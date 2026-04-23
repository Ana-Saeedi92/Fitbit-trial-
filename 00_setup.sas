/*===========================================================
  Setup file for Fitbit SAS analyses
===========================================================*/
options dlcreatedir;

%let project_root = .;
%let data_dir = &project_root./data;
%let out_dir  = &project_root./results/tables;

libname dira  "&data_dir.";
libname dir   "&data_dir.";
libname dirdd "&data_dir.";

%put NOTE: project_root = &project_root.;
%put NOTE: data_dir     = &data_dir.;
%put NOTE: out_dir      = &out_dir.;
