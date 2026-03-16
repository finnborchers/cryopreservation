# Crazy Cells (A1) - 15-Minute Presentation Script

Group: Crazy Cells  
Speakers: Finn Borchers, Franziska Reddner, Maria (Mariia Shabanova)  
Supervisor: M.Sc. Tarek Deeb  
Planned slot (from schedule): 13:20-13:35  
Target duration: 15 minutes + Q&A

## Slide 1 - Title and Context (0:00-0:45) - Speaker: Finn
Suggested slide title: `Cryopreservation of HeLa Cell Suspensions: Effect of CPA Choice on Cooling Behavior and Cell Survival`

Visuals:
- Team names + supervisor name
- Optional background image from lab

Script:
"Good afternoon everyone. We are the Crazy Cells group: Finn Borchers, Franziska Reddner, and Maria Shabanova. Our supervisor for this lab was M.Sc. Tarek Deeb.  
Today we present our cryopreservation project on HeLa cell suspensions. The central question is simple: if we freeze and thaw cells, how can we maximize survival by choosing the right cryoprotective condition and by controlling temperature over time?"

---

## Slide 2 - Problem and Why This Matters (0:45-2:00) - Speaker: Finn
Suggested slide title: `Problem Statement: Why Cryopreservation Is Challenging`

On-slide points:
- Cryopreservation is essential for cell therapy, research, and biobanking
- Freezing can cause lethal cell injury
- We need protocols that preserve viability and recovery after thawing

Script:
"Cryopreservation is widely used whenever living cells must be stored and transported. But freezing is not harmless.  
Cells are damaged mainly by two mechanisms: first, ice crystal damage, especially intracellular ice; and second, solution or osmotic damage from increased extracellular solute concentration during freezing.  
So the practical problem is: we need a freezing-thawing process that is cold enough for storage but gentle enough for cells to survive and remain functional after thawing."

---

## Slide 3 - Biological Background and Hypothesis (2:00-3:15) - Speaker: Finn
Suggested slide title: `Cryodamage Mechanisms and Working Hypothesis`

On-slide points:
- Mazur 2-factor concept: too slow cooling -> solution effects; too fast -> intracellular ice
- Cryoprotectants reduce cryoinjury
- Penetrating (DMSO) vs non-penetrating (sucrose) agents

Script:
"Our background model follows the 2-factor hypothesis: if cooling is too slow, cells dehydrate excessively and suffer solution damage; if cooling is too fast, intracellular ice becomes more likely.  
Cryoprotective agents, or CPAs, are used to reduce this damage. DMSO is penetrating and helps prevent intracellular ice. Sucrose is non-penetrating and mainly supports osmotic protection outside cells.  
Based on this, we expected DMSO-containing conditions to outperform PBS-only controls for post-thaw viability and recovery."

---

## Slide 4 - Experimental Design (3:15-4:45) - Speaker: Finn
Suggested slide title: `Experimental Setup (Crazy Cells vs Cryo Masters)`

On-slide points:
- HeLa suspension split into three CPA conditions:
  - Solution 1: DMSO + FBS
  - Solution 2: Sucrose + FBS
  - Solution 3: PBS only (no dedicated CPA)
- Controlled cooling with Asymptote system
- Thawing in warm water bath, then Vi-CELL counting in triplicates
- Two teams measured in parallel: Crazy Cells and Cryo Masters

Script:
"We split the HeLa suspension into three conditions.  
Condition one was DMSO plus FBS, condition two was sucrose plus FBS, and condition three was PBS only, which acts as our low-protection reference.  
Samples were frozen with a controlled-rate protocol and then thawed, followed by cell counting with Vi-CELL in triplicates.  
Both our team, Crazy Cells, and the Cryo Masters team performed measurements. Our focus is Crazy Cells, but we include Cryo Masters for comparison."

---

## Slide 5 - Data and Analysis Pipeline (4:45-6:00) - Speaker: Franziska
Suggested slide title: `Data Sources and Metrics`

On-slide points:
- Temperature time-series: 6 channels, ~4078 points each
- Vi-CELL sheet: viability %, total cells, viable cells
- Computed metrics:
  - Cooling rate to -80 C
  - Cooling rate to nucleation
  - Thawing rate from minimum to +10 C
  - Recovery % = viable cells after thaw / viable cells before freeze x 100

Script:
"For analysis, we used two datasets.  
First, the temperature log with six channels, one for each team-condition combination.  
Second, the Vi-CELL output with viability and viable-cell concentration for each replicate.  
From these, we calculated cooling rates and thawing rates from the temperature curves, and recovery percentages using the pre-freeze viable-cell baseline from the workbook."

---

## Slide 6 - Full Temperature Curves (6:00-7:20) - Speaker: Franziska
Suggested slide title: `Temperature Profiles Across Freeze-Hold-Thaw`
Insert figure: `analysis_outputs/figures/01_temperature_profiles_full.png`

Key numbers to mention:
- All channels dropped from ~6-7 C to near -190 C
- Cryo Masters sucrose channel showed sensor artifacts (invalid spikes)

Script:
"Here we show the full temperature trajectories for all six channels.  
You can see three clear phases: initial cooling from around 6 to 7 degrees, deep-cold hold near minus 190 degrees, and rapid reheating during thawing.  
Overall patterns are consistent between teams and conditions. One exception is the Cryo Masters sucrose channel, which had clear sensor outliers, so we cleaned those points before calculating rates."

---

## Slide 7 - Freezing Window and Cooling Rates (7:20-8:50) - Speaker: Franziska
Suggested slide title: `Cooling Performance vs Target Rate`
Insert figures:
- `analysis_outputs/figures/02_temperature_profiles_zoom_freezing.png`
- `analysis_outputs/figures/03_rate_summary.png`

Key numbers:
- Cooling to -80 C ranged from about -1.82 to -1.94 K/min
- Mean cooling rate to -80 C: about -1.86 K/min
- Estimated nucleation range: about -10.1 C to -4.9 C

Script:
"Zooming into the controlled freezing region, we compared measured cooling to the nominal target behavior.  
Quantitatively, the cooling rates to minus 80 degrees are very consistent across channels, between about minus 1.82 and minus 1.94 kelvin per minute, with a mean around minus 1.86.  
So in this run, the system cooled faster than the classic 1 K per minute reference.  
The estimated nucleation temperatures ranged roughly from minus 10 to minus 5 degrees, depending on channel and condition."

---

## Slide 8 - Thawing Behavior and Technical Notes (8:50-10:00) - Speaker: Franziska
Suggested slide title: `Thawing Dynamics and Data Quality`
Insert figure: `analysis_outputs/figures/03_rate_summary.png` (reuse right panel focus)

Key points:
- Thawing rates were much higher than cooling rates (expected)
- Channel-dependent differences in reheating speed
- One channel (Cryo Masters sucrose) had many invalid points (217), handled by cleaning

Script:
"During thawing, rates were much steeper than during cooling, which is expected because rapid thawing helps reduce recrystallization risk.  
We also observed strong channel-to-channel differences in thawing slopes, likely influenced by handling and thermal contact details.  
Importantly, we documented and corrected data quality issues in one channel before computing metrics, so the quantitative comparison is transparent."

---

## Slide 9 - Post-thaw Viability Results (10:00-11:30) - Speaker: Maria
Suggested slide title: `Viability (%) by CPA Condition`
Insert figure: `analysis_outputs/figures/04_viability_by_solution.png`

Key numbers (median +/- SD, n=3 per team-condition):
- Crazy Cells:
  - DMSO+FBS: 85.39 +/- 4.02%
  - Sucrose+FBS: 76.00 +/- 3.80%
  - PBS only: 60.00 +/- 13.88%
- Cryo Masters:
  - DMSO+FBS: 81.37 +/- 1.04%
  - Sucrose+FBS: 76.67 +/- 8.28%
  - PBS only: 75.00 +/- 33.68% (high spread)

Script:
"This plot shows viability after thawing.  
For our Crazy Cells data, DMSO plus FBS performed best at about 85 percent viability, sucrose plus FBS was intermediate around 76 percent, and PBS-only was clearly lower around 60 percent.  
Cryo Masters shows the same tendency for DMSO and sucrose, but PBS-only is extremely variable there, which is visible in the large spread.  
Overall, CPA-containing media, especially DMSO-based, are associated with better viability than PBS-only."

---

## Slide 10 - Recovery Results (11:30-12:50) - Speaker: Maria
Suggested slide title: `Recovery Relative to Pre-freeze Viable Cells`
Insert figure: `analysis_outputs/figures/05_recovery_by_solution.png`

Key numbers (median +/- SD):
- Crazy Cells recovery:
  - DMSO+FBS: 6.24 +/- 0.37%
  - Sucrose+FBS: 5.91 +/- 0.78%
  - PBS only: 0.49 +/- 0.19%
- Cryo Masters recovery:
  - DMSO+FBS: 6.82 +/- 0.05%
  - Sucrose+FBS: 4.76 +/- 0.55%
  - PBS only: 0.25 +/- 0.13%

Script:
"Recovery tells us how many viable cells we retain relative to the pre-freeze baseline.  
In Crazy Cells, DMSO and sucrose conditions are both around 6 percent recovery, while PBS-only drops below 1 percent.  
Cryo Masters shows the same core message: DMSO and sucrose preserve far more viable cells than PBS-only.  
So both viability and recovery support the same ranking: DMSO plus FBS is strongest, sucrose plus FBS is intermediate, and PBS-only is weakest."

---

## Slide 11 - Discussion and Interpretation (12:50-14:10) - Speaker: Maria
Suggested slide title: `Discussion: What Did We Learn?`

On-slide points:
- CPA choice strongly influences outcome
- Cooling behavior was consistent; biological outcome differed by condition
- DMSO benefit aligns with penetrating CPA mechanism
- Sucrose provides partial protection
- PBS-only lacks sufficient cryoprotection

Script:
"Our comparison suggests that thermal control alone is not enough.  
Even with similar cooling profiles across channels, biological survival differed significantly by cryoprotective formulation.  
This is consistent with mechanism: DMSO penetrates cells and protects against intracellular ice formation, while sucrose offers extracellular osmotic support but less intracellular protection.  
PBS-only provides insufficient cryoprotection, reflected in low recovery and lower viability."

---

## Slide 12 - Conclusion, Outlook, and Thanks (14:10-15:00) - Speaker: Finn
Suggested slide title: `Conclusions and Next Steps`

On-slide points:
- Main conclusion: DMSO+FBS performed best in this HeLa cryopreservation run
- Sucrose+FBS improved outcomes vs PBS-only
- Recommend standardized thaw protocol and larger n in future runs
- Acknowledge supervisor and audience

Script:
"To conclude, in our HeLa experiment, DMSO plus FBS gave the most robust post-thaw performance, and sucrose plus FBS still clearly outperformed PBS-only.  
The temperature logs confirm controlled and repeatable freezing behavior, while cell outcome data emphasize the critical role of CPA selection.  
For future work, we recommend larger replicate numbers and tighter standardization during thaw handling to reduce variability.  
Thank you for your attention, and special thanks to our supervisor, M.Sc. Tarek Deeb. We are happy to take your questions."

---

## Optional Q&A Backup Points
- Why is recovery low in absolute percent?
  - Recovery is normalized to a pre-freeze baseline and includes losses across freeze, thaw, washing, centrifugation, and handling.
- Why compare with Cryo Masters?
  - Cross-team comparison helps assess robustness and whether trends hold beyond one handling workflow.
- Why not choose sucrose only?
  - In this dataset, sucrose is helpful but less consistent than DMSO-based protection.
