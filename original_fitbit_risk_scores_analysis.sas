libname dira 'C:\Users\saeeda1\OneDrive - UMass Chan Medical School\Documents\Disseration research\sas code\results paper\Data Final';


proc contents data=dira.fhs_risk;
run;
proc contents data=dir.quest_fv_rand;
run;

data temp_bl;
	set dira.fhs_risk;
	start_exam = 0;
	if weight_bl ne . or tc_bl ne . then start_exam = 1;
	run;

data temp_fv;
  set dir.quest_fv_rand;
  final_exam = 0;
  if weight_fv ne . or tc_fv ne . then final_exam = 1;
  run;

proc sort data=temp_bl; by employee_id; run;
proc sort data=temp_fv; by employee_id; run;

data temp_exam (keep=employee_id study_arm tc_bl tc_fv weight_bl weight_fv start_exam final_exam);
  merge temp_bl temp_fv;
  by employee_id;
  run;

options obs=20;
* proc print data=temp_exam;
proc print data=dir.fhs_risk;
where employee_id = 11287 or employee_id = 37088;
format final_exam start_exam yesnof.;
run;
options obs=max;

proc freq data=temp_exam;
where study_arm ne .;
table final_exam*start_exam study_arm*final_exam*start_exam;
title 'Quest Results by Study Arm and Time';
format final_exam start_exam yesnof.;
run;


/* Table 1 T-Tests  - may need to rerun by gender */
options orientation=portrait;
ods rtf style=statistical file='D:\Documents\QHS\Bird Fitbit Project\biometric_rerun_11-27-2022.rtf';

proc ttest data=dir.quest_bl_rand plots=none;
  class study_arm;
  var bmi_bl sys_bl tc_bl height_bl weight_bl waist_bl dia_bl a1c_bl hdl_bl ldl_bl tc_hdl_bl ;
  title 'T-Tests of Biometric Measures at Baseline';
  run;

proc freq data=dir.quest_bl_rand;
  table study_arm*bmi_bl / chisq;
  title "BMI Category Frequency";
  format bmi_bl bmif.;
  run;

ods rtf close;

proc sort data=dira.fitbit out=sfit; by subject_id; run;
data temp_fitbit_long;
  set sfit; by subject_id;
  retain xid;
  keep employee_id subject_id study_arm redcap_event_name study_month eating_habits_confidence eating_habits_motivation 
  			improve_health_confidence improve_health_motivation mindfulness_confidence mindfulness_motivation
			physical_activity_confidence physical_activity_motivation sleep_habits_confidence sleep_habits_motivation;
  if first.subject_id then xid = employee_id;
    else if employee_id = . then employee_id = xid;
			if redcap_event_name = 'baseline_arm_1' then study_month = 0;
			  else if redcap_event_name = '3_months_arm_1' then study_month = 3;
			  else if redcap_event_name = '6_months_arm_1' then study_month = 6;
			  else if redcap_event_name = '9_months_arm_1' then study_month = 9;
			  else if redcap_event_name = '12_months_arm_1' then study_month = 12; 
run;

data temp_fitbit_long_2;
  set temp_fitbit_long;
  if subject_id in (1198, 1261, 1247, 169) then delete;
  if subject_id = "2" then employee_id = 37088;
  run;

proc print data=temp_fitbit_long_2;
  where employee_id in (10522, 52883, 59603, 81319);
  run;

proc contents data=temp_fitbit_long_2;
  run;

  proc freq data=temp_fitbit_long_2;
    table study_arm*redcap_event_name;
	run;

options obs=20;
proc print data=temp_fitbit_long;
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
			start_survey final_survey;
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
			start_survey final_survey;
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
			start_survey = 0; final_survey = 0;
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
			start_survey = 1;
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
			final_survey = 1;
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
			sleep_habits_motivation_0 sleep_habits_motivation_12 sleep_habits_motivation_.;
run;

options obs=20;
proc print data=temp_fitbit_wide;
  title 'Listing of FitBit Wide File';
  run;
options obs=max;

proc freq data = temp_fitbit_wide;
  table start_survey*final_survey study_arm*start_survey*final_survey;
  title 'Frequency of Start and Final Surveys';
  format start_survey final_survey yesnof.;
  run;

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
title2 'Baseline to 12 Month Shifts - all levels of responses';
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

/************ Baseline CVD Risk Score Calculations **************/

ods rtf style=statistical file='D:\Documents\QHS\Bird Fitbit Project\fhs_risk_score_model_final.rtf';
 options obs=max;
data fhs_risk_scores (keep=employee_id study_arm fhs_cvdrisk_bl gender hyperten_bl age tc_bl hdl_bl sys_bl 
											smoke_bl diabetes_bl fhs_cvdrisk_12 hyperten_12 tc_12 hdl_12 sys_12 smoke_12 diabetes_12
											fhs_cvdrisk_diff bmi_bl);
set dir.fhs_risk;
  if tc_12 ne . then do;
  	if smoke_12 = . and smoke_bl ne . then smoke_12 = smoke_bl;
	if diabetes_12 = . and diabetes_bl ne . then diabetes_12 = diabetes_bl;
	if hyperten_12 = . and hyperten_bl ne . then hyperten_12 = hyperten_bl;
 end;
  if gender = 1 then do; /* calculate scores for men */

  	if hyperten_bl = 1 then /* if report dx of hypertension, assume it is treated */

 	fhs_cvdrisk_bl = 1-0.88936**exp( (3.06117*log(age)) + (1.12370*log(tc_bl)) + (-0.93263*log(hdl_bl)) + 
								(1.99881*log(sys_bl)) + (0.65451*smoke_bl) + (0.57367*diabetes_bl) - 23.9802);

	if hyperten_bl = 0 then /* if do not report dx of hypertension, assume it is not treated */

 	fhs_cvdrisk_bl = 1-0.88936**exp( (3.06117*log(age)) + (1.12370*log(tc_bl)) + (-0.93263*log(hdl_bl)) + 
								(1.93303*log(sys_bl)) + (0.65451*smoke_bl) + (0.57367*diabetes_bl) - 23.9802);

	if hyperten_12 = 1 then /* if report dx of hypertension, assume it is treated */

 	fhs_cvdrisk_12 = 1-0.88936**exp( (3.06117*log(age+1)) + (1.12370*log(tc_12)) + (-0.93263*log(hdl_12)) + 
								(1.99881*log(sys_12)) + (0.65451*smoke_12) + (0.57367*diabetes_12) - 23.9802);

	if hyperten_12 = 0 then /* if do not report dx of hypertension, assume it is not treated */

 	fhs_cvdrisk_12 = 1-0.88936**exp( (3.06117*log(age+1)) + (1.12370*log(tc_12)) + (-0.93263*log(hdl_12)) + 
								(1.93303*log(sys_12)) + (0.65451*smoke_12) + (0.57367*diabetes_12) - 23.9802);

end;

if gender = 2 then do; /* calculate scores for women */

  	if hyperten_bl = 1 then /* if report dx of hypertension, assume it is treated */

 	fhs_cvdrisk_bl = 1-0.95012**exp( (2.32888*log(age)) + (1.20904*log(tc_bl)) + (-0.70833*log(hdl_bl)) + 
								(2.82263*log(sys_bl)) + (0.52873*smoke_bl) + (0.69154*diabetes_bl) - 26.1931);

	if hyperten_bl = 0 then /* if do not report dx of hypertension, assume it is not treated */

 	fhs_cvdrisk_bl = 1-0.95012**exp( (2.32888*log(age)) + (1.20904*log(tc_bl)) + (-0.70833*log(hdl_bl)) + 
								(2.76157*log(sys_bl)) + (0.52873*smoke_bl) + (0.69154*diabetes_bl) - 26.1931);

	if hyperten_12 = 1 then /* if report dx of hypertension, assume it is treated */

 	fhs_cvdrisk_12 = 1-0.95012**exp( (2.32888*log(age+1)) + (1.20904*log(tc_12)) + (-0.70833*log(hdl_12)) + 
								(2.82263*log(sys_12)) + (0.52873*smoke_12) + (0.69154*diabetes_12) - 26.1931);

	if hyperten_12 = 0 then /* if do not report dx of hypertension, assume it is not treated */

 	fhs_cvdrisk_12 = 1-0.95012**exp( (2.32888*log(age+1)) + (1.20904*log(tc_12)) + (-0.70833*log(hdl_12)) + 
								(2.76157*log(sys_12)) + (0.52873*smoke_12) + (0.69154*diabetes_12) - 26.1931);
end;

	fhs_cvdrisk_diff = fhs_cvdrisk_12 - fhs_cvdrisk_bl;
	label fhs_cvdrisk_diff = 'FHS CVD Risk Diff (FV-BL)'
			 fhs_cvdrisk_bl = 'FHS CVD Risk (BL)'
			 fhs_cvdrisk_12 = 'FHS CVD Risk (FV)';
run;

data templong (keep=employee_id study_arm gender age fhs_cvdrisk time);
	set fhs_risk_scores;
	length time $ 8;
	time = 'Baseline';
	fhs_cvdrisk = fhs_cvdrisk_bl;
	output;
	time='Month 12';
	fhs_cvdrisk = fhs_cvdrisk_12;
	output;
run;

proc means data=templong n mean min max stddev maxdec=5;
  class time study_arm ;
  var fhs_cvdrisk;
  title 'Means of FHS Risk Score by Time';
  format study_arm study_arm_.;
  run;

  proc ttest data=fhs_risk_scores;
    class study_arm;
	var fhs_cvdrisk_diff;
	run;

proc mixed data=templong plots=none;
  class time (ref='Baseline') gender age (ref='<45') study_arm (ref='Control') employee_id;
  model fhs_cvdrisk =study_arm time study_arm*time  / solution;
  repeated / subject=employee_id type=ar(1);
  lsmeans study_arm*time / diff;
  title 'Mixed Model for FHS Risk Score';
  format study_arm study_arm_. gender gender2f. age age2f.;
  run;

proc sgplot data=templong;
  vbox fhs_cvdrisk / category=study_arm group=time;
  yaxis min=0.0 max=0.5 minor label='FHS CVD Risk';
  title 'Box Plot of FHS CVD Risk at Baseline and Month 12 by Treatment Group';
  run;

options obs=25;
proc print data=fhs_risk_scores;
  var employee_id study_arm age gender fhs_cvdrisk_bl fhs_cvdrisk_12 fhs_cvdrisk_diff; 
  title 'Listing of FHS Risk Scores';
  run cancel;
options obs=max;

ods rtf close;

/* Data step to calculate Z-scores using NHANES Data (added manually) */

proc ttest data=fhs_risk_scores plots=none;
  class study_arm;
  var fhs_cvdrisk_diff;
  title 'FHS CVD Risk Score Difference by Treatment';
  run;

ods rtf close;

proc sgplot datga=fhs_risk_scores;
  vbox fhs_cvdrisk_diff / category=study_arm;
  title 'FHS CVD Risk Scores Difference by Treatment';
  run;

  /* Create Z-scores for biometric variables using NHANES gender-, age-, and race-specific means and standard deviations */

ods rtf style=statistical file='D:\Documents\QHS\Bird Fitbit Project\Z-score_model_final.rtf';

data temp_zscores;										
  set dir.fhs_risk;
  
if gender = 1 then do; 						 			/* male */
  if . < age <=50 then do; 								/* male, young */
	if race = 1 then do; 									/* male, young, white */
		m_a1c = 5.23; sd_a1c = 0.61;
		m_bmi = 29.66; sd_bmi = 10.63;
		m_dia = 75.45; sd_dia = 14.19;
		m_hdl = 48.59; sd_hdl = 13.78;
		m_ldl = 111.48; sd_ldl = 54.44;
		m_sys = 120.10; sd_sys = 13.35;
		m_tc = 187.30; sd_tc = 75.42;
		m_waist = 101.79; sd_waist = 26.81;
		m_weight = 93.53; sd_weight = 38.18;
		m_height = 177.29; sd_height = 9.63;
    end;
    else if race = 0 then  do; 							/* male, young, non-white */
		m_a1c = 5.46; sd_a1c = 1.43;
		m_bmi = 29.75; sd_bmi = 9.78;
		m_dia = 75.71; sd_dia = 13.17;
		m_hdl = 46.70; sd_hdl = 16.86;
		m_ldl = 114.63; sd_ldl = 49.10;
		m_sys = 121.80; sd_sys = 19.05;
		m_tc = 187.08; sd_tc = 41.02;
		m_waist = 99.61; sd_waist = 23.60;
		m_weight = 90.05; sd_weight = 30.22;
		m_height = 173.76; sd_height = 12.29;
	end;
  end;
  if 51 <= age then do;			 					/* male, old */
	if race = 1 then do; 								/* male, old, white */
		m_a1c = 5.92; sd_a1c = 2.19;
		m_bmi = 29.63; sd_bmi = 6.74;
		m_dia = 73.66; sd_dia = 15.39;
		m_hdl = 48.52; sd_hdl = 18.87;
		m_ldl = 105.54; sd_ldl = 60.38;
		m_sys = 127.58; sd_sys = 24.61;
		m_tc = 178.37; sd_tc = 72.95;
		m_waist = 106.84; sd_waist = 15.82;
		m_weight = 91.02; sd_weight = 22.57;
		m_height = 175.07; sd_height = 9.73;
	end;
    else if race = 0 then  do; 						/* male, old, non-white */
		m_a1c = 5.81; sd_a1c = 1.33;
		m_bmi = 29.20; sd_bmi = 8.41;
		m_dia = 75.81; sd_dia = 14.38;
		m_hdl = 49.96; sd_hdl = 19.14;
		m_ldl = 104.90; sd_ldl = 47.82;
		m_sys = 131.36; sd_sys = 23.23;
		m_tc = 181.35; sd_tc = 83.94;
		m_waist = 103.68; sd_waist = 23.06;
		m_weight = 86.39; sd_weight = 28.13;
		m_height = 171.62; sd_height = 12.54;
	end;
  end;
end; 															/* end of males */
if gender = 2 then do;  								/* female */
  if . < age <=50 then do; 							/* female, young */
	if race = 1 then do; 								/* female, young, white */
		m_a1c = 5.13; sd_a1c = 0.81;
		m_bmi = 29.90; sd_bmi = 12.47;
		m_dia = 71.57; sd_dia = 14.85;
		m_hdl = 58.16; sd_hdl = 20.08;
		m_ldl = 104.14; sd_ldl = 45.25;
		m_sys = 110.52; sd_sys = 17.04;
		m_tc = 185.14; sd_tc = 65.38;
		m_waist = 97.26; sd_waist = 28.84;
		m_weight = 80.74; sd_weight = 35.63;
		m_height = 164.25; sd_height = 7.24;
	end;
    else if race = 0 then  do; 						/* female, young, non-white */
		m_a1c = 5.26; sd_a1c = 1.41;
		m_bmi = 30.21; sd_bmi = 10.62;
		m_dia = 72.04; sd_dia = 15.30;
		m_hdl = 56.64; sd_hdl = 12.96;
		m_ldl = 105.86; sd_ldl = 50.62;
		m_sys = 111.47; sd_sys = 20.07;
		m_tc = 180.42; sd_tc = 57.58;
		m_waist = 96.12; sd_waist = 22.16;
		m_weight = 78.22; sd_weight = 27.56;
		m_height = 160.59; sd_height = 8.23;
	end;
   end;
  if 51 <= age then do;				 				/* female, old */
	if race = 1 then do; 								/* female, old, white */
		m_a1c = 5.43; sd_a1c = 1.02;
		m_bmi = 29.98; sd_bmi = 9.36;
		m_dia = 73.06; sd_dia = 15.69;
		m_hdl = 61.58; sd_hdl = 29.75;
		m_ldl = 115.72; sd_ldl = 54.14;
		m_sys = 127.91; sd_sys = 23.12;
		m_tc = 201.30; sd_tc = 49.92;
		m_waist = 100.93; sd_waist = 21.69;
		m_weight = 77.11; sd_weight = 24.68;
		m_height = 160.34; sd_height = 7.25;
	end;
    else if race = 0 then do; 							/* female, old, non-white */
		m_a1c = 5.71; sd_a1c = 1.24;
		m_bmi = 30.62; sd_bmi = 10.95;
		m_dia = 75.47; sd_dia = 14.10;
		m_hdl = 58.68; sd_hdl = 20.93;
		m_ldl = 116.43; sd_ldl = 51.83;
		m_sys = 132.60; sd_sys = 33.16;
		m_tc = 198.29; sd_tc = 61.56;
		m_waist = 100.13; sd_waist = 21.52;
		m_weight = 76.47; sd_weight = 30.37;
		m_height = 157.83; sd_height = 9.58;
	end;
   end;
  end;															 /* end of females */

waist_cm_bl = waist_bl * 2.54;				/* convert anthro measures from Quest to metric unit from NHANES */
height_cm_bl = height_bl * 2.54;
weight_kg_bl = weight_bl * 0.454;
waist_cm_12 = waist_12*2.54;
height_cm_12 = height_12*2.54;
weight_kg_12 = weight_12*0.454;

a1c_bl_z = (a1c_bl - m_a1c) / sd_a1c;		/* Calculate Z-scores for each biometric measure - Baseline */
bmi_bl_z = (bmi_bl - m_bmi) / sd_bmi;
dia_bl_z = (dia_bl - m_dia) / sd_dia;
hdl_bl_z = -1*(hdl_bl - m_hdl) / sd_hdl;
ldl_bl_z = (ldl_bl - m_ldl) / sd_ldl;
sys_bl_z = (sys_bl - m_sys) / sd_sys;
tc_bl_z = (tc_bl - m_tc) / sd_tc;
waist_bl_z = (waist_cm_bl - m_waist) / sd_waist;
weight_bl_z = (weight_kg_bl - m_weight) / sd_weight;
height_bl_z = (height_cm_bl - m_height) / sd_height;

z_score_bl = sum(bmi_bl_z, waist_bl_z, dia_bl_z, sys_bl_z, tc_bl_z,ldl_bl_z, hdl_bl_z,a1c_bl_z)/sqrt(8);

a1c_12_z = (a1c_12 - m_a1c) / sd_a1c;		/* Calculate Z-scores for each biometric measure - MN12 */
bmi_12_z = (bmi_12 - m_bmi) / sd_bmi;
dia_12_z = (dia_12 - m_dia) / sd_dia;
hdl_12_z = -1*(hdl_12 - m_hdl) / sd_hdl;
ldl_12_z = (ldl_12 - m_ldl) / sd_ldl;
sys_12_z = (sys_12 - m_sys) / sd_sys;
tc_12_z = (tc_12 - m_tc) / sd_tc;
waist_12_z = (waist_cm_12 - m_waist) / sd_waist;
weight_12_z = (weight_kg_12 - m_weight) / sd_weight;
height_12_z = (height_cm_12 - m_height) / sd_height;

z_score_12 = sum(bmi_12_z, waist_12_z, dia_12_z, sys_12_z, tc_12_z,ldl_12_z, hdl_12_z,a1c_12_z)/sqrt(8);

z_score_diff = z_score_12 - z_score_bl;
z_a1c_diff = a1c_12_z - a1c_bl_z;
z_bmi_diff = bmi_12_z - bmi_bl_z;
z_waist_diff = waist_12_z - waist_bl_z;
z_dia_diff = dia_12_z - dia_bl_z;
z_sys_diff = sys_12_z - sys_bl_z;
z_tc_diff = tc_12_z - tc_bl_z;
z_ldl_diff = ldl_12_z - ldl_bl_z;
z_hdl_diff = hdl_12_z - hdl_bl_z;

label z_score_bl = 'Summary Z-Score (BL)'
		 z_score_12 = 'Summary Z-Score (MN12)'
		 z_score_diff = 'Summary Z-Score (MN12-BL)';
run;

ods rtf style=statistical file='D:\Documents\QHS\Bird Fitbit Project\Z-score_biometric_details.rtf';
proc means data=temp_zscores maxdec=3;
  class study_arm;
  var z_score_bl z_score_12 bmi_bl_z bmi_12_z waist_bl_z waist_12_z dia_bl_z dia_12_z sys_bl_z sys_12_z tc_bl_z  tc_12_z 
				ldl_bl_z ldl_12_z hdl_bl_z  hdl_12_z a1c_bl_z a1c_12_z;
  title 'Means of BIometric Measures by Study Arm';
  run;

proc ttest data=temp_zscores plots=none;
  class study_arm;
  var z_score_diff z_a1c_diff z_bmi_diff z_waist_diff z_dia_diff z_sys_diff z_tc_diff z_ldl_diff z_hdl_diff;
  run;
ods rtf close;

options obs=25;
proc print data=temp_zscores;
  var employee_id study_arm gender age race a1c_z bmi_z dia_z hdl_z ldl_z sys_z tc_z waist_z weight_z height_z sum_z1 ;
  title 'Listing of Z-scores for First 25 Participants';
  format gender gender_. race race2f.;
  run cancel;
options obs=max;

data templong (keep=employee_id study_arm gender age z_score time);
	set temp_zscores;
	length time $ 8;
	time = 'Baseline';
	z_score = z_score_bl;
	output;
	time='Month 12';
	z_score = z_score_12;
	output;
run;

proc sgplot data=templong;
  vbox z_score / category=study_arm group=time;
  yaxis min=-3.0 max=4.0 minor label='Z-Score';
  title 'Box Plot of Composite Z-Score at Baseline and Month 12 by Treatment Group';
  title2 'Includes: BMI, Waist, Systolic BP, Diastolic BP, Total Cholesterol, LDL-C, HDL-C (inverted), and Hgb A1c';
  run;


proc means data=templong n mean stddev min max maxdec=5;
  class time study_arm ;
  var z_score;
  title 'Means of Z-Score by Time';
  format study_arm study_arm_.;
  run;

proc mixed data=templong plots=none;
  class time (ref='Baseline') gender age (ref='<45') study_arm (ref='Control') employee_id;
  model z_score =study_arm time study_arm*time / solution;
  repeated / subject=employee_id type=ar(1);
  lsmeans study_arm*time / diff;
  title 'Mixed Model for Z-Score';
  format study_arm study_arm_. gender gender2f. age age2f.;
  run;

ods rtf close;

/* Create Biometric Measure Specific Risk Strata */

ods rtf style=statistical file='D:\Documents\QHS\Bird Fitbit Project\clinical_risk_levelsl_final.rtf';

data clin_risk;
  set dir.fhs_risk;

  if waist_bl ne . then do; 		* create waist risk strata;
		waist_risk_bl = 1; 				* low risk by default;
		if gender = 1 then do; 	* male risk strata;
			if 37.0 <= waist_bl < 40.0 then waist_risk_bl = 2; * male medium risk;
			else if waist_bl >= 40.0 then waist_risk_bl = 3; 	   * male high risk;
		end;
		if gender = 2 then do;	* female risk strata;
			if 31.5 <= waist_bl < 35.0 then waist_risk_bl = 2;  *female medium risk;
			else if waist_bl >= 35.0 then waist_risk_bl = 3;      * female high risk;
		end;
	end;											* end of Waist Risk Loop;

	if sys_bl ne . and dia_bl ne . then do;  *create blood pressure risk strata;
		bp_risk_bl = 1;					* normal risk by default;
		if 120 <= sys_bl < 130 and dia_bl < 80 then bp_risk_bl = 2;  * elevated risk;
		else if 130 <= sys_bl < 140 or 80 <= dia_bl < 90 then bp_risk_bl = 3;  *HTN Stage I;
		else if sys_bl ge 140 or dia_bl ge 90 then bp_risk_bl = 4;  *HTN Stage II;
	end;											* end of BP Risk Loop;

	if a1c_bl ne . then do;		* create a1c risk strata;
		a1c_risk_bl = 1;					*normal risk by default;
		if 5.7 <= a1c_bl < 6.5 then a1c_risk_bl = 2;   * pre-diabetes risk;
		if a1c_bl ge 6.5 then a1c_risk_bl = 3;			  * diabetes;
	end;											* end of HgbA1c Risk Loop;

if tc_bl ne . then do;			* create Total Cholesterol Risk strata;
		tc_risk_bl = 1;						* good level by default;
		if 200 <= tc_bl <= 239 then tc_risk_bl = 2; * borderline high level;
		else if 240 <= tc_bl then tc_risk_bl = 3;  * high level;
end;											* end of TC Risk Loop;

if ldl_bl ne . then do;			* create LDL Risk strata;
		ldl_risk_bl = 1;						* desirable level by default;
		if 100 <= ldl_bl < 130 then ldl_risk_bl = 2; * above desirable level;
		else if 130 <= ldl_bl < 160 then ldl_risk_bl = 3;  * Borderline high level;
		else if 160 <= ldl_bl < 190 then ldl_risk_bl = 4;  * High level;
		else if ldl_bl ge 190 then ldl_risk_bl = 5;				* Very High level;
	end;											* end of LDL Risk Loop;

	if hdl_bl ne . then do;			* create HDL risk strata;
		hdl_risk_bl = 1;					* Low HDL by default;
		if gender = 1 then do;	* Male HDL risk strata;
			if 40 <= hdl_bl < 60 then hdl_risk_bl = 2;  * Desirable level;
			else if hdl_bl ge 60 then hdl_risk_bl = 3;   *High level;
		end;									* end of Male HDL Risk Loop;
		if gender = 2 then do;	*Female HDL risk strata;
			if 50 <= hdl_bl < 60 then hdl_risk_bl = 2;  *Desirable level;
			else if hdl_bl ge 60 then hdl_risk_bl = 3;	  *High level;
		end;									* end of Female HDL Risk Loop;
	end;										* end of HDL Risk Loop;

num_risk_bl = .;
if waist_risk_bl ne . then num_risk_bl = 0;
if waist_risk_bl gt 1 then num_risk_bl + 1;
if bp_risk_bl gt 1 then num_risk_bl + 1;
if a1c_risk_bl gt 1 then num_risk_bl + 1;
if ldl_risk_bl ge 3 then num_risk_bl + 1;
if hdl_risk_bl eq 1 then num_risk_bl + 1;
if tc_risk_bl ge 2 then num_risk_bl + 1;

/*************************** Run Clinical Risks for Month 12 ****************************/

  if waist_12 ne . then do; 		* create waist risk strata;
		waist_risk_12 = 1; 				* low risk by default;
		if gender = 1 then do; 	* male risk strata;
			if 37.0 <= waist_12 < 40.0 then waist_risk_12 = 2; * male medium risk;
			else if waist_12 >= 40.0 then waist_risk_12 = 3; 	   * male high risk;
		end;
		if gender = 2 then do;	* female risk strata;
			if 31.5 <= waist_12 < 35.0 then waist_risk_12 = 2;  *female medium risk;
			else if waist_12 >= 35.0 then waist_risk_12 = 3;      * female high risk;
		end;
	end;											* end of Waist Risk Loop;

	if sys_12 ne . and dia_12 ne . then do;  *create blood pressure risk strata;
		bp_risk_12 = 1;					* normal risk by default;
		if 120 <= sys_12 < 130 and dia_12 < 80 then bp_risk_12 = 2;  * elevated risk;
		else if 130 <= sys_12 < 140 or 80 <= dia_12 < 90 then bp_risk_12 = 3;  *HTN Stage I;
		else if sys_12 ge 140 or dia_12 ge 90 then bp_risk_12 = 4;  *HTN Stage II;
	end;											* end of BP Risk Loop;

	if a1c_12 ne . then do;		* create a1c risk strata;
		a1c_risk_12 = 1;					*normal risk by default;
		if 5.7 <= a1c_12 < 6.5 then a1c_risk_12 = 2;   * pre-diabetes risk;
		if a1c_12 ge 6.5 then a1c_risk_12 = 3;			  * diabetes;
	end;											* end of HgbA1c Risk Loop;

if tc_12 ne . then do;			* create Total Cholesterol Risk strata;
		tc_risk_12 = 1;						* good level by default;
		if 200 <= tc_12 <= 239 then tc_risk_12 = 2; * borderline high level;
		else if 240 <= tc_12 then tc_risk_12 = 3;  * high level;
end;											* end of TC Risk Loop;

if ldl_12 ne . then do;			* create LDL Risk strata;
		ldl_risk_12 = 1;						* desirable level by default;
		if 100 <= ldl_12 < 130 then ldl_risk_12 = 2; * above desirable level;
		else if 130 <= ldl_12 < 160 then ldl_risk_12 = 3;  * Borderline high level;
		else if 160 <= ldl_12 < 190 then ldl_risk_12 = 4;  * High level;
		else if ldl_12 ge 190 then ldl_risk_12 = 5;				* Very High level;
	end;											* end of LDL Risk Loop;

	if hdl_12 ne . then do;			* create HDL risk strata;
		hdl_risk_12 = 1;					* Low HDL by default;
		if gender = 1 then do;	* Male HDL risk strata;
			if 40 <= hdl_12 < 60 then hdl_risk_12 = 2;  * Desirable level;
			else if hdl_12 ge 60 then hdl_risk_12 = 3;   *High level;
		end;									* end of Male HDL Risk Loop;
		if gender = 2 then do;	*Female HDL risk strata;
			if 50 <= hdl_12 < 60 then hdl_risk_12 = 2;  *Desirable level;
			else if hdl_12 ge 60 then hdl_risk_12 = 3;	  *High level;
		end;									* end of Female HDL Risk Loop;
	end;										* end of HDL Risk Loop;

num_risk_12 = .;
if waist_risk_12 ne . then num_risk_12 = 0;
if waist_risk_12 gt 1 then num_risk_12 + 1;
if bp_risk_12 gt 1 then num_risk_12 + 1;
if a1c_risk_12 gt 1 then num_risk_12 + 1;
if ldl_risk_12 ge 3 then num_risk_12 + 1;
if hdl_risk_12 eq 1 then num_risk_12 + 1;
if tc_risk_12 ge 2 then num_risk_12 + 1;

format waist_risk_bl waist_risk_12 waist_risk_catf. bp_risk_bl bp_risk_12 bp_risk_catf. a1c_risk_bl a1c_risk_12 a1c_risk_catf.
			ldl_risk_bl ldl_risk_12 ldl_risk_catf. hdl_risk_bl hdl_risk_12 hdl_risk_catf. tc_risk_bl tc_risk_12 tc_risk_catf. 
			num_risk_bl num_risk_12 num2f.;
run;

options obs=25;
proc print data=clin_risk;
  var employee_id gender num_risk waist_bl waist_risk sys_bl dia_bl bp_risk a1c_bl a1c_risk ldl_bl ldl_risk hdl_bl hdl_risk 
  		tc_hdl_bl tc_hdl_risk;
  title 'QC of Risk Strata';
  run cancel;
options obs=max;

proc freq data=clin_risk;
  table study_arm*waist_risk_bl*waist_risk_12  study_arm*bp_risk_bl*bp_risk_12 study_arm*a1c_risk_bl*a1c_risk_12 
			study_arm*ldl_risk_bl*ldl_risk_12 study_arm*hdl_risk_bl*hdl_risk_12 study_arm*tc_risk_bl*tc_risk_12 
			study_arm*num_risk_bl*num_risk_12 / cmh;
  title 'Risk Levels  for Table 1';
  format waist_risk_bl waist_risk_12 waist_risk_catf. bp_risk_bl bp_risk_12 bp_risk_catf. a1c_risk_bl a1c_risk_12 a1c_risk_catf.
			ldl_risk_bl ldl_risk_12 ldl_risk_catf. hdl_risk_bl hdl_risk_12 hdl_risk_catf. tc_risk_bl tc_risk_12 tc_risk_catf. 
			num_risk_bl num_risk_12 num2f.;
  run;
ods rtf close;

proc sort data=clin_risk; by employee_id; run;
proc sort data=temp_zscores; by employee_id; run;

data waist_comb;
  merge clin_risk temp_zscores;
  by employee_id;
  run;

data clin_risk_long (keep=employee_id study_arm waist time);
	set clin_risk;
	length time $ 8;
	time = 'Baseline';
	waist = waist_risk_bl;
	output;
	time='Month 12';
	waist = waist_risk_12;
	output;
run;

proc sgplot data=waist_comb;
  vbar waist_risk_bl / group = study_arm groupdisplay=cluster stat=mean response=/*waist_12_z*/ z_waist_diff;
  yaxis min=-0.5 max=0.5 minor;
  refline 0;
  title 'Waist Difference Z-Score at 12 months by Basline Waist Risk and Treatment';
  label waist_risk_bl = 'Baseline Waist Risk'
  			waist_12_z = 'Month 12 Waist Z-Score'
			z_waist_diff = 'Waist Difference Z-Score';
  format waist_risk_bl waist_risk_catf.;
  run;

  

ods rtf style=statistical file='D:\Documents\QHS\Bird Fitbit Project\correlations_baseline.rtf';
proc corr data=dir.fhs_risk pearson spearman;
  title 'Peason and Spearman Correlations for Biometric Data';
  var age a1c_bl bmi_bl dia_bl hdl_bl ldl_bl sys_bl tc_bl waist_bl weight_bl height_bl;
  with a1c_12 bmi_12 dia_12 hdl_12 ldl_12 sys_12 tc_12 waist_12 weight_12 height_12;
  run;
ods rtf close;

ods rtf style=statistical file='D:\Documents\QHS\Bird Fitbit Project\summary z-scores tests Table 1.rtf';
proc ttest data=temp_zscores plots=none;
  class study_arm;
  var z_score1 z_score2 z_score3 z_score4 z_score5 z_score6;;
  title 'Test of Summary Z-scores for Table 1';
  run;
ods rtf close;

/* calculate ASCVD Risk Scores Using Table A from Goff (Circulation, 2014) paper */

ods rtf style=statistical file='D:\Documents\QHS\Bird Fitbit Project\ascvd_risk_score_model_final.rtf';

data ascvd_risk_scores (keep=employee_id study_arm ascvd_score_bl ascvd_score_12 ascvd_score_diff);
  set dir.fhs_risk;

 /* test data;

  age = 55;
  tc_bl = 213;
  hdl_bl = 50;
  hyperten_bl = 0;
  sys_bl = 120;
  smoke_bl = 0;
  diabetes_bl = 0;
  gender = 1;
  race = 0;
*/

   if tc_12 ne . then do;
  	if smoke_12 = . and smoke_bl ne . then smoke_12 = smoke_bl;
	if diabetes_12 = . and diabetes_bl ne . then diabetes_12 = diabetes_bl;
	if hyperten_12 = . and hyperten_bl ne . then hyperten_12 = hyperten_bl;
 end;

  lnage = log(age);
  lntc = log(tc_bl);
  lnhdl = log(hdl_bl);
  if hyperten_bl = 1 then do; * hypertension reported - assume treated;
		lntsys = log(sys_bl);
		lnuntsys = 0;
  end;
  if hyperten_bl = 0 then do; * no hypertension reported - assume untreated;  
  		lntsys = 0;
		lnuntsys = log(sys_bl);
  end;
  smoke = 0;
  if smoke_bl ge 1 then smoke = 1;

  if gender = 1 then do; * Male risk scores;
  	if race = 1 then do; 	* Male, white risk scores;

	  ascvd_mean = 61.18;
	  base_surv = 0.9144;
	  ascvd_sum = (12.344*lnage) + (11.853*lntc) + (-2.664*lnage*lntc) + (-7.990*lnhdl) + (1.769*lnage*lnhdl) +
	  				(1.797*lntsys) + (1.764*lnuntsys) + (7.837*smoke) + (-1.795*lnage*smoke) + (0.658*diabetes_bl);
	end;
	if race = 0 then do; * Male, non-white;

	  ascvd_mean = 19.54;
	  base_surv = 0.8954;
	  ascvd_sum = (2.469*lnage) + (0.302*lntc) + (-0.307*lnhdl) +
	  				(1.916*lntsys) + (1.809*lnuntsys) + (0.549*smoke) +
					(0.645*diabetes_bl);
	end;
  end;

  if gender = 2 then do; * Female risk scores;
  	if race = 1 then do; 	* Female, white risk scores;

	  ascvd_mean = -29.18;
	  base_surv = 0.9665;
	  ascvd_sum = (-29.799*lnage) + (4.884*lnage**2) + (13.540*lntc) + (-3.114*lnage*lntc) + (-13.578*lnhdl) + (3.149*lnage*lnhdl) +
	  				(2.019*lntsys) + (1.957*lnuntsys) + (7.574*smoke) + (-1.665*lnage*smoke) + (0.661*diabetes_bl);
	end;
	if race = 0 then do; * Female, non-white;

	  ascvd_mean = 86.61;
	  base_surv = 0.9533;
	  ascvd_sum = (17.114*lnage) + (0.940*lntc) + (-18.920*lnhdl) + (4.475*lnage*lnhdl) +
	  				(29.291*lntsys) + (-6.432*lnage*lntsys) + (27.820*lnuntsys) + (-6.087*lnage*lnuntsys) + (0.691*smoke) +
					(0.874*diabetes_bl);
	end;
  end;

  ediff = exp(ascvd_sum - ascvd_mean);
  ascvd_score_bl = 1-(base_surv**ediff);

  /*************** Run the 12-month ASCVD Score *********************/

  lnage = log(age+1);
  lntc = log(tc_12);
  lnhdl = log(hdl_12);
  if hyperten_12 = 1 then do; * hypertension reported - assume treated;
		lntsys = log(sys_12);
		lnuntsys = 0;
  end;
  if hyperten_12 = 0 then do; * no hypertension reported - assume untreated;  
  		lntsys = 0;
		lnuntsys = log(sys_12);
  end;
  smoke = 0;
  if smoke_12 ge 1 then smoke = 1;

  if gender = 1 then do; * Male risk scores;
  	if race = 1 then do; 	* Male, white risk scores;

	  ascvd_mean = 61.18;
	  base_surv = 0.9144;
	  ascvd_sum = (12.344*lnage) + (11.853*lntc) + (-2.664*lnage*lntc) + (-7.990*lnhdl) + (1.769*lnage*lnhdl) +
	  				(1.797*lntsys) + (1.764*lnuntsys) + (7.837*smoke) + (-1.795*lnage*smoke) + (0.658*diabetes_12);
	end;
	if race = 0 then do; * Male, non-white;

	  ascvd_mean = 19.54;
	  base_surv = 0.8954;
	  ascvd_sum = (2.469*lnage) + (0.302*lntc) + (-0.307*lnhdl) +
	  				(1.916*lntsys) + (1.809*lnuntsys) + (0.549*smoke) +
					(0.645*diabetes_12);
	end;
  end;

  if gender = 2 then do; * Female risk scores;
  	if race = 1 then do; 	* Female, white risk scores;

	  ascvd_mean = -29.18;
	  base_surv = 0.9665;
	  ascvd_sum = (-29.799*lnage) + (4.884*lnage**2) + (13.540*lntc) + (-3.114*lnage*lntc) + (-13.578*lnhdl) + (3.149*lnage*lnhdl) +
	  				(2.019*lntsys) + (1.957*lnuntsys) + (7.574*smoke) + (-1.665*lnage*smoke) + (0.661*diabetes_12);
	end;
	if race = 0 then do; * Female, non-white;

	  ascvd_mean = 86.61;
	  base_surv = 0.9533;
	  ascvd_sum = (17.114*lnage) + (0.940*lntc) + (-18.920*lnhdl) + (4.475*lnage*lnhdl) +
	  				(29.291*lntsys) + (-6.432*lnage*lntsys) + (27.820*lnuntsys) + (-6.087*lnage*lnuntsys) + (0.691*smoke) +
					(0.874*diabetes_12);
	end;
  end;

  ediff = exp(ascvd_sum - ascvd_mean);
  ascvd_score_12 = 1-(base_surv**ediff);
  ascvd_score_diff = ascvd_score_12 - ascvd_score_bl;

run;

proc print data=ascvd_risk_scores;
  var ascvd_score ascvd_sum ascvd_mean gender race;;
run cancel;

proc ttest data=ascvd_risk_scores;
  class study_arm;
  var ascvd_score_diff;
  run;

data templong;
  set ascvd_risk_scores;
  length time $ 8;
  label ascvd_score = 'ASCVD Risk Score';
  time = 'Baseline';
  ascvd_score = ascvd_score_bl;
  output;
  time = 'Month 12';
  ascvd_score = ascvd_score_12;
  output;
  run;

proc means data=templong;
  class time study_arm;
  var ascvd_score;
  title 'ASCVD Risk Scores by Study Arm and Time';
  run;

proc sgplot data=templong;
  vbox ascvd_score / category=study_arm group=time;
  yaxis min=0.0 max=0.25 minor label='ASCVD CVD Risk';
  title 'Box Plot of ASCVD Hard CVD Risk at Baseline and Month 12 by Treatment Group';
  run;


proc mixed data=templong plots=none;
  class time (ref='Baseline') study_arm (ref='Control') employee_id;
  model ascvd_score =study_arm time study_arm*time / solution;
  repeated / subject=employee_id type=ar(1);
  lsmeans study_arm*time / diff;
  title 'Mixed Model for ASCVD Score';
  format study_arm study_arm_. gender gender2f. age age2f.;
  run;

ods rtf close;

/* Box plots for z-scores */

proc sgplot data=temp_zscores;
  vbox z_score1 / category=study_arm;
  yaxis min=-3.0 max=3.0 label='Z-Scores';
  title 'Box Plot of Sum of Baseline Z-Score 1 (Table 1) across 6 Measures';
  title2 'Measures: BMI, Waist, DBP, SBP, HDL-C, LDL-C';
  run;

  proc sgplot data=temp_zscores;
  vbox z_score2 / category=study_arm;
  yaxis min=-3.0 max=3.0 label='Z-Scores';
  title 'Box Plot of Sum of Baseline Z-Score 2 (Table 1) across 7 Measures';
  title2 'Measures: BMI, Waist, DBP, SBP, Total Cholesterol, HDL-C, LDL-C';
  run;

proc sgplot data=temp_zscores;
  vbox z_score3 / category=study_arm;
  yaxis min=-3.0 max=3.0 label='Z-Scores';
  title 'Box Plot of Sum of Baseline Z-Score 3 (Table 1) across 8 Measures';
  title2 'Measures: BMI, Waist, Weight, DBP, SBP, Total Cholesterol, HDL-C, LDL-C';
  run;

proc sgplot data=temp_zscores;
  vbox z_score4 / category=study_arm;
  yaxis min=-3.0 max=3.0 label='Z-Scores';
  title 'Box Plot of Sum of Baseline Z-Score 4 (Table 1) across 9 Measures';
  title2 'Measures: BMI, Waist, Weight, DBP, SBP, Total Cholesterol, HDL-C, LDL-C, A1c';
  run;

proc sgplot data=temp_zscores;
  vbox z_score5 / category=study_arm;
  yaxis min=-3.0 max=3.0 label='Z-Scores';
  title 'Box Plot of Sum of Baseline Z-Score 5 (Table 1) across 7 Measures';
  title2 'Measures: BMI, Waist, DBP, SBP, HDL-C, LDL-C, A1c';
  run;

proc sgplot data=temp_zscores;
  vbox z_score6 / category=study_arm;
  yaxis min=-3.0 max=3.0 label='Z-Scores';
  title 'Box Plot of Sum of Baseline Z-Score 6 (Table 1) across 8 Measures';
  title2 'Measures: BMI, Waist, SBP, DBP, Total Cholesterol, HDL-C, LDL-C, A1c';
  run;

proc sgplot data=temp_zscores;
  vbox bmi_z / category=study_arm;
  yaxis min=-3.0 max=3.0 label='Z-Scores';
  title 'Box Plot of Baseline BMI Z-Scores by Treatment';
  run;

proc sgplot data=temp_zscores;
  vbox waist_z / category=study_arm;
  yaxis min=-3.0 max=3.0 label='Z-Scores';
  title 'Box Plot of Baseline Waist Z-Scores by Treatment';
  run;
  
proc sgplot data=temp_zscores;
  vbox weight_z / category=study_arm;
  yaxis min=-3.0 max=3.0 label='Z-Scores';
  title 'Box Plot of Baseline Weight Z-Scores by Treatment';
  run;

proc sgplot data=temp_zscores;
  vbox height_z / category=study_arm;
  yaxis min=-3.0 max=3.0 label='Z-Scores';
  title 'Box Plot of Baseline Height Z-Scores by Treatment';
  run;

proc sgplot data=temp_zscores;
  vbox sys_z / category=study_arm;
  yaxis min=-3.0 max=3.0 label='Z-Scores';
  title 'Box Plot of Baseline Systolic BP Z-Scores by Treatment';
  run;
  
proc sgplot data=temp_zscores;
  vbox dia_z / category=study_arm;
  yaxis min=-3.0 max=3.0 label='Z-Scores';
  title 'Box Plot of Baseline Diastolic BP Z-Scores by Treatment';
  run;

proc sgplot data=temp_zscores;
  vbox tc_z / category=study_arm;
  yaxis min=-3.0 max=3.0 label='Z-Scores';
  title 'Box Plot of Baseline Total Cholesterol Z-Scores by Treatment';
  run;
  
proc sgplot data=temp_zscores;
  vbox hdl_z / category=study_arm;
  yaxis min=-3.0 max=3.0 label='Z-Scores';
  title 'Box Plot of Baseline HDL-C Z-Scores by Treatment';
  run;
  
proc sgplot data=temp_zscores;
  vbox ldl_z / category=study_arm;
  yaxis min=-3.0 max=3.0 label='Z-Scores';
  title 'Box Plot of Baseline LDL-C Z-Scores by Treatment';
  run;

proc sgplot data=temp_zscores;
  vbox A1c_z / category=study_arm;
  yaxis min=-3.0 max=3.0 label='Z-Scores';
  title 'Box Plot of Baseline A1c Z-Scores by Treatment';
  run;

proc univariate data=temp_zscores;
  var sum_z1 sum_z2;
  title 'Univariate Statistics for Summary Z-Score';
  run;

/* Merge all files to create one analytic file */

  proc sort data=fhs_risk_scores; by employee_id; run;
  proc sort data=temp_zscores; by employee_id; run;
  proc sort data=clin_risk; by employee_id; run;
  proc sort data=ascvd_risk_scores; by employee_id; run;
  proc sort data=temp_fitbit_wide; by employee_id; run;

  data dira.fitbit_risk_scores;
    merge temp_fitbit_wide (in=in1) fhs_risk_scores(in=in2) temp_zscores(in=in3) clin_risk(in=in4) ascvd_risk_scores(in=in5);
	by employee_id;
	run;

proc contents daga=dira.fitbit_risk_scores;
  title 'Contents of Merged FitBIt and Risk Scores Datasets';
  run;

proc means data=dira.fitbit_risk_scores;
  title 'Overall Statistics';
  run;

proc sort data=dira.fitbit_risk_scores out=sfitbit; by study_arm; run;

options orientation=landscape;
ods rtf style=journal file='D:\Documents\QHS\Bird Fitbit Project\correlations_ranked.rtf';

proc corr data=sfitbit nosimple spearman rank best=10;
  by study_arm;
  var eating_habits_confidence_0 eating_habits_confidence_12
			eating_habits_motivation_0 eating_habits_motivation_12
  			improve_health_confidence_0 improve_health_confidence_12 
			improve_health_motivation_0 improve_health_motivation_12
			mindfulness_confidence_0 mindfulness_confidence_12
			mindfulness_motivation_0 mindfulness_motivation_12
			physical_activity_confidence_0 physical_activity_confidence_12
			physical_activity_motivation_0 physical_activity_motivation_12
			sleep_habits_confidence_0 sleep_habits_confidence_12
			sleep_habits_motivation_0 sleep_habits_motivation_12;
	with fhs_cvdrisk_diff fhs_cvdrisk_12 fhs_cvdrisk_bl 
			z_score_diff z_score_12 z_score_bl 
			z_a1c_diff a1c_12_z a1c_bl_z
			z_bmi_diff bmi_12_z bmi_bl_z
			z_waist_diff waist_12_z waist_bl_z
			z_dia_diff dia_12_z dia_bl_z
			z_sys_diff sys_12_z sys_bl_z
			z_tc_diff tc_12_z tc_bl_z
			z_ldl_diff ldl_12_z ldl_bl_z
			z_hdl_diff hdl_12_z hdl_bl_z
			waist_risk_bl waist_risk_12 bp_risk_bl bp_risk_12 a1c_risk_bl a1c_risk_12 
			ldl_risk_bl ldl_risk_12 hdl_risk_bl hdl_risk_12 tc_risk_bl tc_risk_12
			num_risk_bl num_risk_12
			ascvd_score_bl ascvd_score_12 ascvd_score_diff;
	title 'Correlation Matrix for Motivation/Confidence Variables by Risk Scores';
	run;
ods rtf close;

	options obs=20;
	proc print data=pearson_out;
	title 'Listing of Pearson Correlations File';
	run;
	options obs=max;

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
	value responsesf
		1,2 = 'Disagree'
		3 = 'Neither'
		4,5 = 'Agree';
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
