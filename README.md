#Design Doc for CalTest/CalTrac Code

The primary purpose of CalTest is to select a set of representative homes from three utilities for use in benchmarking energy savings estimation calculations in third-party software vendors.

The code is organize into th

##ETL

Currently 

##Data Preparationd


Data preparation for data from each utility is below.

####PG&E Data Prep

*scripts that perform these steps*
	
	- PGEDataPrep.py
	- XMLParse.py
	
Raw data: 

1. Standardize variable names
2. Parse XML data
3. Prepare XML data for merge
4. Merge cleaned XML data with building data and use data
5. perform basic cleaning and checks

####SCG Data Prep

*scripts that perform scg data prep*

	- SCGDataPrep.py
	
####Weather Data Prep

*scripts that perform weather data extraction and prepartation*

	- CalWeatherPull.py
	- WeatherImput.py

####Creation of combined database

*scripts that perform combined data*


##Weather Normalization


##PG&E Home Selection



 

