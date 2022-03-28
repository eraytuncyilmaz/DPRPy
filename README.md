# DPRPy
Data Processing With R and Python

# Data Description

We are working on a simplified dump of anonymised data from the website https://travel.stackexchange.com/  
(by the way: full data set is available at https://archive.org/details/stackexchange), which consists of the following data frames:  

• Badges.csv.gz  
• Comments.csv.gz  
• PostLinks.csv.gz  
• Posts.csv.gz  
• Tags.csv.gz  
• Users.csv.gz  
• Votes.csv.gz  
  
To familiarize yourself with the said service and data sets structure (e.g. what information individual columns represent),  
see http://www.gagolewski.com/resources/data/travel_stackexchange_com/readme.txt.  
<br/>

# Task Description

5 SQL queries have four implementations using base functions calls and those provided by the dplyr and data.table packages.

• sqldf::sqldf() – reference solution  
• only base functions  
• dplyr  
• data.table  
