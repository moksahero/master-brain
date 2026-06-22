---
course: "Apps & Extras"
lesson: "Lead gen with AI (n8n + Claude)"
type: module
skool_url: https://www.skool.com/ai-marketing-hub-pro/classroom/62de05f5?md=b7f80fd54121412b89959a5ae957ff50
course_slug: 62de05f5
module_id: b7f80fd54121412b89959a5ae957ff50
---
# Lead gen with AI (n8n + Claude)

![image.png](https://assets.skool.com/f/49ff1f2d656742a68e4b871cd8c0e543/5763554ae740479dad4ecd3ac5d55cff71549077922b4f4d9388350b83000c87-md.png)

Enrichard (Google Maps) scrape + Mr. Claude to get the leads.  
  
1. Run the n8n workflow (get the leads)  
2. Make a copy of the sheets  
3. After you process the leads, download the .csv, share into your claude and paste this prompt:  
4. Prompt for Claude:

```
# Lead Processing Prompt (Copy-Paste into Claude)

You are a lead enrichment and outreach agent. Process the attached CSV of scraped Google Maps leads through these steps in order:

## STEP 1: ENRICH LINKEDIN + EMAIL
For each business in the CSV:
- Find the decision maker / owner LinkedIn profile. Search "site:linkedin.com [business name] [city] owner" and variations.
- Find the business email. Check the company website contact page, footer, about page. Search "site:[domain] email" and "[business name] email [city]".
- If no email found on first pass, dig deeper: check BBB listings, Yelp, Facebook business pages, Chamber of Commerce, and industry directories.
- ONLY use verified emails. If a domain doesn't exist or email can't be confirmed from a public source, leave it blank.
- No generic emails (info@, contact@, service@, office@, support@). We want personal/owner emails only. Gmail, AOL, named addresses like garyp@company.com are good.

## STEP 2: VERIFY ALL DATA
- Verify every LinkedIn URL actually leads to the correct person at the correct company.
- Verify every email domain exists (DNS/MX check). Remove any with dead domains.
- Cross-reference person names on LinkedIn with the actual business. Flag mismatches but keep if person is confirmed correct.
- Remove any email you are not 95%+ confident about.

## STEP 3: WRITE ICE BREAKERS
Add 3 columns: "Ice Breaker LinkedIn", "Ice Breaker Email", "Ice Breaker Phone"

Style rules:
- Gary Vee soft tone. Warm, direct, natural, short.
- No m-dashes (--). Use periods and commas only.
- Personalize using: review count, rating, founding year, owner backstory, niche focus, number of locations, anything unique about the business.
- If no LinkedIn found, leave Ice Breaker LinkedIn blank.
- If no email found, leave Ice Breaker Email blank.
- Always write Ice Breaker Phone (we have every phone number).

The offer being pitched: SEO / Google ranking services.

LinkedIn ice breaker: Open with something personal about the owner. Reference their background. Connect it to SEO. End with "Worth connecting?"
Email ice breaker: Start with "Hey [Name]," reference the business stats or story. Pitch SEO value. End with a soft CTA.
Phone ice breaker: Start with "Hey [Name], quick one." Reference one standout stat. Pitch in one sentence. End with "Got a couple minutes?"

## STEP 4: OUTPUT
- Update the CSV with all enriched data.
- Flag the best targets: leads with personal emails (not generic), owner LinkedIn found, mid-size companies (not too big, not too small), high ratings.
- Generate a Blog Outreach Plan PDF identifying the top targets and a recommended blog topic for cold outreach.

CSV columns: Scrape Date, Business Name, Website, Phone, Rating, Review Count, City, Address, Maps URL, Decision Maker Linkedin, Business Email, Ice Breaker LinkedIn, Ice Breaker Email, Ice Breaker Phone
```

## Prompt for pdf generation:

```
Generate a professional PDF report of the audit findings. Include all findings, data points, and recommendations. Add bar/pie/line charts to visualize key metrics, and embed any relevant screenshots inline with their sections — all properly sized with captions. Use a clean layout with a title page, table of contents, section headers, consistent fonts/colors, and page numbers. Ensure no overlapping, clipping, or overflow. Save as a single, well-formatted PDF.
```

---

## Resources

- [n8n Google Maps Leads Scraper](https://assets.skool.com/f/49ff1f2d656742a68e4b871cd8c0e543/4b46bf3f3e59479c9c7bd393ebe11593d722b12e02bb46eea1fb5a3f2a086360)
- [Google Sheets Example](https://docs.google.com/spreadsheets/d/1aLhksDuo8_6PYCWIJh-cHxZvV-eFaZsknbq9VPx0NpI/edit?usp=sharing)
