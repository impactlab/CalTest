# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <markdowncell>

# ###Weather Data Imputation for CalCalc
# 
# Using data from 89 weather stations in California, we construct a balanced panel of daily tempurature readings for all stations over the last eight years. Missing data is imputed using a combination of random forest regression and linear interpolation. 

# <markdowncell>

# ###Setup
# 
# Import libraries and define global variables

# <codecell>

import pandas as pd
import datetime as dt
#import statsmodels
from sklearn.ensemble import RandomForestRegressor

PATH = "/Users/matthewgee/Dropbox/Projects/CalCalc/CalCalcShared/Data/weather/" #
URL = ""  #for setting up reoccuring data creation

# <codecell>

#read in data and generate two main datasets for analysis and export
rawtemps = pd.read_csv(PATH + 'cz2010_gsod_2006_2013.csv')
completetemps = rawtemps[['usaf' , 'date' , 'temp']]
completetemps['predtemp'] = NaN

# <codecell>

#check data
rawtemps.head()
completetemps.head()

# <markdowncell>

# ###Reformat and reshape raw tempurature data and complete tempurature dataset (for later use)

# <codecell>

#set the index
completetemps = completetemps.set_index(['usaf','date'])
df = rawtemps.pivot(index='date',columns='usaf',values='temp')

# <markdowncell>

# ###Sort prepared data

# <codecell>

df.sort()
df

# <markdowncell>

# ###Implement Random Forest Model
# 
# For imputing large blocks of missing data, I apply an ensemble method called random forest regression. Random forest is a meta estimator that fits a number of classifying decision trees on various sub-samples of the dataset and use averaging to improve the predictive accuracy and control over-fitting. 
# 
# I use the sci-kit learn machine learning library for implementation of the random forest regression method. The documentation for sci-kit learn's RandomForestRegressor can be found [here.](http://scikit-learn.org/stable/modules/generated/sklearn.ensemble.RandomForestRegressor.html)

# <codecell>

##Loop through imputation procedure

for i in range(len(allstations)):
    allstations = df.columns #creates list of stations for use
    otherstations = allstations.delete(i)
    train = df[df[allstations[i]].notnull()]
    missing = df[df[allstations[i]].isnull()]
    
    if len(missing) > 5:
        
        #create prediction dataset
        predict = missing[otherstations]
        predict.fillna(predict.mean(),inplace=True)
        
        #create features dataset
        features = train[otherstations] 
        features.fillna(features.mean(),inplace=True)
        
        #create dependent variable for training
        y = train[allstations[i]]
        
        #run the random forest model
        reg = RandomForestRegressor(n_jobs=-1, n_estimators=20)
        reg.fit(features, y)
        
        #generate predictions
        preds = reg.predict(predict)
        missing[allstations[i]]=preds
        
        #create dataset of filled values to merge back into incomplete data
        varname = 'predtemp' + str(i)
        filled = pd.DataFrame(missing[allstations[i]], columns=[varname])
        filled['usaf']=allstations[i]
        filled = filled.reset_index().set_index(['usaf','date'])

        
        #merge predictions into incomplete data
        #pd.merge(completetemps, filled, left_index=True, right_index=True,how='inner')
        completetemps = completetemps.join(filled, how='outer')
        completetemps['predtemp'] = np.where(completetemps['predtemp'].isnull(),  completetemps[varname], completetemps['predtemp'])



# <markdowncell>

# ###Apply linear Interpolation for single missing values
# 
# For single instance of missing values and small contiguous instances within station, I apply a linear interpolation.

# <codecell>

outputtemps = completetemps[['temp','predtemp']]
outputtemps['completetemps'] = np.where(outputtemps['temp'].isnull(), outputtemps['predtemp'], outputtemps['temp'])

#convert to datetime
outputtemps = outputtemps.reset_index() #reset the index on the data to allow for datetime converions
outputtemps['date'] = pd.to_datetime(outputtemps['date'], format='%d%b%Y') #convert date string to datetime for sorting
outputtemps #check conversions
outputtemps = outputtemps.sort(columns=['usaf','date']) #sort on station code and date

#Apply interpolation to final missing data
outputtemps['completetemps'] = outputtemps['completetemps'].interpolate()

# <markdowncell>

# ###Output predictions
# 
# Write final imputed values to a csv and save it to the shared folder.

# <codecell>

outputtemps.to_csv(PATH + "CalCalc_Complete_Temps.csv")

# <markdowncell>

# ####Plot imputed tempuratures for sanity check

# <codecell>

import matplotlib as plt
plot(outputtemps['date'][:3000],outputtemps['completetemps'][:3000])
plot(outputtemps['date'][:3000],outputtemps['predtemp'][:3000], color='red')

# <markdowncell>

# ###Add Distance Weights to Tempurature Estimates
# 
# We may think that having 1/r weights is superior to implied weighting in the regression since there is the change for systematic correlation between distant stations that is more sensitive to underestimation of local shocks (overweighted in estimating local outlying tempurature events).
# 
# I define a function that calculates the distance between any two stations and use that to construct a distance weighting in the estimation.

# <markdowncell>

# ####Create distance calculating function

# <codecell>

import math

def distance(origin, destination):
    lat1, lon1 = origin
    lat2, lon2 = destination
    radius = 6371 # km

    dlat = math.radians(lat2-lat1)
    dlon = math.radians(lon2-lon1)
    a = math.sin(dlat/2) * math.sin(dlat/2) + math.cos(math.radians(lat1)) \
        * math.cos(math.radians(lat2)) * math.sin(dlon/2) * math.sin(dlon/2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    d = radius * c

    return d

# <codecell>

#read in location data

stationLocations = pd.read_csv(PATH + "WeatherFileClimateZone.csv")
stationLocations

