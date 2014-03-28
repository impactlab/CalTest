/*

Convert the latest version of every Stata dataset to csv for use in final creation

*/


local pgeDIR '/Users/matthewgee/Projects/CalTest/data/pgedata'
local sdgeDIR '/Users/matthewgee/Projects/CalTest/data/sdge/'
local scgDIR '/Users/matthewgee/Projects/CalTest/data/scgdata'

**********************
**Convert sdge Data***
**********************
cd sdgeDIR

**Convert program data
use 

outsheet 

**Convert use data


********************
**Convert SCG Data**
********************
