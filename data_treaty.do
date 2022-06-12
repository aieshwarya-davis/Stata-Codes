

use "${p2_datadir}/data_treaty", clear

drop var*

sum

tab status
keep if status=="In Force" | status=="Not In Force"


local varlist wht_int wht_int_fin wht_roy wht_roy_copyrite wht_roy_equip wht_roy_tech

foreach var of varlist `varlist' {
tab `var'
replace `var'="999" if `var'=="NO LIMIT"
destring `var', replace
}

*developing country indicator"
gen c1_developing=c1income!="High income" 
tab c1_developing
codebook c1long if c1_developing==1
codebook c1long if c1_developing==0

gen c2_developing=c2income!="High income" 
tab c2_developing

*Number of treaty
gen obs=1 
gen obs_dev=1 if c2_developing==1


*In force: sum stat*

preserve
keep if status=="In Force"

collapse c1_developing (sum)obs (sum)obs_dev , by (c1long c1code)

sort c1long

save "${p2_datadir}/data_treaty_sumstat", replace
restore

preserve
keep if status=="In Force"
keep if c2_developing==1
collapse (min)wht_int_min_c2dev=wht_int ///
(min)wht_int_fin_min_c2dev=wht_int_fin (max)wht_int_max_c2dev=wht_int ///
(max)wht_int_fin_max_c2dev=wht_int_fin (median)wht_int_c2dev=wht_int (median)wht_int_fin_c2dev=wht_int_fin, by (c1long)

sort c1long

save "${p2_datadir}/data_treaty_sumstat_c2dev1", replace
restore

preserve
keep if status=="In Force"
keep if c2_developing==0
collapse (min)wht_int_min_c2dev0=wht_int ///
(min)wht_int_fin_min_c2dev0=wht_int_fin (max)wht_int_max_c2dev0=wht_int ///
(max)wht_int_fin_max_c2dev0=wht_int_fin (median)wht_int_c2dev0=wht_int (median)wht_int_fin_c2dev0=wht_int_fin, by (c1long)

sort c1long

save "${p2_datadir}/data_treaty_sumstat_c2dev0", replace
restore

preserve
drop if status=="In Force"
replace c1code="TZA" if c1long=="Tanzania"
collapse c1_developing (sum)obs (sum)obs_dev , by (c1long c1code)

sort c1long 

save "${p2_datadir}/data_treaty_sumstata", replace
restore

preserve
drop if status=="In Force"

keep if c2_developing==1
collapse (min)wht_int_min_c2dev=wht_int ///
(min)wht_int_fin_min_c2dev=wht_int_fin (max)wht_int_max_c2dev=wht_int ///
(max)wht_int_fin_max_c2dev=wht_int_fin (median)wht_int_c2dev=wht_int (median)wht_int_fin_c2dev=wht_int_fin, by (c1long)

sort c1long

save "${p2_datadir}/data_treaty_sumstat_c2dev1a", replace
restore

preserve
drop if status=="In Force"
keep if c2_developing==0
collapse (min)wht_int_min_c2dev0=wht_int ///
(min)wht_int_fin_min_c2dev0=wht_int_fin (max)wht_int_max_c2dev0=wht_int ///
(max)wht_int_fin_max_c2dev0=wht_int_fin (median)wht_int_c2dev0=wht_int (median)wht_int_fin_c2dev0=wht_int_fin, by (c1long)

sort c1long 

save "${p2_datadir}/data_treaty_sumstat_c2dev0a", replace
restore

use "${p2_datadir}/data_treaty_sumstat", clear
merge 1:1  c1long  using "${p2_datadir}/data_treaty_sumstat_c2dev1"
drop _merge
merge 1:1  c1long  using "${p2_datadir}/data_treaty_sumstat_c2dev0"
drop _merge
gen status="In Force"
save "${p2_datadir}/data_treaty_sumstat1", replace


use "${p2_datadir}/data_treaty_sumstata", clear
merge 1:1 c1long using "${p2_datadir}/data_treaty_sumstat_c2dev1a"
drop _merge
merge 1:1 c1long using "${p2_datadir}/data_treaty_sumstat_c2dev0a"
drop _merge
gen status="Not In Force"
save "${p2_datadir}/data_treaty_sumstat2", replace

append using "${p2_datadir}/data_treaty_sumstat1"
sort c1long status
browse

ren obs_dev obs_dev1
gen obs_dev0=obs-obs_dev1

save "${p2_datadir}/data_treaty_sumstat", replace


gen shr_dev=obs_dev1/obs


*************/*Merging CIT et al data with Treaty In Force file*/***************

use "${p2_datadir}/data_treaty_inforce.dta", replace 

rename c2code iso3
rename c2long cname

replace cname = "Congo, Democratic Republic of the" if cname== "Congo, Dem. Rep."
replace cname = "Egypt" if cname== "Egypt, Arab Rep."
replace cname = "Hong Kong SAR" if cname== "Hong Kong SAR, China"
replace cname = "Iran" if cname== "Iran, Islamic Rep."
replace cname = "Korea (the Democratic People's Republic of)" if cname== "Korea, Dem. People's Rep."
replace cname = "Korea" if cname== "Korea, Rep."
replace iso3 = "UVK" if cname== "Kosovo"
replace cname = "Lao P.D.R." if cname== "Lao PDR"
replace cname = "Macao SAR" if cname== "Macao SAR, China"
replace cname = "Montenegro, Rep. of" if cname== "Montenegro"
replace cname = "Russia" if cname== "Russian Federation"
replace cname = "Syria" if cname== "Syrian Arab Republic"
replace cname = "São Tomé and Príncipe" if cname== "São Tomé and Principe"
replace cname = "Taiwan Province of China" if cname== "Taiwan, China"
replace cname = "Venezuela" if cname== "Venezuela, RB"
replace iso3 = "WBG" if cname== "West Bank and Gaza"
replace cname = "Yemen" if cname== "Yemen, Rep."

merge m:1 iso3 cname using "${p2_datadir}/CIT et al.dta"
drop if _merge==2

replace cit_top_comb=25 if cname=="Iran"
replace cit_top_comb=25 if cname=="Mauritania"
replace cit_top_comb=25 if cname=="Belize"
replace cit_top_comb=35 if cname=="Cuba"
replace cit_top_comb=35 if cname=="Guinea"
replace cit_top_comb=25 if cname=="Guinea-Bissau"
replace cit_top_comb=35 if cname=="Kiribati"
replace cit_top_comb=30 if cname=="Niger"
replace cit_top_comb=17 if cname=="San Marino"
replace cit_top_comb=33 if cname=="Seychelles"
replace cit_top_comb=30 if cname=="Somalia"
replace cit_top_comb=25 if cname=="São Tomé and Príncipe"

drop _merge
rename cname c2long
rename iso3 c2code
rename cit_top_comb c2_cit_top_comb
rename corp c2_corp
rename income_imf c2_income_imf
rename ngdp c2_ngdp

rename c1code iso3
rename c1long cname
replace cname = "Congo, Democratic Republic of the" if cname== "Congo, Dem. Rep."
replace cname = "Egypt" if cname== "Egypt, Arab Rep."
replace cname = "Hong Kong SAR" if cname== "Hong Kong SAR, China"
replace cname = "Iran" if cname== "Iran, Islamic Rep."
replace cname = "Korea (the Democratic People's Republic of)" if cname== "Korea, Dem. People's Rep."
replace cname = "Korea" if cname== "Korea, Rep."
replace iso3 = "UVK" if cname== "Kosovo"
replace cname = "Lao P.D.R." if cname== "Lao PDR"
replace cname = "Macao SAR" if cname== "Macao SAR, China"
replace cname = "Montenegro, Rep. of" if cname== "Montenegro"
replace cname = "Russia" if cname== "Russian Federation"
replace cname = "Syria" if cname== "Syrian Arab Republic"
replace cname = "São Tomé and Príncipe" if cname== "São Tomé and Principe"
replace cname = "Taiwan Province of China" if cname== "Taiwan, China"
replace cname = "Venezuela" if cname== "Venezuela, RB"
replace iso3 = "WBG" if cname== "West Bank and Gaza"
replace cname = "Yemen" if cname== "Yemen, Rep."
replace cname = "Congo, Republic of" if cname== "Congo, Rep."
replace cname = "Faroe Islands (the)" if cname== "Faroe Islands"


merge m:1 iso3 cname year using "${p2_datadir}/CIT et al.dta"
drop if _merge==2

replace cit_top_comb=25 if cname=="Iran"
replace cit_top_comb=25 if cname=="Mauritania"
replace cit_top_comb=25 if cname=="Belize"
replace cit_top_comb=35 if cname=="Cuba"
replace cit_top_comb=35 if cname=="Guinea"
replace cit_top_comb=25 if cname=="Guinea-Bissau"
replace cit_top_comb=35 if cname=="Kiribati"
replace cit_top_comb=30 if cname=="Niger"
replace cit_top_comb=17 if cname=="San Marino"
replace cit_top_comb=33 if cname=="Seychelles"
replace cit_top_comb=30 if cname=="Somalia"
replace cit_top_comb=25 if cname=="São Tomé and Príncipe"
replace cit_top_comb=22 if cname=="Cabo Verde"
replace cit_top_comb=28 if cname=="Congo, Republic of"
replace cit_top_comb=18 if cname=="Faroe Islands (the)"
replace cit_top_comb=17 if cname=="Korea (the Democratic People's Republic of)"
replace cit_top_comb=25 if cname=="Lesotho"
replace cit_top_comb=50 if cname=="Comoros"

drop _merge

rename cname c1long
rename iso3 c1code
rename cit_top_comb c1_cit_top_comb
rename corp c1_corp
rename income_imf c1_income_imf
rename ngdp c1_ngdp

levelsof c2long if c2_cit_top_comb==.
levelsof c1long if c1_cit_top_comb==.



save "${p2_datadir}/data_treaty_inforce+CIT.dta", replace

/* Patent Box merge*/

/*Excel Import and PB dataset*

//import excel "${p2_datadir}/data_pb.xlsx", sheet("Sheet1") firstrow clear
gen year=2019
save "${p2_datadir}/PB data.dta" */


*Data merge

//use "${p2_datadir}/data_treaty+payment+CIT.dta", replace
merge m:m c2code c2long year using "${p2_datadir}/PB data.dta"
drop if _merge==2
drop _merge

save "${p2_datadir}/data_treaty_inforce+CIT+PB.dta", replace


/*Merging CIT et al data with Treaty not In Force file*/

use "${p2_datadir}/data_treaty_notinforce.dta", replace 

rename c2code iso3
rename c2long cname

replace cname = "Congo, Democratic Republic of the" if cname== "Congo, Dem. Rep."
replace cname = "Egypt" if cname== "Egypt, Arab Rep."
replace cname = "Hong Kong SAR" if cname== "Hong Kong SAR, China"
replace cname = "Iran" if cname== "Iran, Islamic Rep."
replace cname = "Korea (the Democratic People's Republic of)" if cname== "Korea, Dem. People's Rep."
replace cname = "Korea" if cname== "Korea, Rep."
replace iso3 = "UVK" if cname== "Kosovo"
replace cname = "Lao P.D.R." if cname== "Lao PDR"
replace cname = "Macao SAR" if cname== "Macao SAR, China"
replace cname = "Montenegro, Rep. of" if cname== "Montenegro"
replace cname = "Russia" if cname== "Russian Federation"
replace cname = "Syria" if cname== "Syrian Arab Republic"
replace cname = "São Tomé and Príncipe" if cname== "São Tomé and Principe"
replace cname = "Taiwan Province of China" if cname== "Taiwan, China"
replace cname = "Venezuela" if cname== "Venezuela, RB"
replace iso3 = "WBG" if cname== "West Bank and Gaza"
replace cname = "Yemen" if cname== "Yemen, Rep."
replace cname = "Congo, Republic of" if cname== "Congo, Rep."
replace cname = "Faroe Islands (the)" if cname== "Faroe Islands"


merge m:1 iso3 cname using "${p2_datadir}/CIT et al.dta"
drop if _merge==2

replace cit_top_comb=25 if cname=="Iran"
replace cit_top_comb=25 if cname=="Mauritania"
replace cit_top_comb=25 if cname=="Belize"
replace cit_top_comb=35 if cname=="Cuba"
replace cit_top_comb=35 if cname=="Guinea"
replace cit_top_comb=25 if cname=="Guinea-Bissau"
replace cit_top_comb=35 if cname=="Kiribati"
replace cit_top_comb=30 if cname=="Niger"
replace cit_top_comb=17 if cname=="San Marino"
replace cit_top_comb=33 if cname=="Seychelles"
replace cit_top_comb=30 if cname=="Somalia"
replace cit_top_comb=25 if cname=="São Tomé and Príncipe"
replace cit_top_comb=22 if cname=="Cabo Verde"
replace cit_top_comb=28 if cname=="Congo, Republic of"
replace cit_top_comb=18 if cname=="Faroe Islands (the)"
replace cit_top_comb=17 if cname=="Korea (the Democratic People's Republic of)"
replace cit_top_comb=25 if cname=="Lesotho"
replace cit_top_comb=50 if cname=="Comoros"
replace cit_top_comb=35 if cname=="Equatorial Guinea"
replace cit_top_comb=10 if cname=="Timor-Leste"

drop _merge

rename cname c2long
rename iso3 c2code
rename cit_top_comb c2_cit_top_comb
rename corp c2_corp
rename income_imf c2_income_imf
rename ngdp c2_ngdp

rename c1code iso3
rename c1long cname

replace cname = "Congo, Democratic Republic of the" if cname== "Congo, Dem. Rep."
replace cname = "Egypt" if cname== "Egypt, Arab Rep."
replace cname = "Hong Kong SAR" if cname== "Hong Kong SAR, China"
replace cname = "Iran" if cname== "Iran, Islamic Rep."
replace cname = "Korea (the Democratic People's Republic of)" if cname== "Korea, Dem. People's Rep."
replace cname = "Korea" if cname== "Korea, Rep."
replace iso3 = "UVK" if cname== "Kosovo"
replace cname = "Lao P.D.R." if cname== "Lao PDR"
replace cname = "Macao SAR" if cname== "Macao SAR, China"
replace cname = "Montenegro, Rep. of" if cname== "Montenegro"
replace cname = "Russia" if cname== "Russian Federation"
replace cname = "Syria" if cname== "Syrian Arab Republic"
replace cname = "São Tomé and Príncipe" if cname== "São Tomé and Principe"
replace cname = "Taiwan Province of China" if cname== "Taiwan, China"
replace cname = "Venezuela" if cname== "Venezuela, RB"
replace iso3 = "WBG" if cname== "West Bank and Gaza"
replace cname = "Yemen" if cname== "Yemen, Rep."
replace cname = "Congo, Republic of" if cname== "Congo, Rep."
replace cname = "Faroe Islands (the)" if cname== "Faroe Islands"
replace iso3 = "TZA" if cname== "Tanzania"

merge m:1 iso3 cname year using "${p2_datadir}/CIT et al.dta"
drop if _merge==2

replace cit_top_comb=25 if cname=="Iran"
replace cit_top_comb=25 if cname=="Mauritania"
replace cit_top_comb=25 if cname=="Belize"
replace cit_top_comb=35 if cname=="Cuba"
replace cit_top_comb=35 if cname=="Guinea"
replace cit_top_comb=25 if cname=="Guinea-Bissau"
replace cit_top_comb=35 if cname=="Kiribati"
replace cit_top_comb=30 if cname=="Niger"
replace cit_top_comb=17 if cname=="San Marino"
replace cit_top_comb=33 if cname=="Seychelles"
replace cit_top_comb=30 if cname=="Somalia"
replace cit_top_comb=25 if cname=="São Tomé and Príncipe"
replace cit_top_comb=22 if cname=="Cabo Verde"
replace cit_top_comb=28 if cname=="Congo, Republic of"
replace cit_top_comb=18 if cname=="Faroe Islands (the)"
replace cit_top_comb=17 if cname=="Korea (the Democratic People's Republic of)"
replace cit_top_comb=25 if cname=="Lesotho"
replace cit_top_comb=50 if cname=="Comoros"
replace cit_top_comb=35 if cname=="Equatorial Guinea"
replace cit_top_comb=10 if cname=="Timor-Leste"
replace cit_top_comb=35 if cname=="Chad"

drop _merge


rename cname c1long
rename iso3 c1code
rename cit_top_comb c1_cit_top_comb
rename corp c1_corp
rename income_imf c1_income_imf
rename ngdp c1_ngdp

levelsof c2long if c2_cit_top_comb==.
levelsof c1long if c1_cit_top_comb==.

save "${p2_datadir}/data_treaty_notinforce+CIT.dta", replace

/* Patent Box merge*/

/*Excel Import and PB dataset*

//import excel "${p2_datadir}/data_pb.xlsx", sheet("Sheet1") firstrow clear
gen year=2019
save "${p2_datadir}/PB data.dta" */


*Data merge

//use "${p2_datadir}/data_treaty+payment+CIT.dta", replace
merge m:m c2code c2long year using "${p2_datadir}/PB data.dta"
drop if _merge==2
drop _merge

save "${p2_datadir}/data_treaty_notinforce+CIT+PB.dta", replace


