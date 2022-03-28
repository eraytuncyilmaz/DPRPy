# DPRPy
Data Processing With R and Python  
<br/>

# Project 1
## Data Description

We are working on a simplified dump of anonymised data from the website https://travel.stackexchange.com/  
(full data set is available at https://archive.org/details/stackexchange), which consists of the following data frames:  

• Badges.csv.gz  
• Comments.csv.gz  
• PostLinks.csv.gz  
• Posts.csv.gz  
• Tags.csv.gz  
• Users.csv.gz  
• Votes.csv.gz  
  
To familiarize yourself with the said service and data sets structure,  
see http://www.gagolewski.com/resources/data/travel_stackexchange_com/readme.txt.  
<br/>

## Task Description

5 SQL queries have four implementations using base functions calls and those provided by the dplyr and data.table packages.

• sqldf::sqldf() – reference solution  
• only base functions  
• dplyr  
• data.table  
<br/>

# Project 2 - 3
## Data Description

We will continue to work on data from the Stack Exchange network. However, not only simplified data from Travel Stack Exchange forum but from other forums as well.  
At https://archive.org/details/stackexchange an anonymized dump of all user-contributed content on the Stack Exchange network is available. In all cases (except for the StackOverflow - due to its size) each website is saved as one .7z archive, which contains 8 tables (XML files):  

• Badges  
• Comments  
• PostHistory  
• PostLinks  
• Posts  
• Tags  
• Users  
• Votes  

Detailed description can be found on the https://archive.org/27/items/stackexchange/readme.txt  
and https://meta.stackexchange.com/questions/2677  
<br/>

## Task Description

• Preparing documented, specialized functions, scripts / moduls that are named named  
• Prepared scripts / moduls automaticly load data (from any forum) based on the given path  
• Creating functions to prepare data for analysis  
• Dates are transformed into correct format if needed  
• All missing values are denoted as NA  

The Project 3, is a data science challenge. We are going to create questions and generate answers to them.  
We are interested in issues related to specific websites, but also comparisons between sites.  
The state of “today” and trends over time. Popular stuff and rarities. Differences and similarities.  
<br/>

# Project 4
## Data Description

We are working on a simplified dump of anonymised data from the website https://travel.stackexchange.com/  
(full data set is available at https://archive.org/details/stackexchange), which consists of the following data frames:  

• Badges.csv.gz  
• Comments.csv.gz  
• PostLinks.csv.gz  
• Posts.csv.gz  
• Tags.csv.gz  
• Users.csv.gz  
• Votes.csv.gz  
  
To familiarize yourself with the said service and data sets structure,  
see http://www.gagolewski.com/resources/data/travel_stackexchange_com/readme.txt.  
<br/>

## Task Description

3 SQL queries have two implementations using Python:  

• pandas.read_sql_query("""question SQL""") - reference solution  
• calling methods and functions from pandas package
<br/>
