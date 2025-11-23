# Vertigo Games - Data Analyst Case Study

### Task 1: A/B Test Modeling & Simulation

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

### 💡 Strategic Recommendation (Question f)

**Recommendation: Prioritize the 10-Day Sale (Option 1).**

**Why?:**
Based on the simulation results (comparing the "Net Gain" of each scenario against the baseline):
- **Gain from Sale:** Generates an uplift of approximately **+$24,000 - $25,000**.
- **Gain from New Source:** Generates an uplift of approximately **+$7,000 - $8,000**.

**Conclusion:** The short-term impact of increasing the conversion rate by 1% (Sale) creates significantly more immediate value than the addition of the new user source within the 30-day window. Therefore, the **Sale Strategy** yields a higher ROI.
