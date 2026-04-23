/*===========================================================
  Fitbit Claims Analysis Tables
  Public-facing cleaned version of the original workflow
  - Uses project-relative paths
  - Keeps analysis logic intact
  - Expects restricted datasets to be placed in ./data
===========================================================*/
options dlcreatedir;

%let project_root = .;
%let data_dir = &project_root./data;
%let out_dir  = &project_root./results/tables;

libname dirdd "&data_dir.";

/* Expected input dataset in ./data:
   - comb_claims
*/

/*===========================================================
  0) LIBNAME
===========================================================*/

/*===========================================================
  1) BASIC QA
===========================================================*/
proc contents data=dirdd.comb_claims; run;

options obs=20;
proc print data=dirdd.comb_claims;
  title "Sample of DIRDD.COMB_CLAIMS";
  format dateout mmddyy10.;
run;
options obs=max;

/*===========================================================
  2) CLEAN FORMATS THAT BREAK PROCEDURES
     - POSIDF. is missing (so do not use it)
     - STUDY_ARM_. is missing and is attached to study_arm
===========================================================*/
data work.claims_clean;
  set dirdd.comb_claims;
  format study_arm;           /* strips missing STUDY_ARM_. */
  /* do NOT apply PosIdf. anywhere unless you define it */
run;

/*===========================================================
  3) EMPLOYEE-YEAR-POS-ARM ANNUAL TOTALS (LONG TABLE)
     Goal: one row per employee_id  claim_year  PosId  study_arm
           with:
             - SumPos = total ChargeAmt
             - Freq   = number of claims/rows contributing
===========================================================*/
proc sort data=work.claims_clean out=work.claims_sorted;
  by employee_id claim_year PosId study_arm;
run;

proc means data=work.claims_sorted nway noprint;
  where claim_year in (2020, 2021)         /* limit to years used in diffs */
        and PosId not in (31, 99)          /* keep your exclusions here */
        and study_arm ne .;
  by employee_id claim_year PosId study_arm;
  var ChargeAmt;
  output out=work.scost_long(drop=_type_ _freq_)
         n   = Freq
         sum = SumPos;
run;

/* QA: confirm year distribution */
proc freq data=work.scost_long;
  tables claim_year / missing;
run;

options obs=20;
proc print data=work.scost_long;
  title "scost_long (employee-year-pos-arm totals): first 20";
run;
options obs=max;

/*===========================================================
  4) YEARLY MEANS BY POS AND ARM (NO DIFFS NEEDED)
     This is usually the most defensible claims summary.
===========================================================*/
proc sort data=work.scost_long;
  by claim_year PosId;
run;

proc means data=work.scost_long maxdec=2 n mean std clm;
  by claim_year;
  class PosId study_arm;
  var SumPos Freq;
  title "Annual totals (SumPos, Freq) by Year  POSID  Study Arm";
run;

/*===========================================================
  5) T-TESTS OF ANNUAL TOTALS BY YEAR AND POS (ARM COMPARISON)
     (Uses all available employee-year observations)
===========================================================*/
proc ttest data=work.scost_long plots=none;
  where PosId not in (9);   /* you excluded 9 later; keep if desired */
  by claim_year PosId;
  class study_arm;
  var SumPos Freq;
  title "T-tests comparing Study Arm within Year  POSID (annual totals)";
run;

/*===========================================================
  6) WIDE TABLE: 2020 vs 2021 (PER EMPLOYEE  POS  ARM)
     Robust method using PROC TRANSPOSE.
===========================================================*/
proc sort data=work.scost_long;
  by employee_id PosId study_arm claim_year;
run;

/* SumPos wide */
proc transpose data=work.scost_long out=work.sumpos_wide prefix=SumPos_;
  by employee_id PosId study_arm;
  id claim_year;
  var SumPos;
run;

/* Freq wide */
proc transpose data=work.scost_long out=work.freq_wide prefix=Freq_;
  by employee_id PosId study_arm;
  id claim_year;
  var Freq;
run;

/* Merge wide tables and compute diffs */
data work.scostrx;
  merge work.sumpos_wide work.freq_wide;
  by employee_id PosId study_arm;

  /* Differences (will be missing if a year is missing) */
  SumPos_Diff = SumPos_2021 - SumPos_2020;
  Freq_Diff   = Freq_2021   - Freq_2020;

  keep employee_id PosId study_arm
       SumPos_2020 SumPos_2021 SumPos_Diff
       Freq_2020   Freq_2021   Freq_Diff;
run;

/* QA */
proc sql;
  select count(*) as n_obs from work.scostrx;
quit;

options obs=20;
proc print data=work.scostrx;
  title "scostrx (wide): first 20";
run;
options obs=max;

/*===========================================================
  7) MEANS ON WIDE COLUMNS (will include missing where one year absent)
===========================================================*/
proc means data=work.scostrx maxdec=2 n mean std clm;
  class PosId study_arm;
  var SumPos_2020 SumPos_2021 SumPos_Diff
      Freq_2020   Freq_2021   Freq_Diff;
  title "Wide summary (2020/2021 and differences) by POSID  Study Arm";
run;

/*===========================================================
  8) T-TESTS ON DIFFERENCES (RECOMMENDED: COMPLETE PAIRS ONLY)
     Because most employees do not have both years within the same POSID.
===========================================================*/
data work.scostrx_complete;
  set work.scostrx;
  if not missing(SumPos_2020) and not missing(SumPos_2021);
run;

proc sort data=work.scostrx_complete;
  by PosId;
run;

proc ttest data=work.scostrx_complete plots=none;
  where PosId not in (31, 99, 9);
  by PosId;
  class study_arm;
  var SumPos_Diff Freq_Diff;
  title "T-tests on within-employee changes (complete pairs only) by POSID";
run;

/****************************************************************************************************/

/*  Formats for all of the variables in REDCap */

proc format;
	value $redcap_event_name_ baseline_arm_1='Baseline' '3_months_arm_1'='3 Months' 
		'6_months_arm_1'='6 Months' '9_months_arm_1'='9 Months' 
		'12_months_arm_1'='12 Months';
	value insurance_ 1='Yes, I will' 0='No, I will not';
	value consent_ 1='I consent to be part of this study' 0='I do not consent to be part of this study';
	value shift_ 1='Day shift' 2='Evening shift' 
		3='Night shift' 99='Mixed';
	value hours_ 20='20-30' 30='30-40' 
		40='40-50' 50='50-60' 
		60='60+';
	value race___2_ 0='Unchecked' 1='Checked';
	value race___1_ 0='Unchecked' 1='Checked';
	value race___3_ 0='Unchecked' 1='Checked';
	value race___4_ 0='Unchecked' 1='Checked';
	value race___5_ 0='Unchecked' 1='Checked';
	value race___88_ 0='Unchecked' 1='Checked';
	value race___99_ 0='Unchecked' 1='Checked';
	value ethnicity_ 0='Not Hispanic/Latino' 1='Hispanic/Latino' 
		88='Prefer not to answer';
	value gender_ 1='Male' 2='Female' 
		88='Prefer not to answer' 99='Prefer to self-describe as:';
	value overall_ 4='Excellent' 3='Good' 
		2='Fair' 1='Poor';
	value conditions___0_ 0='Unchecked' 1='Checked';
	value conditions___1_ 0='Unchecked' 1='Checked';
	value conditions___2_ 0='Unchecked' 1='Checked';
	value conditions___3_ 0='Unchecked' 1='Checked';
	value conditions___4_ 0='Unchecked' 1='Checked';
	value conditions___5_ 0='Unchecked' 1='Checked';
	value conditions___99_ 0='Unchecked' 1='Checked';
	value improve_health_motivation_ 5='Strongly agree' 4='Somewhat agree' 
		3='Neither agree nor disagree' 2='Somewhat disagree' 
		1='Strongly disagree';
	value improve_health_confidence_ 5='Strongly agree' 4='Somewhat agree' 
		3='Neither agree nor disagree' 2='Somewhat disagree' 
		1='Strongly disagree';
	value eating_habits_ 4='Excellent' 3='Good' 
		2='Fair' 1='Poor';
	value eating_habits_fruits_ 5='5 or more' 4='4' 
		3='3' 2='2' 
		1='1' 0='0';
	value eating_habits_grains_ 3='3 or more' 2='2' 
		1='1' 0='0';
	value eating_habits_drinks_ 2='2 or more' 1='1' 
		0='0';
	value nutrition_app_yn_ 1='Yes' 0='No';
	value nutrition_app___1_ 0='Unchecked' 1='Checked';
	value nutrition_app___2_ 0='Unchecked' 1='Checked';
	value nutrition_app___3_ 0='Unchecked' 1='Checked';
	value nutrition_app___4_ 0='Unchecked' 1='Checked';
	value nutrition_app___5_ 0='Unchecked' 1='Checked';
	value nutrition_app___6_ 0='Unchecked' 1='Checked';
	value nutrition_app___7_ 0='Unchecked' 1='Checked';
	value nutrition_app___8_ 0='Unchecked' 1='Checked';
	value nutrition_app___9_ 0='Unchecked' 1='Checked';
	value nutrition_app___10_ 0='Unchecked' 1='Checked';
	value nutrition_app___99_ 0='Unchecked' 1='Checked';
	value eating_plan_yn_ 1='Yes' 0='No';
	value eating_plan___1_ 0='Unchecked' 1='Checked';
	value eating_plan___2_ 0='Unchecked' 1='Checked';
	value eating_plan___3_ 0='Unchecked' 1='Checked';
	value eating_plan___4_ 0='Unchecked' 1='Checked';
	value eating_plan___5_ 0='Unchecked' 1='Checked';
	value eating_plan___6_ 0='Unchecked' 1='Checked';
	value eating_plan___7_ 0='Unchecked' 1='Checked';
	value eating_plan___8_ 0='Unchecked' 1='Checked';
	value eating_plan___9_ 0='Unchecked' 1='Checked';
	value eating_plan___10_ 0='Unchecked' 1='Checked';
	value eating_plan___11_ 0='Unchecked' 1='Checked';
	value eating_plan___12_ 0='Unchecked' 1='Checked';
	value eating_plan___13_ 0='Unchecked' 1='Checked';
	value eating_plan___99_ 0='Unchecked' 1='Checked';
	value eating_habits_motivation_ 5='Strongly agree' 4='Somewhat agree' 
		3='Neither agree nor disagree' 2='Somewhat disagree' 
		1='Strongly disagree';
	value eating_habits_confidence_ 5='Strongly agree' 4='Somewhat agree' 
		3='Neither agree nor disagree' 2='Somewhat disagree' 
		1='Strongly disagree';
	value physical_activity_ 4='Excellent' 3='Good' 
		2='Fair' 1='Poor';
	value exercise_days_ 3='5 or more' 2='3-4' 
		1='1-2' 0='0';
	value exercise_intensity_ 3='Vigorous (jogging or running, bicycling fast, playing sports, strength training, etc.)' 2='Moderate (brisk walks, light bicycling, etc.)' 
		1='Light (light walks, standing work, etc.)';
	value device_activity_yn_ 1='Yes' 0='No';
	value device_activity___1_ 0='Unchecked' 1='Checked';
	value device_activity___2_ 0='Unchecked' 1='Checked';
	value device_activity___3_ 0='Unchecked' 1='Checked';
	value device_activity___4_ 0='Unchecked' 1='Checked';
	value device_activity___5_ 0='Unchecked' 1='Checked';
	value device_activity___99_ 0='Unchecked' 1='Checked';
	value device_exercise_yn_ 1='Yes' 0='No';
	value device_exercise___1_ 0='Unchecked' 1='Checked';
	value device_exercise___2_ 0='Unchecked' 1='Checked';
	value device_exercise___3_ 0='Unchecked' 1='Checked';
	value device_exercise___4_ 0='Unchecked' 1='Checked';
	value device_exercise___5_ 0='Unchecked' 1='Checked';
	value device_exercise___6_ 0='Unchecked' 1='Checked';
	value device_exercise___7_ 0='Unchecked' 1='Checked';
	value device_exercise___8_ 0='Unchecked' 1='Checked';
	value device_exercise___9_ 0='Unchecked' 1='Checked';
	value device_exercise___10_ 0='Unchecked' 1='Checked';
	value device_exercise___11_ 0='Unchecked' 1='Checked';
	value device_exercise___12_ 0='Unchecked' 1='Checked';
	value device_exercise___13_ 0='Unchecked' 1='Checked';
	value device_exercise___14_ 0='Unchecked' 1='Checked';
	value device_exercise___15_ 0='Unchecked' 1='Checked';
	value device_exercise___16_ 0='Unchecked' 1='Checked';
	value device_exercise___99_ 0='Unchecked' 1='Checked';
	value physical_activity_motivation_ 5='Strongly agree' 4='Somewhat agree' 
		3='Neither agree nor disagree' 2='Somewhat disagree' 
		1='Strongly disagree';
	value physical_activity_confidence_ 5='Strongly agree' 4='Somewhat agree' 
		3='Neither agree nor disagree' 2='Somewhat disagree' 
		1='Strongly disagree';
	value sleep_quality_ 4='Excellent' 3='Good' 
		2='Fair' 1='Poor';
	value sleep_rested_ 5='Strongly agree' 4='Somewhat agree' 
		3='Neither agree nor disagree' 2='Somewhat disagree' 
		1='Strongly disagree';
	value sleep_enough_ 5='Strongly agree' 4='Somewhat agree' 
		3='Neither agree nor disagree' 2='Somewhat disagree' 
		1='Strongly disagree';
	value sleep_wake_ 5='Strongly agree' 4='Somewhat agree' 
		3='Neither agree nor disagree' 2='Somewhat disagree' 
		1='Strongly disagree';
	value sleep_habits_ 4='Excellent' 3='Good' 
		2='Fair' 1='Poor';
	value device_sleep_yn_ 1='Yes' 0='No';
	value device_sleep___1_ 0='Unchecked' 1='Checked';
	value device_sleep___2_ 0='Unchecked' 1='Checked';
	value device_sleep___3_ 0='Unchecked' 1='Checked';
	value device_sleep___4_ 0='Unchecked' 1='Checked';
	value device_sleep___5_ 0='Unchecked' 1='Checked';
	value device_sleep___99_ 0='Unchecked' 1='Checked';
	value sleep_habits_motivation_ 5='Strongly agree' 4='Somewhat agree' 
		3='Neither agree nor disagree' 2='Somewhat disagree' 
		1='Strongly disagree';
	value sleep_habits_confidence_ 5='Strongly agree' 4='Somewhat agree' 
		3='Neither agree nor disagree' 2='Somewhat disagree' 
		1='Strongly disagree';
	value stress_level_ 1='Minimal' 2='Mild' 
		3='Moderate' 4='Significant' 
		5='Overwhelming';
	value mindful_skills_ 4='Excellent' 3='Good' 
		2='Fair' 1='Poor';
	value mindful_resilience_ 4='Excellent' 3='Good' 
		2='Fair' 1='Poor';
	value device_mindfulness_yn_ 1='Yes' 0='No';
	value device_mindfulness___1_ 0='Unchecked' 1='Checked';
	value device_mindfulness___2_ 0='Unchecked' 1='Checked';
	value device_mindfulness___3_ 0='Unchecked' 1='Checked';
	value device_mindfulness___4_ 0='Unchecked' 1='Checked';
	value device_mindfulness___5_ 0='Unchecked' 1='Checked';
	value device_mindfulness___6_ 0='Unchecked' 1='Checked';
	value device_mindfulness___99_ 0='Unchecked' 1='Checked';
	value mindfulness_motivation_ 5='Strongly agree' 4='Somewhat agree' 
		3='Neither agree nor disagree' 2='Somewhat disagree' 
		1='Strongly disagree';
	value mindfulness_confidence_ 5='Strongly agree' 4='Somewhat agree' 
		3='Neither agree nor disagree' 2='Somewhat disagree' 
		1='Strongly disagree';
	value week_drinks_ 0='0 days' 1='1-2 days' 
		2='3-4 days' 3='5 or more days';
	value smoking_ 0='Never' 1='Occasionally' 
		2='Weekly' 3='Daily';
	value fitbit_device_help_health_ 5='Strongly agree' 4='Somewhat agree' 
		3='Neither agree nor disagree' 2='Somewhat disagree' 
		1='Strongly disagree';
	value fitbit_premium_help_health_ 5='Strongly agree' 4='Somewhat agree' 
		3='Neither agree nor disagree' 2='Somewhat disagree' 
		1='Strongly disagree';
	value firbit_coaching_help_health_ 5='Strongly agree' 4='Somewhat agree' 
		3='Neither agree nor disagree' 2='Somewhat disagree' 
		1='Strongly disagree';
	value survey_complete_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	value infosheet_complete_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	value quest_scheduled_ 1='Yes' 0='No';
	value attended_ 1='Yes' 0='No';
	value gender_category_ 1='Gender Category 1' 2='Gender Category 2' 
		3='Gender Category 3';
	value age_category_ 1='Age Category 1' 2='Age Category 2';
	value eligibility_ 1='Eligible' 0='Not eligible';
	value eligible_no_ 1='No show' 2='No Smartphone' 
		3='No insurance' 4='Pregnant' 
		5='Under 18' 88='HR Deemed ineligibile';
	value study_arm_ 1='Intervention' 2='Control';
	value attended_12m_ 1='Yes' 0='No';
	value withdrawn_ 1='Yes' 0='No';
	value withdrawn_why_ 1='No show' 2='No Smartphone' 
		3='No insurance' 4='Pregnant' 
		5='Under 18' 6='Withdrew Consent' 
		88='Found to be ineligible later' 99='Other';
	value study_events_complete_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	value race_combf 1='White' 2='Black/African-American' 3='Asian' 
		4='Other';
    value posidf
	9 = 'Ambulance'
	11 = 'Doctor-s Office'
	12 = 'Patient-s Home'
	21 = 'Inpatient Hospital'
	22 = 'Outpatient Hospital'
	24 = 'Ambulatory Surgery Center'
	31 = 'SNF'
	81 = 'Indpendent Lab'
	99 = 'Unlisted'
	777 = 'Total+Rx'
	888 = 'Rx Total'
	999 = 'Total';
	run;
