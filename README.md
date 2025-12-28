# ecommerce-persona-dashboard

# E-Commerce User Behavior & Persona Segmentation: Understanding Decision-Making in Digital Environments

## Dashboard Link
[View the interactive dashboard on Tableau Public](https://public.tableau.com/views/E-CommerceConvertingConsumerBehavior/newdash?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

## Overview
This project analyzes 1.7M e-commerce sessions to understand how different user personas make purchasing decisions under cognitive load. Rather than assuming all users experience "choice overload" equally, the analysis reveals that user intent significantly mediates how choice volume affects behavior—challenging simplified models of consumer decision-making.

*Key finding: While some users (such as Indecisive Navigators) do exhibit choice paralysis, high-intent shoppers (like the Power Shoppers) browse extensively and convert at high rates, which suggests decision-making is a lot more nuanced than traditional choice overload theory predicts.*

## Why This Matters
E-commerce platforms often apply *one-size-fits-all* UX solutions. This analysis shows that user intent is the critical variable—the same design choice (e.g., showing 50 products) may help Power Shoppers and harm Indecisive Navigators. Understanding these differences **enables** more transparent, **user-centered design**.

## Project Goals
  - identify key behavioral patterns for each persona
  - visualize where users drop off in the shopping funnel
  - recommend actionable strategies to increase conversion rates for each persona
  - provide a user-friendly, interactive dashboard for anyone to view!

## Data & Methodology
  - **Source:** [Kaggle E-Commerce Dataset](https://www.kaggle.com/datasets/retailrocket/ecommerce-dataset)
  - **Processing:** Data cleaned and segmented using SQL (see `queries.sql`)
  - **Personas:** Defined by session length, browsing depth, and purchase patterns
  - **Visualization:** Built in Tableau, with custom funnel and comparison charts
  - **Theoretical grounding:** Behavioral research on the paradox of choice (Iyengar & Lepper, 2000)

## Design Implications
Understanding persona-specific decision-making barriers can inform ethical UX design:
  - **Casual Browsers:** Quick-add features, reduced choice, urgency cues to capture low-intent attention

  - **Indecisive Navigators:** Comparison tools, personalized recommendations, and simplified checkout reduce decision anxiety

  - **Power Shoppers:** Bundling, loyalty rewards, streamlined bulk purchasing

  - Design note: Interventions that help Indecisive Navigators may not suit high-intent shoppers like Power Shoppers, suggesting platforms should offer persona-aware experiences.

## Key Insights
  - **Casual Browsers** drop off early; limiting choices increases engagement.
  - **Indecisive Navigators** add to cart but hesitate at checkout; comparison tools boost confidence.
  - **Power Shoppers** convert at high rates; streamlined checkout and clear pricing are critical.
**Central Insight:**
The traditional "paradox of choice" holds true for some user segments but not others. Indecisive Navigators appear to experience decision fatigue, while Power Shoppers demonstrate that high intent enables users to navigate complexity effectively. This suggests user intent, not choice volume alone, predicts purchasing behavior.

## Challenges & Insights
Theory predicts choice overload should suppress all high-volume browsing, but Power Shoppers browse extensively and convert at high rates. This reveals the importance of intent-based segmentation—choice only "paralyzes" those with low or ambivalent purchase intent.


## Features
- **Persona Cards:** Quick summaries of each shopper type and their conversion rates
- **Drop-Off Funnels:** Visualize where each persona exits the shopping process
- **Key Metrics:** Compare conversion, session length, and items viewed across personas and site averages
- **Interactive Comparison:** Select a persona to dive deeper and benchmark against site averages
- **Actionable Insights:** Strategy cards with research-backed recommendations for each persona

## How to Use
1. **select a persona card** to view their shopping behavior.
2. **compare metrics** with site averages to see what drives purchases.
3. **review strategy cards** for actionable recommendations tailored to each persona.

## File Structure
- `dashboard.twbx` — Tableau packaged workbook
- `queries.sql` — All SQL queries used for data processing (clearly commented)
- `data/` — Source and processed data files
- `README.md` — Project documentation (this file)


## Tools Used
- Tableau Public
- SQL (SQLite/Excel)
- Figma (for design mockups)

## References
1. [Kaggle E-Commerce Dataset](https://www.kaggle.com/datasets/retailrocket/ecommerce-dataset)
2. [Iyengar & Lepper (2000) - Choice Overload](https://psycnet.apa.org/record/2000-16701-012)
3. [Baymard Institute - Cart Abandonment](https://baymard.com/lists/cart-abandonment-rate)
4. [Nielsen Norman Group - Comparison Tables](https://www.nngroup.com/articles/comparison-tables/)

## Author
[Cameron Hill]  
[(https://www.linkedin.com/in/cameronh2601/)]

For feedback, questions, or more portfolio projects, contact chill101@umd.edu.
