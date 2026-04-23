# Fitbit-trial
SAS-based analysis of a workplace digital health intervention (Fitbit Care), including behavioral survey outcomes, cardiometabolic risk modeling, and healthcare claims utilization.
# Overview

This repository contains a complete analytical workflow for evaluating a workplace digital health intervention using Fitbit-based engagement data.

The analysis integrates:

## Behavioral survey outcomes
## Clinical and cardiometabolic risk factors
## Healthcare utilization (claims data)

The goal is to assess how digital behavioral interventions impact health outcomes and healthcare use over time.

## Key Analyses
1. Behavioral Outcomes (Survey Data)
Long → wide data transformation
Baseline vs 12-month comparisons
Behavioral “shift tables” (improvement / decline)
Domains:
Physical activity
Sleep
Motivation & confidence
2. Cardiometabolic Risk & Biometrics
Integration of survey + clinical data
Risk score derivation (e.g., cardiovascular risk proxies)
Standardization (z-scores)
Longitudinal modeling (mixed models / repeated measures)
3. Healthcare Utilization (Claims Data)
Cost aggregation by place of service
Pre–post comparisons within individuals
Change-score analysis
Between-group comparisons (intervention vs control)

## Methods

- Descriptive statistics for baseline characteristics  
- Longitudinal comparisons (baseline vs follow-up)  
- Mixed-effects modeling for repeated measures  
- Cost and utilization analysis using claims data  


##  Data Availability

The datasets used in this project are not publicly available due to privacy and institutional restrictions.

However:
- All analysis code is fully reproducible
- Data structure and variable names are preserved in the scripts
- The workflow can be adapted to similar datasets
