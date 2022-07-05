# Stata-Codes

This repository contains stata project used to curate a database that looks at the level Bilateral Trade in Services data along with its rates of CIT, excises and taxes/royalties to understand the effect of bilateral treaties, in these international transactions, with an additional layer of patents. This is to support the pillar 2 agreement work on tax treaties. 

The data is collected from World Bank, Eurostat, IMF and WITS. 

The codes within the project are also included for easy viewing.

data_WITS.do- This do file imports the .csv file of export import bilateral data  from WITS and runs preliminary cleaning functions and merging of country group files

data_pmt.do- This do file imports the .csv file of more payments data from OECD and runs preliminary cleaning functions along with an option to classify for royalties

data_treaty.do- This do file uses pre-curated treaty information on whether treaties between countries are in force or or not and merges CIT rates along with other manipulations to provide insight on the effect of these treaties and their differences with existing CIT rates, in case these treaties were not in effect. 

data_combine.do- This do file combines the above do files to understand the effect of treaties on imports and exports along with the option to highlight the effects of patents as well.
