libname dira 'C:\Users\saeeda1\OneDrive - UMass Chan Medical School\Documents\Disseration research\sas code\results paper\Data Final';

proc sort data=dira.fitbit out=sfit; by subject_id; run;
data temp_fitbit_long;
  set sfit; by subject_id;
  retain xid xarm;
  keep employee_id subject_id study_arm redcap_event_name study_month eating_habits_confidence eating_habits_motivation 
  			improve_health_confidence improve_health_motivation mindfulness_confidence mindfulness_motivation
			physical_activity_confidence physical_activity_motivation sleep_habits_confidence sleep_habits_motivation
			eating_habits eating_habits_drinks eating_habits_fruits eating_habits_grains 
			exercise_days exercise_intensity mindful_resilience mindful_skills overall physical_activity sleep_enough
			sleep_habits sleep_quality sleep_rested sleep_wake stress_level week_drinks survey_complete;
  if first.subject_id then do;
	xid = employee_id;
	xarm=study_arm;
	end;
    else if employee_id = . then do;
		employee_id = xid;
		study_arm = xarm;
	end;
			if redcap_event_name = 'baseline_arm_1' then study_month = 0;
			  else if redcap_event_name = '3_months_arm_1' then study_month = 3;
			  else if redcap_event_name = '6_months_arm_1' then study_month = 6;
			  else if redcap_event_name = '9_months_arm_1' then study_month = 9;
			  else if redcap_event_name = '12_months_arm_1' then study_month = 12; 
run;

data temp_fitbit_long_2;
  set temp_fitbit_long;
  if subject_id in ("1198", "1261", "1247", "169") then delete;
  if subject_id = "2" then employee_id = 37088;
  run;

proc print data=temp_fitbit_long_2;
  where employee_id in (10522, 52883, 59603, 81319);
  run cancel;

proc contents data=temp_fitbit_long_2;
  run;

  proc freq data=temp_fitbit_long_2;
    table study_month*study_arm;
	run;

options obs=20;
proc print data=temp_fitbit_long_2;
  where subject_id = "2" or subject_id = "29";
 var employee_id study_arm redcap_event_name study_month improve_health_motivation improve_health_confidence;
  run;
options obs=max;

proc sort data=temp_fitbit_long_2;
  by employee_id study_month;
  run;

data temp_fitbit_wide;
  set temp_fitbit_long_2; by employee_id;
  keep employee_id study_arm study_month  
			eating_habits_confidence_0 eating_habits_confidence_12
			eating_habits_motivation_0 eating_habits_motivation_12
  			improve_health_confidence_0 improve_health_confidence_12 
			improve_health_motivation_0 improve_health_motivation_12
			mindfulness_confidence_0 mindfulness_confidence_12
			mindfulness_motivation_0 mindfulness_motivation_12
			physical_activity_confidence_0 physical_activity_confidence_12
			physical_activity_motivation_0 physical_activity_motivation_12
			sleep_habits_confidence_0 sleep_habits_confidence_12
			sleep_habits_motivation_0 sleep_habits_motivation_12
			eating_habits_0 eating_habits_12 eating_habits_drinks_0 eating_habits_drinks_12
			eating_habits_fruits_0 eating_habits_fruits_12 eating_habits_grains_0 eating_habits_grains_12 
			exercise_days_0 exercise_days_12 exercise_intensity_0 exercise_intensity_12
			mindful_resilience_0 mindful_resilience_12 mindful_skills_0 mindful_skills_12 overall_0 overall_12
			physical_activity_0 physical_activity_12 sleep_enough_0 sleep_enough_12
			sleep_habits_0 sleep_habits_12 sleep_quality_0 sleep_quality_12 sleep_rested_0 sleep_rested_12
			sleep_wake_0 sleep_wake_12 stress_level_0 stress_level_12 week_drinks_0 week_drinks_12;
	retain employee_id study_month xarm
			eating_habits_confidence_0 eating_habits_confidence_12
			eating_habits_motivation_0 eating_habits_motivation_12
  			improve_health_confidence_0 improve_health_confidence_12 
			improve_health_motivation_0 improve_health_motivation_12
			mindfulness_confidence_0 mindfulness_confidence_12
			mindfulness_motivation_0 mindfulness_motivation_12
			physical_activity_confidence_0 physical_activity_confidence_12
			physical_activity_motivation_0 physical_activity_motivation_12
			sleep_habits_confidence_0 sleep_habits_confidence_12
			sleep_habits_motivation_0 sleep_habits_motivation_12
			eating_habits_0 eating_habits_12 eating_habits_drinks_0 eating_habits_drinks_12
			eating_habits_fruits_0 eating_habits_fruits_12 eating_habits_grains_0 eating_habits_grains_12 
			exercise_days_0 exercise_days_12 exercise_intensity_0 exercise_intensity_12
			mindful_resilience_0 mindful_resilience_12 mindful_skills_0 mindful_skills_12 overall_0 overall_12
			physical_activity_0 physical_activity_12 sleep_enough_0 sleep_enough_12
			sleep_habits_0 sleep_habits_12 sleep_quality_0 sleep_quality_12 sleep_rested_0 sleep_rested_12
			sleep_wake_0 sleep_wake_12 stress_level_0 stress_level_12 week_drinks_0 week_drinks_12;
  if first.employee_id then do;
  			xarm = study_arm;
			eating_habits_confidence_0=.; eating_habits_confidence_12=.;
			eating_habits_motivation_0=.; eating_habits_motivation_12=.;
  			improve_health_confidence_0=.; improve_health_confidence_12=.; 
			improve_health_motivation_0=.; improve_health_motivation_12=.;
			mindfulness_confidence_0=.; mindfulness_confidence_12=.;
			mindfulness_motivation_0=.; mindfulness_motivation_12=.;
			physical_activity_confidence_0=.; physical_activity_confidence_12=.;
			physical_activity_motivation_0=.; physical_activity_motivation_12=.;
			sleep_habits_confidence_0=.; sleep_habits_confidence_12=.;
			sleep_habits_motivation_0=.; sleep_habits_motivation_12=.;
			eating_habits_0=.; eating_habits_12 =.;
			eating_habits_drinks_0=.; eating_habits_drinks_12=.;
			eating_habits_fruits_0=.; eating_habits_fruits_12=.; 
			eating_habits_grains_0=.; eating_habits_grains_12=.; 
			exercise_days_0=.; exercise_days_12 =.;
			exercise_intensity_0=.; exercise_intensity_12=.;
			mindful_resilience_0=.; mindful_resilience_12=.; 
			mindful_skills_0=.; mindful_skills_12=.; 
			overall_0=.; overall_12=.;
			physical_activity_0=.; physical_activity_12=.; 
			sleep_enough_0=.; sleep_enough_12=.;
			sleep_habits_0=.; sleep_habits_12=.; 
			sleep_quality_0=.; sleep_quality_12=.; 
			sleep_rested_0=.; sleep_rested_12=.;
			sleep_wake_0=.; sleep_wake_12=.; 
			stress_level_0=.; stress_level_12=.; 
			week_drinks_0=.; week_drinks_12=.;
			end;
  if study_month = 0 then do;
			eating_habits_confidence_0 = eating_habits_confidence;
			eating_habits_motivation_0 = eating_habits_motivation;
  			improve_health_confidence_0 = improve_health_confidence;
			improve_health_motivation_0 = improve_health_motivation;
			mindfulness_confidence_0 = mindfulness_confidence;
			mindfulness_motivation_0 = mindfulness_motivation;
			physical_activity_confidence_0 = physical_activity_confidence;
			physical_activity_motivation_0 = physical_activity_motivation;
			sleep_habits_confidence_0 = sleep_habits_confidence;
			sleep_habits_motivation_0 = sleep_habits_motivation;
			eating_habits_0=eating_habits;
			eating_habits_drinks_0= eating_habits_drinks;
			eating_habits_fruits_0=eating_habits_fruits; 
			eating_habits_grains_0=eating_habits_grains; 
			exercise_days_0=exercise_days;
			exercise_intensity_0=exercise_intensity;
			mindful_resilience_0=mindful_resilience; 
			mindful_skills_0=mindful_skills; 
			overall_0=overall;
			physical_activity_0= physical_activity; 
			sleep_enough_0=sleep_enough;
			sleep_habits_0=sleep_habits; 
			sleep_quality_0=sleep_quality; 
			sleep_rested_0=sleep_rested;
			sleep_wake_0=sleep_wake; 
			stress_level_0=stress_level; 
			week_drinks_0=week_drinks;
			end;
   if study_month = 12 then do;
			eating_habits_confidence_12 = eating_habits_confidence;
			eating_habits_motivation_12 = eating_habits_motivation;
  			improve_health_confidence_12 = improve_health_confidence;
			improve_health_motivation_12 = improve_health_motivation;
			mindfulness_confidence_12 = mindfulness_confidence;
			mindfulness_motivation_12 = mindfulness_motivation;
			physical_activity_confidence_12 = physical_activity_confidence;
			physical_activity_motivation_12 = physical_activity_motivation;
			sleep_habits_confidence_12 = sleep_habits_confidence;
			sleep_habits_motivation_12 = sleep_habits_motivation;
			eating_habits_12=eating_habits;
			eating_habits_drinks_12= eating_habits_drinks;
			eating_habits_fruits_12=eating_habits_fruits; 
			eating_habits_grains_12=eating_habits_grains; 
			exercise_days_12=exercise_days;
			exercise_intensity_12=exercise_intensity;
			mindful_resilience_12=mindful_resilience; 
			mindful_skills_12=mindful_skills; 
			overall_12=overall;
			physical_activity_12= physical_activity; 
			sleep_enough_12=sleep_enough;
			sleep_habits_12=sleep_habits; 
			sleep_quality_12=sleep_quality; 
			sleep_rested_12=sleep_rested;
			sleep_wake_12=sleep_wake; 
			stress_level_12=stress_level; 
			week_drinks_12=week_drinks;
			end;
	if last.employee_id then do;
			study_arm = xarm;
			if study_arm ne . then output;
	end;
	format eating_habits_confidence_0 eating_habits_confidence_12 eating_habits_confidence_.
			eating_habits_motivation_0 eating_habits_motivation_12 eating_habits_motivation_.
  			improve_health_confidence_0 improve_health_confidence_12 improve_health_confidence_.
			improve_health_motivation_0 improve_health_motivation_12 improve_health_motivation_.
			mindfulness_confidence_0 mindfulness_confidence_12 mindfulness_confidence_.
			mindfulness_motivation_0 mindfulness_motivation_12 mindfulness_motivation_.
			physical_activity_confidence_0 physical_activity_confidence_12 physical_activity_confidence_.
			physical_activity_motivation_0 physical_activity_motivation_12 physical_activity_motivation_.
			sleep_habits_confidence_0 sleep_habits_confidence_12 sleep_habits_confidence_.
			sleep_habits_motivation_0 sleep_habits_motivation_12 sleep_habits_motivation_.
			eating_habits_0 eating_habits_12 eating_habits_.
			eating_habits_drinks_0 eating_habits_drinks_12 eating_habits_drinks_.
			eating_habits_fruits_0 eating_habits_fruits_12 eating_habits_fruits_. 
			eating_habits_grains_0 eating_habits_grains_12 eating_habits_grains_. 
			exercise_days_0 exercise_days_12 exercise_days_.
			exercise_intensity_0 exercise_intensity_12 exercise_intensity_.
			mindful_resilience_0 mindful_resilience_12 mindful_resilience_. 
			mindful_skills_0 mindful_skills_12 mindful_skills_. 
			overall_0 overall_12 overall_.
			physical_activity_0 physical_activity_12 physical_activity_. 
			sleep_enough_0 sleep_enough_12 sleep_enough_.
			sleep_habits_0 sleep_habits_12 sleep_habits_. 
			sleep_quality_0 sleep_quality_12 sleep_quality_. 
			sleep_rested_0 sleep_rested_12 sleep_rested_.
			sleep_wake_0 sleep_wake_12 sleep_wake_. 
			stress_level_0 stress_level_12 stress_level_. 
			week_drinks_0 week_drinks_12 week_drinks_.;
run;

options obs=20;
proc print data=temp_fitbit_wide;
  title 'Listing of FitBit Wide File';
  run;
options obs=max;

/* Start Area-Specific Shift Tables */

ods rtf style=journal file='D:\Documents\QHS\Bird Fitbit Project\eating_habits_shift.rtf';
proc freq data=temp_fitbit_wide;
  table study_arm*eating_habits_confidence_0*eating_habits_confidence_12
			study_arm*eating_habits_motivation_0*eating_habits_motivation_12
			study_arm*eating_habits_0*eating_habits_12 
			study_arm*eating_habits_drinks_0*eating_habits_drinks_12
			study_arm*eating_habits_fruits_0*eating_habits_fruits_12 
			study_arm*eating_habits_grains_0*eating_habits_grains_12
			study_arm*week_drinks_0*week_drinks_12 ;
Title 'Shift tables for Eating Habits Questions on Survey';
title2 'Baseline to 12 Month Shifts - Good/Bad responses';
format eating_habits_confidence_0 eating_habits_confidence_12
			eating_habits_motivation_0 eating_habits_motivation_12 response2f.
			eating_habits_0 eating_habits_12 response3f.
			eating_habits_drinks_0 eating_habits_drinks_12 response4f.
			eating_habits_fruits_0 eating_habits_fruits_12 response5f.
			eating_habits_grains_0 eating_habits_grains_12 response6f.
			week_drinks_0 week_drinks_12 drinks_0f.;

run;
ods rtf close;

/******************* create new table and test differences *******************************/
  /* add proc freq here and save statistics to merge with the info from the previous step */

/* maybe just pull numbers from output manually into a spreadsheet and then read the spreadsheet back in */
/* want for each treatment group, % 0 drinks at Month 0, % 0 drinks at Month 12, z-test for each */
/* then test differences of the diff */
/* logistic model? */

ods rtf style=journal file='D:\Documents\QHS\Bird Fitbit Project\physical_activity_habits_shift.rtf';
proc freq data=temp_fitbit_wide;
  table 	study_arm*physical_activity_confidence_0*physical_activity_confidence_12
			study_arm*physical_activity_motivation_0*physical_activity_motivation_12
			study_arm*physical_activity_0*physical_activity_12
			study_arm*exercise_days_0*exercise_days_12 
			study_arm*exercise_intensity_0*exercise_intensity_12;
Title 'Shift tables for Physical Activity Habits Questions on Survey';
title2 'Baseline to 12 Month Shifts - all levels of responses';
format physical_activity_confidence_0 physical_activity_confidence_12
			physical_activity_motivation_0 physical_activity_motivation_12 response2f.
			physical_activity_0 physical_activity_12 response3f.
			exercise_days_0 exercise_days_12 response6f.
			exercise_intensity_0 exercise_intensity_12 response7f.;
run;
ods rtf close;

ods rtf style=journal file='D:\Documents\QHS\Bird Fitbit Project\mindful_habits_shift.rtf';
proc freq data=temp_fitbit_wide;
  table study_arm*mindfulness_confidence_0*mindfulness_confidence_12
			study_arm*mindfulness_motivation_0*mindfulness_motivation_12
			study_arm*mindful_resilience_0*mindful_resilience_12 
			study_arm*mindful_skills_0*mindful_skills_12;
Title 'Shift tables for Mindfulness Habits Questions on Survey';
title2 'Baseline to 12 Month Shifts - all levels of responses';
format mindfulness_confidence_0 mindfulness_confidence_12
			mindfulness_motivation_0 mindfulness_motivation_12 response2f.
			mindful_resilience_0 mindful_resilience_12 
			mindful_skills_0 mindful_skills_12 response3f.; 
run;
ods rtf close;

ods rtf style=journal file='D:\Documents\QHS\Bird Fitbit Project\sleep_habits_shift.rtf';
proc freq data=temp_fitbit_wide;
  table 	study_arm*sleep_habits_confidence_0*sleep_habits_confidence_12
			study_arm*sleep_habits_motivation_0*sleep_habits_motivation_12
			study_arm*sleep_enough_0*sleep_enough_12
			study_arm*sleep_habits_0*sleep_habits_12
			study_arm*sleep_quality_0*sleep_quality_12 
			study_arm*sleep_rested_0*sleep_rested_12
			study_arm*sleep_wake_0*sleep_wake_12 ; 
Title 'Shift tables for Sleeping Habits and Overall Questions on Survey';
title2 'Baseline to 12 Month Shifts - all levels of responses';
format sleep_habits_confidence_0 sleep_habits_confidence_12
			sleep_habits_motivation_0 sleep_habits_motivation_12 response2f.
			sleep_enough_0 sleep_enough_12
			sleep_rested_0 sleep_rested_12 response2f.
			sleep_wake_0 sleep_wake_12 response2sleepf. 
			sleep_habits_0 sleep_habits_12
			sleep_quality_0 sleep_quality_12 response3f.;  
run;
ods rtf close;

ods rtf style=journal file='D:\Documents\QHS\Bird Fitbit Project\overall_health_shift.rtf';
proc freq data=temp_fitbit_wide;
  table 	study_arm*improve_health_confidence_0*improve_health_confidence_12 
			study_arm*improve_health_motivation_0*improve_health_motivation_12 
			study_arm*overall_0*overall_12 
			study_arm*stress_level_0*stress_level_12; 
			;
Title 'Shift tables for Overall Health Questions on Survey';
title2 'Baseline to 12 Month Shifts - all levels of responses';
format improve_health_confidence_0 improve_health_confidence_12 
			improve_health_motivation_0 improve_health_motivation_12 response2f.
			overall_0 overall_12 response3f.
			stress_level_0 stress_level_12 response8f.;
run;
ods rtf close;

/* Revision for Top Two Lines Analysis */


ods rtf style=journal file='D:\Documents\QHS\Bird Fitbit Project\survey_shift.rtf';
proc freq data=temp_fitbit_wide;
  table study_arm*eating_habits_confidence_0*eating_habits_confidence_12
			study_arm*eating_habits_motivation_0*eating_habits_motivation_12
  			study_arm*improve_health_confidence_0*improve_health_confidence_12 
			study_arm*improve_health_motivation_0*improve_health_motivation_12
			study_arm*mindfulness_confidence_0*mindfulness_confidence_12
			study_arm*mindfulness_motivation_0*mindfulness_motivation_12
			study_arm*physical_activity_confidence_0*physical_activity_confidence_12
			study_arm*physical_activity_motivation_0*physical_activity_motivation_12
			study_arm*sleep_habits_confidence_0*sleep_habits_confidence_12
			study_arm*sleep_habits_motivation_0*sleep_habits_motivation_12 / chisq;
Title 'Shift tables for Confidence and Motivation Questions on Survey';
title2 'Baseline to 12 Month Shifts - Consolidated Responses';
format eating_habits_confidence_0 eating_habits_confidence_12
			eating_habits_motivation_0 eating_habits_motivation_12
  			improve_health_confidence_0 improve_health_confidence_12 
			improve_health_motivation_0 improve_health_motivation_12
			mindfulness_confidence_0 mindfulness_confidence_12
			mindfulness_motivation_0 mindfulness_motivation_12
			physical_activity_confidence_0 physical_activity_confidence_12
			physical_activity_motivation_0 physical_activity_motivation_12
			sleep_habits_confidence_0 sleep_habits_confidence_12
			sleep_habits_motivation_0 sleep_habits_motivation_12 responsesf.;
run;
ods rtf close;


  /*** Formats for All REDCap Variables and Derived Variables ***/

 proc format;
  value age2f
  0 -44 = '<45'
  45-65 = '45-65'
  66-99 = '65+';
  value ethnicity2f 0='Not Hispanic/Latino' 1='Hispanic/Latino' 
		other=.;
	value gender2f 1='Male' 2='Female' other = .;
	value bmif 
	0-<18.5 = 'Underweight'
	18.5-<25.0 = 'Normal'
	25.0-<30.0 = 'Overweight'
	30.0-high = 'Obese';
	value waist_risk_catf
	1 = 'Low'
	2 = 'Medium'
	3 = 'High';
	value bp_risk_catf
	1 = 'Normal'
	2 = 'Elevated'
	3 = 'HTN Stage I'
	4 = 'HTN Stage II';
	value a1c_risk_catf
	1 = 'Normal'
	2 = 'Pre-diabetic'
	3 = 'Diabetic';
	value ldl_risk_catf
	1 = 'Desirable'
	2 = 'Above Desirable'
	3 = 'Borderline High'
	4 = 'High'
	5 = 'Very High';
	value hdl_risk_catf
	1 = 'Low - High Risk'
	2 = 'Low Desirable'
	3 = 'High Desirable';
	value tc_hdl_risk_catf
	1 = 'Very Low Risk'
	2 = 'Low Risk'
	3 = 'Average Risk'
	4 = 'Moderate Risk'
	5 = 'High Risk';
	value tc_risk_catf
	1 = 'Good risk'
	2 = 'Borderline high risk'
	3 = 'High risk';
	value num2f
	3-6 = '3+';

	value $redcap_event_name_ 'baseline_arm_1'='0Baseline' '3_months_arm_1'='3 Months' 
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

	/* Put new formats for Top Two Line Report here */

value responsesf
		1,2 = 'Disagree'
		3 = 'Neither'
		4,5 = 'Agree';
	value response2f
		1,2,3 = 'Not agree'
		4,5 = 'Agree';
	value response2sleepf
		1,2 = 'Disagree'
		3,4,5 = 'Not disagree';
	value response3f
	1,2 = 'Poor-Fair'
	3,4 = 'Good-Excellent';
	value response4f
	0 = 'None'
	1,2 = '1+ daily';
	value response5f
	0,1,2 = 'Low'
	3,4,5 = 'Good';
	value response6f
	0,1 = 'Low'
	2,3 = 'Good';
    value response7f
	1 = 'Low'
	2,3 = 'Good';
	value response8f
	1,2 = 'Low Stress'
	3,4,5 = 'Elevated Stress';
	value drinks_0f
	0 = '0 days'
	1,2,3 = '1+ days';

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
	value race2f 1 = 'White' 0='Other';
	value yesnof 0 = 'No' 1 = 'Yes';

	run;
