# ecommerce-persona-dashboard

# E-Commerce Psychology: Converting Consumer Behavior Into Revenue

## Overview
This project analyzes 1.7M e-commerce sessions to uncover how different shopper personas behave and what drives them to purchase. The interactive Tableau dashboard segments users into three personas—Casual Browser, Indecisive Navigator, and Power Shopper—and visualizes their shopping patterns, drop-off points, and conversion strategies.

## Dashboard Link
[View the interactive dashboard on Tableau Public](https://public.tableau.com/views/E-CommerceConvertingConsumerBehavior/newdash?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

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

## Key Insights
- **Casual Browsers** drop off early; limiting choices increases engagement.
- **Indecisive Navigators** add to cart but hesitate at checkout; comparison tools boost confidence.
- **Power Shoppers** convert at high rates; streamlined checkout and clear pricing are critical.

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
