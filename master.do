clear all
cap log close
set more off
macro drop all
set mem 5000m
set maxvar 20000
set matsize 11000


cap cd "C:\Users\adavis3\OneDrive - International Monetary Fund (PRD)\P2\Stata"

global p2_dir "C:\Users\adavis3\P2"
global p2_datadir "C:\Users\adavis3\P2\Data"
global p2_codedir "${p2_dir}/Stata"
global p2_graphdir "${p2_dir}/Graph"
global p2resultdir "${p2_dir}/Results"



cd "${p2_dir}"


/*Data Preparation*/

do "{p2_codedir}/data_WITS"
do "{p2_codedir}/data_pmt"
do "{p2_codedir}/data_treaty"
do "{p2_codedir}/data_combine"
