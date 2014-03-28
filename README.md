#Design Doc for CalTest/CalTrac Code

The primary purpose of CalTest is to select a set of representative homes from three utilities for use in benchmarking energy savings estimation calculations in third-party software vendors.

The code is organize into th

##ETL

Currently, the process doesn't require any ETLs to be written because we are not connecting to any utility databases. 

##Data Preparation

Each utility provided the following three data 

- Project data collected by the utility
- Energy use data
- XML files from each of the installations

The goal of data preparation is to standardize the format of the following variables from each of the datasets:

Project/Building Data

	group_number	
	preference	
	record	
	yearbuilt	
	zipcode	
	climate	
	pre_area	
	pre_volume	
	stories	
	date_of_retrofit

Energy Use Data
	
	ave_daily_gas_adj
	ave_daily_electric_adj
	

XML Data
	
	XML_FoundationType	
	XML_Ductloc1	
	XML_HeatingEfficiency	
	XML_postafue	
	XML_CoolingEfficiency	
	XML_EER	XML_postseer	
	XML_posteer	
	pre_r_duct	
	XML_ductrpost	
	pre_cfm25duct	
	XML_ductcfm25post	
	pre_cfm50	
	XML_cfm50post	
	pre_ceil_u	
	pre_wall_u	
	pre_floor_u


Data preparation for data from each utility is below.

Steps in raw data preparation: 

1. Read in utility project data & standardize variable names
2. Parse XML data
3. Prepare XML data for merge
4. Merge cleaned XML data with building data and use data
5. perform basic cleaning and checks

####General XML Parsing
To parse the 


####PG&E Data Prep

*PG&E Raw Datasets*

	We were given the following raw PG&E data sets
		- 

*scripts that perform these steps*
	
	- PGEDataPrep.py
	- XMLParse.py
	


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

For weather normalization

##PG&E Home Selection

Home selection underwent the following process

 

