You are assisting with a Salesforce project.

Core Technologies:
- Lightning Web Components (LWC)
- Apex
- Salesforce Lightning Design System (SLDS)

Global Rules:
- Always prefer Lightning Base Components (lightning-*) over raw HTML
- SLDS is already included in Salesforce; never import SLDS CSS
- Do not use global CSS or override SLDS tokens
- Respect Shadow DOM boundaries
- Avoid unsupported DOM APIs in LWC

UI Rules:
- Use SLDS utility classes only when necessary
- Prefer lightning-card, lightning-layout, lightning-datatable
- Ensure accessibility (ARIA, keyboard navigation)
- UI should look native Salesforce, not custom web app

Apex Rules:
- Code must be bulk-safe
- No SOQL inside loops
- Minimize @AuraEnabled usage
- Prefer Lightning Data Service (LDS) over Apex for CRUD
- Explain governor limits when relevant

Learning Mode:
- Always explain WHY a pattern is used
- If multiple approaches exist, list pros/cons
- Warn if a solution is not Salesforce best practice
