use "${p2_datadir}/data_treaty", clear

drop var*

sum

tab status

local varlist wht_int wht_int_fin wht_roy wht_roy_copyrite wht_roy_equip wht_roy_tech

foreach var of varlist `varlist' {
tab `var'
replace `var'="999" if `var'=="NO LIMIT"
destring `var', replace
}

gen countrypair=c1code+c2code

preserve
keep if status=="In Force" 

bysort countrypair: gen obs=_N
tab obs
browse if obs==2

drop if (treatyid==15001 | treatyid==9333) & obs==2
drop obs

bysort countrypair: gen obs=_N
tab obs
drop obs

save "${p2_datadir}/data_treaty_inforce", replace

restore
keep if status=="Not In Force" 

save "${p2_datadir}/data_treaty_notinforce", replace

*Combine with the royalty pmt data*

use "${p2_datadir}/data_pmt", clear

merge 1:1 countrypair using "${p2_datadir}/data_treaty_inforce"

preserve 
keep if _merge==3
drop _merge
save "${p2_datadir}/data_pmt2019_m3", replace
restore

keep if _merge==1
drop countrypair _merge
gen countrypair=c2code+c1code
merge 1:1 countrypair using "${p2_datadir}/data_treaty_inforce", update
keep if _merge==3
drop _merge

append using "${p2_datadir}/data_pmt2019_m3"

label var c1long "Paying/Exp country"
label var c1code "Paying/Exp country code"

label var c2long "Receiving/Imp country"
label var c2code "Receving/Imp country code"

save "${p2_datadir}/data_pmt_treaty", replace


/*Combine with the CIT dataset and pb rate*/

/*CIT + CIT Revenue + GDP merge*/

//use "${p2_datadir}/data_pmt_treaty", replace
rename c2code iso3
rename c2long cname
merge m:1 iso3 cname using "${p2_datadir}/CIT et al.dta"
drop if _merge==2
drop _merge
rename cname c2long
rename iso3 c2code
rename cit_top_comb c2_cit_top_comb
rename corp c2_corp
rename income_imf c2_income_imf
rename ngdp c2_ngdp
rename c1code iso3
rename c1long cname
merge m:1 iso3 cname year using "${p2_datadir}/CIT et al.dta"
drop if _merge==2
drop _merge
rename cname c1long
rename iso3 c1code
rename cit_top_comb c1_cit_top_comb
rename corp c1_corp
rename income_imf c1_income_imf
rename ngdp c1_ngdp

levelsof c2long if c2_cit_top_comb==.
levelsof c1long if c1_cit_top_comb==.
replace c1_cit_top_comb=25 if c1long=="Iran"
replace c1_cit_top_comb=25 if c1long=="Mauritania"
save "${p2_datadir}/data_treaty+payment+CIT.dta", replace

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

save "${p2_datadir}/data_treaty+payment+CIT+PB.dta", replace



