# Crazy Cells (A1) - 15-Minute Presentation Script

Group: Crazy Cells  
Speakers: Finn Borchers, Franziska Reddner, Maria (Mariia Shabanova)  
Supervisor: M.Sc. Tarek Deeb  
Planned slot (from schedule): 13:20-13:35  
Target duration: 15 minutes + Q&A

## Slide 1 - Title and Context (0:00-0:45) - Speaker: Finn
Suggested slide title: `Cryopreservation of HeLa Cell Suspensions`

Visuals:
- Cover image from lab workflow
- Team names + supervisor name

Script:
"Good afternoon everyone. We are the Crazy Cells group: Finn Borchers, Franziska Reddner, and Maria Shabanova. Our supervisor for this lab was M.Sc. Tarek Deeb.  
Today we present our cryopreservation project on HeLa cell suspensions. Our key question is how we can maximize post-thaw survival by combining suitable cryoprotective media with controlled temperature handling."

---

## Slide 2 - Problem and Why This Matters (0:45-1:50) - Speaker: Finn
Suggested slide title: `Problem Statement: Why Cryopreservation Is Challenging`

On-slide points:
- Cryopreservation is essential in research and therapy workflows
- Freezing can damage cells mechanically and osmotically
- The practical aim is high viability and high recovery after thawing

Script:
"Cryopreservation is crucial for storing and transporting living cells. But freezing is risky.  
Cells can be damaged by intracellular or extracellular ice effects and by osmotic stress during water/solute redistribution.  
So the practical challenge is to preserve cells at low temperature while still recovering viable cells after thawing."

---

## Slide 3 - Mechanism and Hypothesis (1:50-2:55) - Speaker: Finn
Suggested slide title: `Cryodamage Mechanisms and Working Hypothesis`

On-slide points:
- 2-factor idea: too slow cooling -> solution damage; too fast -> ice damage
- Penetrating CPA (DMSO) vs non-penetrating CPA (sucrose)
- Hypothesis: DMSO-containing condition should perform best vs PBS-only

Script:
"Based on the 2-factor concept, both very slow and very fast cooling can be harmful, but for different reasons.  
To reduce injury, we compare CPAs: DMSO as a penetrating cryoprotectant and sucrose as a non-penetrating one.  
Our expectation was that DMSO-containing medium would provide better post-thaw outcomes than PBS-only."

---

## Slide 4 - Experimental Setup in the Lab (2:55-4:00) - Speaker: Finn
Suggested slide title: `Experimental Setup in the Lab`

Visuals:
- Biosafety cabinet image
- Cooling/measurement setup image

Script:
"Here you see our practical setup.  
We prepared and handled cell suspensions under clean conditions, split samples into three media conditions, and recorded temperatures with probe channels during freezing.  
The three tested conditions were DMSO+FBS, Sucrose+FBS, and PBS-only. We measured triplicates and later compared our Crazy Cells data with Cryo Masters."

---

## Slide 5 - Data Sources and Metrics (4:00-5:10) - Speaker: Franziska
Suggested slide title: `Data Sources and Analysis Metrics`

Visuals:
- Vi-CELL device image

On-slide points:
- Temperature series: 6 channels, 4078 points/channel
- Vi-CELL outputs: viability %, total cells, viable cells
- Metrics: cooling rate, thawing rate, recovery %, nucleation points

Script:
"We used two data sources.  
First, the Asymptote temperature series with six channels and one-second sampling.  
Second, Vi-CELL outputs for viability and viable cell concentration.  
From this we computed cooling and thawing rates, recovery percentages, and in a new detailed step, exact nucleation and recalescence points.  
For recovery, we used cells per sample, not just concentration per milliliter."

---

## Slide 6 - Full Temperature Profiles (5:10-6:20) - Speaker: Franziska
Suggested slide title: `Temperature Profiles Across Freeze-Hold-Thaw`  
Insert figure: `analysis/figures/01_temperature_profiles_full.png`

Script:
"This figure shows the full thermal trajectories.  
All channels start around 6 to 7 degrees, cool down to deep cryogenic temperatures near minus 190 degrees, and then rewarm.  
The overall sequence is consistent, and we applied cleaning for obvious sensor artifacts in one noisy channel before extracting exact events."

---

## Slide 7 - Freezing Rates and Target Comparison (6:20-7:25) - Speaker: Franziska
Suggested slide title: `Cooling Performance vs Target Behavior`  
Insert figures:
- `analysis/figures/02_temperature_profiles_zoom_freezing.png`
- `analysis/figures/03_rate_summary.png`

Script:
"In the controlled freezing window, channels behave similarly.  
Using the corrected definition from minute 5 to minute 45, controlled-cooling rates are close to minus 1 K per minute (about -0.93 to -0.96 K per minute).  
This confirms reproducible thermal control and gives us a good basis for interpreting later biological outcomes."

---

## Slide 8 - Nucleation in Supercooled Water (7:25-9:10) - Speaker: Franziska
Suggested slide title: `Nucleation in Supercooled Water (Recalescence Zoom)`  
Insert figure: `analysis/figures/06_nucleation_zoom.png`

How to read this chart:
- Rows = protective condition (`DMSO+FBS`, `Sucrose+FBS`, `PBS only`)
- Columns = team (`Crazy Cells` left, `Cryo Masters` right)
- `t = 0 s` is nucleation onset (supercooled minimum)
- Marked rebound point is recalescence peak
- Dashed segment is `DeltaT` from latent heat release during crystallization  
  (`Kristallkeimbildung in unterkühltem Wasser`)

Exact points to say:
- CC-DMSO: `-10.13 -> -1.19 C`, `DeltaT 8.94 C`
- CC-Suc: `-9.96 -> -0.28 C`, `DeltaT 9.68 C`
- CC-PBS: `-7.13 -> 0.86 C`, `DeltaT 7.99 C`
- CM-DMSO: `-9.75 -> -2.57 C`, `DeltaT 7.18 C`
- CM-Suc: `-12.72 -> -1.82 C`, `DeltaT 10.90 C`
- CM-PBS: `-8.23 -> 0.12 C`, `DeltaT 8.35 C`

Interpretation lines:
- Larger `DeltaT` indicates a stronger or clearer crystallization rebound.
- Nucleation starts at different supercooling depths between channels.
- This is a thermal marker of phase transition, not by itself a viability endpoint.

Script:
"This zoom shows the nucleation moment for each channel.  
Time zero is the supercooled minimum.  
Right after nucleation, temperature rebounds because latent heat is released as ice forms, and the dashed segment shows that DeltaT jump.  
The strongest rebound is Cryo Masters sucrose with DeltaT 10.90 C.  
This is a thermal marker of freezing physics, not a direct viability result."

---

## Slide 9 - Thawing Dynamics and Data Quality (9:10-10:05) - Speaker: Franziska
Suggested slide title: `Thawing Dynamics and Data Quality`  
Insert figure: `analysis/figures/03_rate_summary.png`

Script:
"During thawing, temperatures rise much faster than during controlled cooling.  
For PBS, Cryo Masters reaches +10 C earlier than Crazy Cells in this dataset, so the PBS thawing rate is higher.  
Crazy Cells PBS starts at -187.97 C at 52.35 min and reaches +10 C at 55.479 min, which is 63.27 K/min.  
Cryo Masters PBS starts at -189.51 C at 52.35 min and reaches +10 C at 54.413 min, which is 96.73 K/min.  
For sucrose, Crazy Cells is 78.74 K/min and Cryo Masters is 102.14 K/min, but Cryo Masters has a sharp spike near +10 C.  
So we keep that value visible, but interpret that channel cautiously and focus on overall trends."

---

## Slide 10 - Post-thaw Viability Results (10:05-11:20) - Speaker: Maria
Suggested slide title: `Post-thaw Viability by CPA Condition`  
Insert figure: `analysis/figures/04_viability_by_solution.png`

Key values (median +/- SD):
- Crazy Cells:
  - DMSO+FBS: `85.39 +/- 4.02%`
  - Sucrose+FBS: `76.00 +/- 3.80%`
  - PBS only: `60.00 +/- 13.88%`
- Cryo Masters:
  - DMSO+FBS: `81.37 +/- 1.04%`
  - Sucrose+FBS: `76.67 +/- 8.28%`
  - PBS only: `75.00 +/- 33.68%`

Script:
"Viability results show DMSO+FBS as strongest and PBS-only as less robust, especially regarding spread.  
Cryo Masters PBS has very high SD because the three Vi-CELL repeat counts are far apart.  
These are technical repeats from the same thawed sample, so the spread mainly reflects counting, mixing, or handling scatter rather than true biological replicate variation."

---

## Slide 11 - Recovery Results (11:20-12:30) - Speaker: Maria
Suggested slide title: `Recovery Relative to Pre-freeze Viable Cells`  
Insert figure: `analysis/figures/05_recovery_by_solution.png`

Key values (median +/- SD):
- Crazy Cells:
  - DMSO+FBS: `18.72 +/- 1.11%`
  - Sucrose+FBS: `17.73 +/- 2.33%`
  - PBS only: `1.48 +/- 0.57%`
- Cryo Masters:
  - DMSO+FBS: `20.46 +/- 0.14%`
  - Sucrose+FBS: `14.29 +/- 1.64%`
  - PBS only: `0.74 +/- 0.38%`

Script:
"Recovery supports the same ranking: DMSO and sucrose are much better than PBS-only.  
Here we corrected the formula to match the lab protocol.  
Each sample started from 500 microliters before freezing, and this starting sample contained 1.47 million viable cells in total.  
After thawing, washing, and centrifugation, the cells were resuspended in 3 milliliters of PBS.  
This suspension was divided into three 1 milliliter aliquots for Vi-CELL counting.  
These three aliquots are technical repeat measurements of the same recovered sample.  
Recovery then compares the 1.47 million viable cells at the start with the cells estimated for the full recovered suspension after thaw.  
With this corrected recovery, DMSO is highest, sucrose is intermediate, and PBS-only is clearly lowest.  
So both viability and recovery indicate that cryoprotective formulation is a major driver of post-thaw success."

---

## Slide 12 - Discussion (12:30-13:50) - Speaker: Maria
Suggested slide title: `Discussion: What Did We Learn?`

On-slide points:
- Thermal control was relatively consistent
- Nucleation behavior differs by channel and condition
- Biological outcomes still depend strongly on CPA choice
- High SD likely reflects handling sensitivity + low-protection conditions

Script:
"Even when global cooling behavior is comparable, outcomes differ biologically by condition.  
The nucleation zoom adds mechanistic detail: crystallization events differ in supercooling depth and rebound size.  
But the strongest practical message remains that CPA selection, especially using DMSO-containing media, improves post-thaw performance."

---

## Slide 13 - Conclusions and Next Steps (13:50-15:00) - Speaker: Finn
Suggested slide title: `Conclusions and Next Steps`

On-slide points:
- DMSO+FBS performed best in this run
- Sucrose+FBS improved outcomes compared with PBS-only
- Nucleation analysis strengthened thermal interpretation
- Future: larger n and stricter thaw standardization

Script:
"To conclude, DMSO+FBS delivered the most robust overall outcome in our experiment.  
Sucrose+FBS also improved survival compared with PBS-only.  
The new nucleation recalescence analysis helped us interpret thermal transition events more precisely.  
For future work, we recommend larger replicate numbers and tighter standardization of thaw and handling steps.  
Thank you for your attention."

---

## Optional Q&A Backup Points
- **How is SD calculated in simple terms?**  
  It is the typical distance of replicate values from their average. Large SD means replicates are far apart.
- **Why can SD be high in Cryo Masters PBS?**  
  Small n=3 plus large replicate spread, and PBS-only is more sensitive to handling and thaw variability.
- **Do larger DeltaT jumps mean better viability?**  
  Not directly. DeltaT describes freezing thermodynamics; viability also depends on CPA toxicity/protection and handling.
