# Vertigo Games - Data Analyst Case Study

### Task 1

### Methodology
Since the retention data was provided for only specific days (Day 1, 3, 7, 14), a **Power Law Model** was used to fit the curve and predict retention rates for the missing days (Day 1 to 30).

A cohort-based simulation engine was built in R to calculate Daily Active Users (DAU) and Revenue day-by-day.

### Assumptions
- **ARPPU (Average Revenue Per Paying User):** The provided dataset for Task 1 did not include an ARPPU value. Based on industry standards and to perform the revenue analysis, an ARPPU of **$5.0** was assumed.
- **Sensitivity Analysis:** A break-even analysis was conducted. If the actual ARPPU is above **$2.62**, Variant B wins in the long run. Since $5.0 > $2.62, the results favor Variant B.

### Key Findings & Answers

#### a) Which variant will have the most daily active users after 15 days?
**Answer: Variant B**
- **Reason:** Although Variant A starts with higher retention (D1: 53%), it decays faster. Variant B has a better long-term retention profile, allowing it to accumulate more users over time.

#### b) Which variant will earn the most total money by Day 15?
**Answer: Variant A**
- **Reason:** In the short term, Variant A's superior Ad Revenue per DAU ($0.022 vs $0.017) and higher initial user base outweigh Variant B's retention advantage.

#### c) If we look at the total money earned by Day 30 instead, does our choice change?
**Answer: Yes, Variant B wins.**
- **Reason:** By Day 30, the "compounding effect" of Variant B's better retention kicks in. The larger active user base generates enough IAP revenue to surpass Variant A's early lead.

#### d) Sale Scenario (10-day sale starting on Day 15)
**Answer: Variant B still wins.**
- Both variants benefit from the sale, but Variant B maintains its lead in total revenue by Day 30.

#### e) New User Source Scenario (Mixed Retention from Day 20)
**Answer: Variant B wins.**
- Even with the new user source mix, Variant B's total revenue by Day 30 remains higher than Variant A.

---

### Strategic Recommendation (Question f)

**Recommendation: Prioritize the 10-Day Sale (Option 1).**

**Why?:**
Based on the simulation results:
- **Gain from Sale:** Generates an uplift of approximately **+$24,000 - $25,000**.
- **Gain from New Source:** Generates an uplift of approximately **+$7,000 - $8,000**.

**Conclusion:** The short-term impact of increasing the conversion rate by 1% (Sale) creates significantly more immediate value than the addition of the new user source within the 30-day window. Therefore, the **Sale Strategy** yields a higher ROI.

## Task 2

This section focuses on uncovering user behavior patterns, segmentation opportunities, and monetization trends using the provided user activity dataset.

### Data Cleaning & Preprocessing
Before starting the analysis, the following data integrity steps were taken:
- **Date Parsing:** Standardized `event_date` and `install_date` columns, handling and removing rows with corrupted date formats.
- **Handling Missing Data (Critical Step):** - A significant portion of the dataset had missing (`N/A`) values in the `country` column.
  - Instead of dropping these rows (which would have resulted in significant revenue data loss), **missing values were imputed as "Unknown"**.
  - This ensures that total revenue calculations remain accurate and inclusive of all user activity.

### 📊 Key Analyses & Insights

#### 1. User Segmentation (Day 0 Engagement)
**Hypothesis:** Users who are more active on their first day (Install Day) are more likely to monetize.
- **Methodology:** Users were categorized into three segments ("Low", "Medium", "High") based on their Day 0 total session duration using statistical quartiles.
- **Finding:** There is a strong positive correlation between Day 0 engagement and revenue. **"High Engagement" users are the primary revenue drivers**, validating the importance of a strong "First Time User Experience" (FTUE).

#### 2. Session Duration Trends
**Question:** How does user interest evolve over the first month?
- **Finding:** Average session duration peaks during the first 3 days (Day 0 - Day 3) and sees a noticeable drop afterward.
- **Implication:** Retention strategies (e.g., push notifications, daily rewards) should be most aggressive between Day 3 and Day 7 to prevent churn.

#### 3. Monetization by Platform & Country
- **Platform:** The analysis compares the Total Revenue contribution of iOS vs. Android users. (See `task2_platform_pie.png` for the breakdown).
- **Geography:** The top 10 revenue-generating countries were identified to help prioritize localization and marketing efforts. *Note: The "Unknown" category is included in the dataset to represent users with unidentified locations.*

### 📈 Visualizations
The R script generates the following plots to visualize these findings:
1. **Revenue by Segment:** Bar chart showing average revenue per engagement group.
   <img width="914" height="878" alt="Revenue by Segment" src="https://github.com/user-attachments/assets/192523ab-12d1-458e-98df-bb364cf9f286" />
2. **Session Trend:** Line chart tracking average session duration over the first 30 days.
   <img width="914" height="878" alt="Session Duration Trend" src="https://github.com/user-attachments/assets/e907d444-a86d-44f8-a21e-a6731b447ba1" />
3. **Platform Share:** Pie chart of total revenue distribution.
   <img width="914" height="878" alt="Platform Share" src="https://github.com/user-attachments/assets/938d17f3-1278-44ff-8005-3bd085e77cd6" />
4. **Top Countries:** Bar chart of the highest-grossing countries.
   <img width="914" height="878" alt="Top Countries" src="https://github.com/user-attachments/assets/51ae2b31-85c5-4070-9f53-89fd1db43100" />
