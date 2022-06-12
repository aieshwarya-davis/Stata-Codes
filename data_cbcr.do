
use "C:\Users\LLiu\OneDrive - International Monetary Fund (PRD)\P2\Data\CbCR 2017.dta"", replace

keep if grouping=="All Sub-Groups"
drop if cname_host==""

tab cname_partner
keep if cname_host=="United States"
tab cname_partner

drop if cname_partner=="Foreign Jurisdictions Total"

