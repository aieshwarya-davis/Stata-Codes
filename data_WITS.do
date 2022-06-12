//Importing WITS data from https://stats.wto.org/?idSavedQuery=0143fd19-0066-44dc-ad13-0c31f81a100d . Rename indicators with short forms and merging export and import data in the excel file itself. 
//import excel "C:\Users\adavis3\OneDrive - International Monetary Fund (PRD)\P2\Data\WITS data .xlsx", sheet("Report") firstrow clear 

/*reshape long v, i(Indicator exp reporting_country partner_country ) j(year) string 
rename v value
order reporting_country partner_country Indicator exp year value
rename Indicator indicator
save "${p2_datadir}/bilateral data.dta", replace */
//Saving WITS export import bilateral data without ISO3 codes 


*Generating Source and Matching cname with ISO3 codes*

use "${p2_datadir}/bilateral data.dta", replace 
gen src= "WTO" 
label variable year "Year"
label variable value "Value"
label variable src "Source"
label variable exp "Import/Export"


*Merging C2 country (reporting country) name to get ISO3 code*

rename reporting_country cname
replace cname="Aruba" if cname==" Aruba, the Netherlands with respect to"
replace cname = "Aruba" in 1981
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


merge m:1 cname using "${p2_datadir}/country_lists_202202.dta"
rename cname c2long
rename iso3 c2code
drop if _merge==2 /*dropping extra country list observations*/

keep c2long partner_country indicator exp year src value c2code


*Merging C1 (Partner country) country name to get ISO3 code*

rename partner_country cname
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
drop if cname == "Other Countries, n.e.s."

merge m:1 cname using "${p2_datadir}/country_lists_202202.dta"
drop if _merge==2 /*dropping extra country list observations*/
rename cname c1long
rename iso3 c1code

keep c2long c1long indicator exp year src value c2code c1code

*Generating country pair*

gen countrypair= c1code+ c2code
sort c2long c1long indicator exp year
rename indicator ser

save "${p2_datadir}/Bilateral data WITS.dta", replace /*Bilateral WITS data with ISO3 codes*/

*Dropping years except 2019 and export data*

keep if year== "2019"	
drop if exp== "EXP"
destring year, replace


save "${p2_datadir}/data_WITS.dta", replace 