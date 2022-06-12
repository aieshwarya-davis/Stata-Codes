
/*
import delimited "${p2_datadir}/TISP_EBOPS2010_11032022153337916.csv", clear
save "${p2_datadir}/data_flows_raw", replace

import delimited "${p2_datadir}/TISP_EBOPS2010_24032022040631999_pmtall.csv", clear
save "${p2_datadir}/data_flows_oecd", replace
*/


*****************************************************************
*************OECD dataset for more payment***********************
*****************************************************************

use "${p2_datadir}/data_flows_oecd", clear


ren ïcou c2code
ren country c2long
ren partner c1long
ren par c1code

drop yea
tab year

drop v8 unit powercodecode referenceperiodcode flagcodes flags

tab ser
tab service

gen countrypair=c1code+c2code
encode countrypair, gen (ctry_pair)

drop referenceperiod exp expression powercode unitcode measure service
rename value v
gen src= "OECD"

/*Merging with iso3 codes to remove group aggregates*/

*Starting with Reporting country*
rename c2code iso3
rename c2long cname

replace cname= "Hong Kong SAR" if cname == "Hong Kong, China"

merge m:1 iso3 cname using "${p2_datadir}/country_lists_202202.dta"

rename iso3 c2code
rename cname c2long

drop if _merge==2
drop _merge

*Next with Partner country*

rename c1code iso3
rename c1long cname


replace cname = "Aruba" if cname== "Aruba, the Netherlands with respect to"
replace cname = "Bahamas, The" if cname== "Bahamas"
replace cname = "Bahrain" if cname== "Bahrain, Kingdom of"
replace cname = "Bolivia" if cname== "Bolivia, Plurinational State of"
replace cname = "Cayman Islands (the)" if cname== "Cayman Islands"
replace cname = "Taiwan Province of China" if cname== "Chinese Taipei"
replace cname = "Congo, Republic of" if cname== "Congo"
replace cname = "Congo, Democratic Republic of the" if cname== "Democratic Republic of the Congo"
replace cname = "Faroe Islands (the)" if cname== "Faroe Islands"
replace cname = "Faroe Islands (the)" if cname== "Faeroe Islands"
replace cname = "Hong Kong SAR" if cname== "Hong Kong, China"
replace cname = "Korea (the Democratic People's Republic of)" if cname== "Korea, Democratic People's Republic of"
replace cname = "Korea" if cname== "Korea, Republic of"
replace cname = "Kuwait" if cname== "Kuwait, the State of"
replace cname = "Lao P.D.R." if cname== "Lao People's Democratic Republic"
replace cname = "Lebanon" if cname== "Lebanese Republic"
replace cname = "Macao SAR" if cname== "Macao, China"
replace cname = "Moldova" if cname== "Moldova, Republic of"
replace cname = "Montenegro, Rep. of" if cname== "Montenegro"
replace cname = "Palestine, State of" if cname== "Palestine"
replace cname = "Russia" if cname== "Russian Federation"
replace cname = "St. Kitts and Nevis" if cname== "Saint Kitts and Nevis"
replace cname = "St. Lucia" if cname== "Saint Lucia"
replace cname = "Saint Martin (French part)" if cname== "Saint Martin"
replace cname = "St. Vincent and the Grenadines" if cname== "Saint Vincent and the Grenadines"
replace cname = "São Tomé and Príncipe" if cname== "Sao Tomé and Principe"
replace cname = "Saudi Arabia" if cname== "Saudi Arabia, Kingdom of"
replace cname = "Serbia" if cname== "Serbia and Montenegro"
replace cname = "Syria" if cname== "Syrian Arab Republic"
replace cname = "Gambia, The" if cname== "The Gambia"
replace cname = "Turks and Caicos Islands (the)" if cname== "Turks and Caicos Islands"
replace cname = "Kosovo" if cname== "UNMIK/Kosovo"
replace cname = "United States" if cname== "United States of America"
replace cname = "Venezuela" if cname== "Venezuela, Bolivarian Republic of"
replace cname = "Vietnam" if cname== "Viet Nam"
replace cname = "Cabo Verde" if cname== "Cape Verde"
replace cname="China" if cname=="China (Peopleâs Republic of)"
replace cname="Curaçao" if cname=="CuraÃ§ao"
replace cname="Côte d'Ivoire" if cname=="CÃ´te dâIvoire"
replace cname="Gambia, The" if cname=="Gambia"
replace cname="Hong Kong SAR" if cname=="Hong Kong (China)"
replace cname="Kyrgyz Republic" if cname=="Kyrgyzstan"
replace cname="Macao SAR" if cname=="Macao (China)"
replace cname="Micronesia" if cname=="Micronesia, Federated States of"
replace cname="Eswatini" if cname=="Swaziland"
replace cname="British Indian Ocean Territory (the)" if cname=="British Indian Ocean Territory"
replace cname="Virgin Islands (British)" if cname=="British Virgin Islands"
replace cname="Virgin Islands (U.S.)" if cname=="Virgin Islands, United States"

merge m:1 iso3 cname using "${p2_datadir}/country_lists_202202.dta"

drop if _merge==1
drop if _merge==2

rename iso3 c1code
rename cname c1long

keep c2long c1long ser year src v c2code c1code countrypair ctry_pair
rename v value
save "${p2_datadir}/data_OECD.dta", replace 

*Appending WITS and OECD*

//use "${p2_datadir}/data_OECD.dta", replace 
append using "${p2_datadir}/data_WITS.dta"
drop exp

*Duplicates cleaning*

tab year
codebook c2long
codebook c1long
tab ser

bysort c2long c1long year ser: gen obs=_N
tab obs

browse if obs==2

count if obs==2 & src=="WTO" & value!=.

count if obs==2 & src=="OECD" & value!=.

drop if obs==2 & src=="WTO"

count if obs==1 & src=="WTO" & value!=.

count if obs==1 & src=="OECD" & value!=.

drop obs

bysort c2long c1long year ser: gen obs=_N
tab obs
drop obs

count if value==.
count if value==. & src=="WTO"


tab c1long

tab c2long

drop countrypair ctry_pair

gen countrypair=c1code+c2code

encode countrypair, gen(ctry_pair)

bysort ctry_pair year ser: gen obs=_N

drop if obs==2 & src=="WTO" 

drop obs

save "${p2_datadir}/data_OECD+WITSclean.dta", replace 


*Reshape and cleaning*

//use "${p2_datadir}/data_OECD+WITSclean.dta", replace 

drop src
rename value v
reshape wide v, i(c2code c1code year) j(ser) string
rename v* *
rename SA Pmt_manuf
rename SB Pmt_maint
rename SC Pmt_trans
rename SD Pmt_travel
rename SE Pmt_cons
rename SF Pmt_ins
rename SG Pmt_fin
rename SH Pmt_roy
rename SI Pmt_telecom
rename SJ Pmt_otherbus
rename SJ1 Pmt_RandD
rename SJ2 Pmt_prof
rename SJ3 Pmt_techser
label variable Pmt_manuf "SA"
label variable Pmt_maint "SB"
label variable Pmt_trans "SC"
label variable Pmt_travel "SD"
label variable Pmt_cons "SE"
label variable Pmt_ins "SF"
label variable Pmt_fin "SG"
label variable Pmt_roy "SH"
label variable Pmt_telecom "SI"
label variable Pmt_otherbus "SJ"
label variable Pmt_RandD "SJ1"
label variable Pmt_prof "SJ2"
label variable Pmt_techser "SJ3"

save "${p2_datadir}/data_OECD+WITSclean_wide.dta", replace 
save "${p2_datadir}/data_royalty_imp", replace 




/**For Royalty Payments**

tab service if ser=="SH"
keep if ser=="SH"
ren service royalty


/*Services for royalties*/
/*Royalty pmts: To be a royalty, a payment must relate to the use of a valuable right. 
Payments for the use of trademarks, trade names, service marks, or copyrights 
whether or not payment is based on the use made of such property, are ordinarily 
classified as royalties for federal tax purposes.*/


tab ser
tab service

tab service if ser=="SH"
keep if ser=="SH"
ren service royalty

tab c1long
tab c2long

drop if c1long=="Services not allocated geographically"

keep if year>=2015

keep c2code c2long royalty exp year c1long value

save "${p2_datadir}/data_royalty_short", replace
