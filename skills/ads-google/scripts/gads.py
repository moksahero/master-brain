#!/usr/bin/env python3
"""Minimal Google Ads REST helper (GAQL) — stdlib only, no google-ads SDK.

Ships with the master-brain `ads-google` skill; copy into your ads workspace
(e.g. <workspace>/shared/tools/gads.py) on bootstrap and import from there.

Auth is read from the shell env (put these in ~/.claude/settings.json "env"):
    GOOGLE_ADS_DEVELOPER_TOKEN, GOOGLE_ADS_OAUTH_CLIENT_ID,
    GOOGLE_ADS_OAUTH_CLIENT_SECRET, GOOGLE_ADS_REFRESH_TOKEN,
    GOOGLE_ADS_LOGIN_CUSTOMER_ID (MCC id; optional for direct account access)

Usage:
    import sys; sys.path.insert(0, "<workspace>/shared/tools")
    import gads
    for row in gads.search("SELECT customer.id, customer.descriptive_name FROM customer",
                           cid="1234567890"):
        print(row["customer"])
    gads.mutate("campaignBudgets", [{"create": {...}}], cid="1234567890")

`cid` is the target customer id (digits, hyphens allowed). It is REQUIRED per
call (no silent default) so a shared helper can never write to the wrong
account by accident. GOOGLE_ADS_CID in the env acts as an explicit fallback.
"""
import os
import json
import time
import urllib.request
import urllib.error

API_VER = "v22"

_token_cache = {"tok": None, "exp": 0}


def _env(name, required=True):
    v = os.environ.get(name, "")
    if required and not v:
        raise RuntimeError(
            f"{name} is not set. Add it to the 'env' block of ~/.claude/settings.json "
            "(see the ads-google skill, 'Auth & the API helper').")
    return v


def _cid(cid):
    cid = cid or os.environ.get("GOOGLE_ADS_CID", "")
    if not cid:
        raise ValueError("cid is required (pass cid=... or set GOOGLE_ADS_CID)")
    return str(cid).replace("-", "")


def _post(url, data, headers, is_json=True):
    body = json.dumps(data).encode() if is_json else data.encode()
    req = urllib.request.Request(url, data=body, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req) as r:
            return json.loads(r.read().decode())
    except urllib.error.HTTPError as e:
        raise RuntimeError(f"HTTP {e.code} {url}\n{e.read().decode()}") from None


def access_token():
    if _token_cache["tok"] and time.time() < _token_cache["exp"] - 60:
        return _token_cache["tok"]
    form = (f"client_id={_env('GOOGLE_ADS_OAUTH_CLIENT_ID')}"
            f"&client_secret={_env('GOOGLE_ADS_OAUTH_CLIENT_SECRET')}"
            f"&refresh_token={_env('GOOGLE_ADS_REFRESH_TOKEN')}"
            f"&grant_type=refresh_token")
    r = _post("https://oauth2.googleapis.com/token", form,
              {"Content-Type": "application/x-www-form-urlencoded"}, is_json=False)
    _token_cache["tok"] = r["access_token"]
    _token_cache["exp"] = time.time() + r.get("expires_in", 3600)
    return _token_cache["tok"]


def _headers():
    h = {"Authorization": f"Bearer {access_token()}",
         "developer-token": _env("GOOGLE_ADS_DEVELOPER_TOKEN"),
         "Content-Type": "application/json"}
    login = _env("GOOGLE_ADS_LOGIN_CUSTOMER_ID", required=False)
    if login:  # MCC access; omit for direct single-account credentials
        h["login-customer-id"] = login.replace("-", "")
    return h


def search(query, cid=None):
    """Run a GAQL query, auto-paginating; returns a list of result rows."""
    cid = _cid(cid)
    url = f"https://googleads.googleapis.com/{API_VER}/customers/{cid}/googleAds:search"
    out, page = [], None
    while True:
        payload = {"query": query}
        if page:
            payload["pageToken"] = page
        r = _post(url, payload, _headers())
        out.extend(r.get("results", []))
        page = r.get("nextPageToken")
        if not page:
            break
    return out


def mutate(service, operations, cid=None, extra=None):
    """service e.g. 'campaigns', 'adGroups', 'campaignBudgets', 'adGroupCriteria'."""
    cid = _cid(cid)
    url = f"https://googleads.googleapis.com/{API_VER}/customers/{cid}/{service}:mutate"
    payload = {"operations": operations}
    if extra:
        payload.update(extra)
    return _post(url, payload, _headers())


def units(s):
    """Google RSA character count: full-width (CJK/W/F) chars count as 2, others as 1.
    Headline limit 30 units, description limit 90 units. Validate BEFORE writing ads."""
    import unicodedata
    return sum(2 if unicodedata.east_asian_width(c) in ("W", "F") else 1 for c in s)


if __name__ == "__main__":
    import sys
    cid = sys.argv[1] if len(sys.argv) > 1 else None
    for row in search("SELECT customer.id, customer.descriptive_name, customer.currency_code, "
                      "customer.time_zone, customer.status FROM customer", cid=cid):
        print(json.dumps(row["customer"], ensure_ascii=False))
