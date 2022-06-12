


use "${datadir}\tax_exemption_clean.dta", clear


*Drop Missing Values

drop Warrant PaymentDate

*Data on Imports
keep if Type=="C13" | Type=="C13W"

save "${datadir}\tax_exemption_clean_import.dta", replace

use "${datadir}\tax_exemption_clean_import.dta", clear

drop if TIN==""
*drop if year==2020

gen t=substr(TIN,1,1)
gen tin=TIN if t!="C"
*replace tin=substr(TIN,2,5) if t=="C" | t=="c"
destring tin, force replace

*label the duty concession type:
gen duty_concession_type=int(ConcessionCode/10000)
gen duty_con=duty_concession_type!=.

replace TariffHeading=int(TariffCode/1000000) if TariffHeading==.

replace ExciseConcession=CIFValue*ExciseRate/100 if Receipt==200288756

gen hs4=int(TariffCode/10000)

*Aggregate Data in Different Ways*

*1. By Exemption Type and Year:

preserve
collapse (sum) CIFValue DutyPayable DutyConcession ExcisePayable ExciseConcession CTPayable CTConcession, by (year)
save "${datadir}\Customs\exemption_annual.dta", replace
restore

 *2. By Exemption Type, Product and Year:
 
preserve
collapse (sum)CIFValue DutyPayable DutyConcession ExcisePayable ExciseConcession CTPayable CTConcession, by (TariffHeading duty_con year)
save "${datadir}\Customs\exemption_product.dta", replace
sort duty_con year TariffHeading
export excel using "${resultdir}\exemption_product.xls", firstrow(variables) replace

restore

preserve
collapse (sum)CIFValue DutyPayable DutyConcession ExcisePayable ExciseConcession CTPayable CTConcession, by (Name duty_con TIN year)
save "${datadir}\Customs\exemption_firm.dta", replace
sort duty_con year TIN
export excel using "${resultdir}\exemption_firm.xls", firstrow(variables) replace

restore

***Tonga Power: 268147***

preserve

keep if TIN=="268147"

collapse (sum)CIFValue DutyPayable DutyConcession ExcisePayable ExciseConcession CTPayable CTConcession, by (TariffHeading duty_con year)
save "${datadir}\Customs\exemption_producttongapower.dta", replace
sort duty_con year TariffHeading
export excel using "${resultdir}\exemption_producttongapower.xls", firstrow(variables) replace

restore

***Excise Concession: 

preserve
keep if TariffHeading==27
keep if ExciseConcession>0 & ExciseConcession!=.
collapse (sum)CIFValue DutyPayable DutyConcession ExcisePayable ExciseConcession CTPayable CTConcession, by (hs4 year)
save "${datadir}\Customs\exemption_fuelhs4.dta", replace
sort year ExciseConcession 
export excel using "${resultdir}\exemption_fuelhs4.xls", firstrow(variables) replace

restore

preserve
keep if TariffHeading==27
keep if ExciseConcession>0 & ExciseConcession!=.
collapse (sum)CIFValue DutyPayable DutyConcession ExcisePayable ExciseConcession CTPayable CTConcession, by (Name TIN year)
save "${datadir}\Customs\exemption_firmfuel.dta", replace
sort duty_con year ExciseConcession TIN
export excel using "${resultdir}\exemption_firmfuel.xls", firstrow(variables) replace
restore

***CT Concession: 

preserve

keep if CTConcession>0 & CTConcession!=.

collapse (sum)CIFValue CTPayable CTConcession, by (hs4 year)
bysort year: egen CTConcession_sum=total(CTConcession)
gen shr_ct=CTConcession/CTConcession_sum
save "${datadir}\Customs\exemption_cths4.dta", replace
drop CTConcession_sum
sort year shr_ct  
export excel using "${resultdir}\exemption_cths4.xls", firstrow(variables) replace

restore

preserve
collapse (sum)CIFValue CTPayable CTConcession, by (Name TIN year)
bysort year: egen CTConcession_sum=total(CTConcession)
gen shr_ct=CTConcession/CTConcession_sum
save "${datadir}\Customs\exemption_firmct.dta", replace
drop CTConcession_sum
gsort year -shr_ct TIN
export excel using "${resultdir}\exemption_firmct.xls", firstrow(variables) replace
restore

preserve
collapse (sum)CIFValue DutyPayable DutyConcession ExcisePayable ExciseConcession CTPayable CTConcession, by (tin year)
bysort year: egen CTConcession_sum=total(CTConcession)
gen shr_ct=CTConcession/CTConcession_sum
gen concession_total=DutyConcession+ExciseConcession+CTConcession
save "${datadir}\Customs\exemption_firm2merge.dta", replace
restore

*a closer look into the top 20 companies with largest CT exemptions:

keep if year==2019
keep if ///
TIN=="268147" | ///
TIN=="265807" | ///
TIN=="259385" | ///
TIN=="262787" | ///
TIN=="260864" | ///
TIN=="752857" | ///
TIN=="268707" | ///
TIN=="257974" | ///
TIN=="261425" | ///
TIN=="768795" | ///
TIN=="455521" | ///
TIN=="261205" | ///
TIN=="260383" | ///
TIN=="268491" | ///
TIN=="491965" | ///
TIN=="C00240" | ///
TIN=="259392" | ///
TIN=="536301" | ///
TIN=="258009" | ///
TIN=="500658"

collapse (sum)CIFValue CTPayable CTConcession, by (TariffHeading Name TIN)
bysort TIN: egen CTConcession_sum=total(CTConcession)
gen shr_ct=CTConcession/CTConcession_sum
save "${datadir}\Customs\exemption_firm20ct.dta", replace
gsort -CTConcession_sum -shr_ct 
export excel using "${resultdir}\exemption_firm20ct.xls", firstrow(variables) replace
