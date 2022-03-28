library(xml2)
library(future)
library(rmarkdown)
library(knitr)
library(kableExtra)
library(sqldf)
library(wordcloud)
library(RColorBrewer)
library(TSstudio)
library(plotly)
library(lubridate)

#In this project the Exploratory Data Analysis of forums from Stack Exchange network is made. 
#Each forum has 8 tables that are XML files Badges, Comments, PostHistory, PostLinks, Posts, Tags, Users and Votes. 
#Detailed description can be found on “https://meta.stackexchange.com/questions/2677”. 
#The forum that is chosen to analyse is https://academia.stackexchange.com/"

#Badges
Badges <- function(path){
  #Path to XML file
  Badges_xml <- path
  
  #Read XML file
  Badges_doc <- read_xml(Badges_xml, useInternalNode = TRUE)
  
  #Get rows
  Badges_rows <- xml_children(Badges_doc)
  
  #Create data frame
  Badges_df <- data.frame(
    Id = as.integer(xml_attr(Badges_rows, "Id")),
    UserId = as.integer(xml_attr(Badges_rows, "UserId")),
    Name = as.character(xml_attr(Badges_rows, "Name")),
    Date = as.Date(xml_attr(Badges_rows, "Date")), 
    Class = as.integer(xml_attr(Badges_rows, "Class")),
    TagBased = as.logical(xml_attr(Badges_rows, "TagBased")))
  
  return(Badges_df)}

#Comment
Comments <- function(path){
  #Path to XML file
  Comments_xml <- path
  
  #Read XML file
  Comments_doc <- read_xml(Comments_xml, useInternalNode = TRUE)
  
  #Get rows
  Comments_rows <- xml_children(Comments_doc)
  
  #Create data frame
  Comments_df <- data.frame(
    Id = as.integer(xml_attr(Comments_rows, "Id")),
    PostId = as.integer(xml_attr(Comments_rows, "PostId")),
    Score = as.integer(xml_attr(Comments_rows, "Score")),
    Text = as.character(xml_attr(Comments_rows, "Text")),
    CreationDate = as.Date(xml_attr(Comments_rows, "CreationDate")),
    UserDisplayName = as.character(xml_attr(Comments_rows, "UserDisplayName")),
    UserId = as.integer(xml_attr(Comments_rows, "UserId")),
    ContentLicense = as.character(xml_attr(Comments_rows, "ContentLicense")))
  
  return(Comments_df)}

#PostHistory
PostHistory <- function(path){
  #Path to XML file
  PostHistory_xml <- path
  
  #Read XML file
  PostHistory_doc <- read_xml(PostHistory_xml, useInternalNode = TRUE)
  
  #Get rows
  PostHistory_rows <- xml_children(PostHistory_doc)
  
  #Create data frame
  PostHistory_df <- data.frame(
    Id = as.integer(xml_attr(PostHistory_rows, "Id")),
    PostHistoryTypeId = as.integer(xml_attr(PostHistory_rows, "PostHistoryTypeId")),
    PostId = as.integer(xml_attr(PostHistory_rows, "PostId")),
    RevisionGUID = as.character(xml_attr(PostHistory_rows, "RevisionGUID")),
    CreationDate = as.Date(xml_attr(PostHistory_rows, "CreationDate")),
    UserId = as.integer(xml_attr(PostHistory_rows, "UserId")),
    UserDisplayName = as.character(xml_attr(PostHistory_rows, "UserDisplayName")),
    Comment = as.character(xml_attr(PostHistory_rows, "Comment")),
    Text = as.character(xml_attr(PostHistory_rows, "Text")),
    ContentLicense = as.character(xml_attr(PostHistory_rows, "ContentLicense")))
  
  return(PostHistory_df)}

#PostLinks
PostLinks <- function(path){
  #Path to XML file
  PostLinks_xml <- path
  
  #Read XML file
  PostLinks_doc <- read_xml(PostLinks_xml, useInternalNode = TRUE)
  
  #Get rows
  PostLinks_rows <- xml_children(PostLinks_doc)
  
  #Create data frame
  PostLinks_df <- data.frame(
    Id = as.integer(xml_attr(PostLinks_rows, "Id")),
    CreationDate = as.Date(xml_attr(PostLinks_rows, "CreationDate")),
    PostId = as.integer(xml_attr(PostLinks_rows, "PostId")),
    RelatedPostId = as.integer(xml_attr(PostLinks_rows, "RelatedPostId")),
    LinkTypeId = as.integer(xml_attr(PostLinks_rows, "LinkTypeId")))
  
  return(PostLinks_df)}

#Posts
Posts <- function(path){
  #Path to XML file
  Posts_xml <- path
  
  #Read XML file
  Posts_doc <- read_xml(Posts_xml, useInternalNode = TRUE)
  
  #Get rows
  Posts_rows <- xml_children(Posts_doc)
  
  #Create data frame
  Posts_df <- data.frame(
    Id = as.integer(xml_attr(Posts_rows, "Id")),
    PostTypeId = as.integer(xml_attr(Posts_rows, "PostTypeId")),
    AcceptedAnswerId = as.integer(xml_attr(Posts_rows, "AcceptedAnswerId")),
    ParentId = as.integer(xml_attr(Posts_rows, "ParentId")),
    CreationDate = as.Date(xml_attr(Posts_rows, "CreationDate")),
    Score = as.integer(xml_attr(Posts_rows, "Score")),
    ViewCount = as.integer(xml_attr(Posts_rows, "ViewCount")),
    Body = as.character(xml_attr(Posts_rows, "Body")),
    OwnerUserId = as.integer(xml_attr(Posts_rows, "OwnerUserId")),
    OwnerDisplayName = as.character(xml_attr(Posts_rows, "OwnerDisplayName")),
    LastEditorUserId = as.integer(xml_attr(Posts_rows, "LastEditorUserId")),
    LastEditorDisplayName = as.character(xml_attr(Posts_rows, "LastEditorDisplayName")),
    LastEditDate = as.Date(xml_attr(Posts_rows, "LastEditDate")),
    LastActivityDate = as.Date(xml_attr(Posts_rows, "LastActivityDate")),
    Title = as.character(xml_attr(Posts_rows, "Title")),
    Tags = as.character(xml_attr(Posts_rows, "Tags")),
    AnswerCount = as.integer(xml_attr(Posts_rows, "AnswerCount")),
    CommentCount = as.integer(xml_attr(Posts_rows, "CommentCount")),
    FavoriteCount = as.integer(xml_attr(Posts_rows, "FavoriteCount")),
    ClosedDate = as.Date(xml_attr(Posts_rows, "ClosedDate")),
    CommunityOwnedDate = as.Date(xml_attr(Posts_rows, "CommunityOwnedDate")),
    ContentLicense = as.character(xml_attr(Posts_rows, "ContentLicense")))

  return(Posts_df)}

#Tags
Tags <- function(path){
  #Path to XML file
  Tags_xml <- path
  
  #Read XML files
  Tags_doc <- read_xml(Tags_xml, useInternalNode = TRUE)
  
  #Get rows
  Tags_rows <- xml_children(Tags_doc)
  
  #Create data frame
  Tags_df <- data.frame(
    Id = as.integer(xml_attr(Tags_rows, "Id")),
    TagName = as.character(xml_attr(Tags_rows, "TagName")),
    Count = as.integer(xml_attr(Tags_rows, "Count")),
    ExcerptPostId = as.integer(xml_attr(Tags_rows, "ExcerptPostId")),
    WikiPostId = as.integer(xml_attr(Tags_rows, "WikiPostId")))
  
  return(Tags_df)}

#Users
Users <- function(path){
  #Path to XML file
  Users_xml <- path
  
  #Read XML files
  Users_doc <- read_xml(Users_xml, useInternalNode = TRUE)
  
  #Get rows
  Users_rows <- xml_children(Users_doc)
  
  #Create data frame
  Users_df <- data.frame(
    Id = as.integer(xml_attr(Users_rows, "Id")),
    Reputation = as.integer(xml_attr(Users_rows, "Reputation")),
    CreationDate = as.Date(xml_attr(Users_rows, "CreationDate")),
    DisplayName = as.character(xml_attr(Users_rows, "DisplayName")),
    LastAccessDate = as.Date(xml_attr(Users_rows, "LastAccessDate")),
    WebsiteUrl = as.character(xml_attr(Users_rows, "WebsiteUrl")),
    Location = as.character(xml_attr(Users_rows, "Location")),
    AboutMe = as.character(xml_attr(Users_rows, "AboutMe")),
    Views = as.integer(xml_attr(Users_rows, "Views")),
    UpVotes = as.integer(xml_attr(Users_rows, "UpVotes")),
    DownVotes = as.integer(xml_attr(Users_rows, "DownVotes")),
    ProfileImageUrl = as.character(xml_attr(Users_rows, "ProfileImageUrl")),
    AccountId = as.integer(xml_attr(Users_rows, "AccountId")))
  
  return(Users_df)}

#Votes
Votes <- function(path){
  #Path to XML file
  Votes_xml <- path
  
  #Read XML files
  Votes_doc <- read_xml(Votes_xml, useInternalNode = TRUE)
  
  #Get rows
  Votes_rows <- xml_children(Votes_doc)
  
  #Create data frame
  Votes_df <- data.frame(
    Id = as.integer(xml_attr(Votes_rows, "Id")),
    PostId = as.integer(xml_attr(Votes_rows, "PostId")),
    VoteTypeId = as.integer(xml_attr(Votes_rows, "VoteTypeId")),
    UserId = as.integer(xml_attr(Votes_rows, "UserId")),
    CreationDate = as.Date(xml_attr(Votes_rows, "CreationDate")),
    BountyAmount = as.integer(xml_attr(Votes_rows, "BountyAmount")))
  
  return(Votes_df)}

#Data Viewer
#For a quick look at the data frame. Top 10 rows are shown.
Data_View <- function(df, cptn, algnmnt)
  kable(head(df, n = 10), caption = cptn, align = algnmnt) %>% 
  kable_styling(bootstrap_options = c('striped', 'hover', 'responsive', 'condensed')) %>%  
  scroll_box(width = "100%", height = "200px")

#No NAs in a Column
#Returns a data frame without the rows of which has the value NA of selected column.
No_NAs <- function(df, col)
  sqldf::sqldf(sprintf("
  SELECT
      ROW_NUMBER() OVER(ORDER BY %s) AS [#],
      * 
  FROM 
      %s 
  WHERE 
      %s IS NOT NULL
  ", col, df, col))

#Order by
#Returns a data frame where it is ordered according to given column
Order_By <- function(df, col)
  sqldf::sqldf(sprintf("
  SELECT
      *
  FROM
      %s
  ORDER BY 
      %s DESC
  ", df, col))

#Badge Distributions
#Returns a data frame where badges are ordered according to their usage counts.
Badge_Dist <- function(Badges_df)
  sqldf::sqldf("
  SELECT
      Name,
      COUNT(*) AS Volume
  FROM
      Badges_df
  GROUP BY
      Name
  ORDER BY
      Volume DESC
  ")

#Top Answerers
#Returns a data frame of users ordered according to their scores.
Top_Answerers <- function(Users_df, Posts_df)
  sqldf::sqldf("
  SELECT 
      Users_df.Id,
      DisplayName,
      Count(Posts_df.Id) AS Answers,
      CAST(AVG(CAST(Score AS float)) as numeric(6,2)) AS [Average Answer Score]
  FROM
      Posts_df
  INNER JOIN
      Users_df ON Users_df.Id = OwnerUserId
  WHERE 
      PostTypeId = 2 and CommunityOwnedDate IS NULL and ClosedDate IS NULL
  GROUP BY
      Users_df.Id, DisplayName
  HAVING
      Count(Posts_df.Id) > 10
  ORDER BY
      [Average Answer Score] DESC
  ")

#Most Used Tags
#Returns a data frame where tags are ordered according to their usage counts.
Words <- function(Tags_df)
  sqldf::sqldf("
  SELECT 
      TagName,
      Count
  FROM
      Tags_df
  ORDER BY
      Count DESC
  ")

#Top Users by Country
#Returns a data frame of users ordered by their reputation of given country.
Top_Users <- function(Users_df, Country)
  sqldf::sqldf(sprintf("
  SELECT
      ROW_NUMBER() OVER(ORDER BY Reputation DESC) AS [#], 
      Id,
      DisplayName,
      Reputation
  FROM
      %s
  WHERE
      LOWER(Location) LIKE LOWER('%s')
  ORDER BY
      Reputation DESC
  ", Users_df, Country))

#Most Controversial Answers
#Returns a data frame of answers to posts where answers are the most controversial.
#Meaning, those answers had the high up and down votes at the same time.
Controversial <- function(Votes_df, Posts_df)
  sqldf::sqldf("
  SELECT 
      p.ParentId [Post Id],
      p.id AS [Answer Id],
      up AS [Up Votes], 
      down AS [Down Votes] 
  FROM
      (SELECT
          PostId, 
          SUM(CASE WHEN VoteTypeId = 2 THEN 1 ELSE 0 END) AS up, 
          SUM(CASE WHEN VoteTypeId = 3 THEN 1 ELSE 0 END) AS down
      FROM 
          Votes_df
      WHERE 
          VoteTypeId in (2,3)
      GROUP BY 
          PostId) AS a
  JOIN
      Posts_df p ON a.PostId = p.Id
  WHERE down > (up * 0.5) AND p.CommunityOwnedDate IS NULL AND p.ClosedDate IS NULL
  ORDER BY 
      up DESC
  ")

#Distribution of Posts Count by Years or Months
#Returns Posts grouped by year or month
Total_By <- function(Posts_df, Ymd, as)
  sqldf::sqldf(sprintf("
  SELECT
      strftime('%s', CreationDate * 3600 * 24, 'unixepoch') AS %s, 
      COUNT(*) AS Volume
  FROM
      %s
  GROUP BY
      strftime('%s', CreationDate * 3600 * 24, 'unixepoch')
  ORDER BY
      %s
  ", Ymd, as, Posts_df, Ymd, as))

#Monthly Total Created
#Returns a data frame grouped by exact month
Monthly <- function(df)
  sqldf::sqldf("
  SELECT
      CreationDate,
      COUNT(*) AS Volume
  FROM
      df
  GROUP BY
      strftime('%Y', CreationDate * 3600 * 24, 'unixepoch'),
      strftime('%m', CreationDate * 3600 * 24, 'unixepoch')
  ")

#Posts Grouped by Exact Months and Types
# Returns a data frame grouped by exact months and types
Posts_TT <- function(Posts_df)
  sqldf::sqldf("
  SELECT
      CreationDate,
      PostTypeId,
      COUNT(*) AS Volume
  FROM
      Posts_df
  GROUP BY
      strftime('%Y', CreationDate * 3600 * 24, 'unixepoch'),
      strftime('%m', CreationDate * 3600 * 24, 'unixepoch'),
      PostTypeId
  ")

#Posts Grouped by Type
Posts_GRP <- function(Posts_df)
  sqldf::sqldf("
  SELECT
      PostTypeId,
      COUNT(*) AS Volume
  FROM
      Posts_df
  GROUP BY
      PostTypeId
  ")

#--------------------------------------------------------------------------------------------------------------------#

#academia.stackexchange.com
#Path to academia XML files
academia_Badges_xml <- "academia.stackexchange.com\\Badges.xml"
academia_Comments_xml <- "academia.stackexchange.com\\Comments.xml"
academia_PostHistory_xml <- "academia.stackexchange.com\\PostHistory.xml"
academia_PostLinks_xml <- "academia.stackexchange.com\\PostLinks.xml"
academia_Posts_xml <- "academia.stackexchange.com\\Posts.xml"
academia_Tags_xml <- "academia.stackexchange.com\\Tags.xml"
academia_Users_xml <- "academia.stackexchange.com\\Users.xml"
academia_Votes_xml <- "academia.stackexchange.com\\Votes.xml"

#Data Frames
#Data frames will be created in parallel. Hence, creating multisession
plan(multisession, gc = TRUE)

#Promises
academia_Badges_df %<-% Badges(academia_Badges_xml)
academia_Comments_df %<-% Comments(academia_Comments_xml)
academia_PostHistory_df %<-% PostHistory(academia_PostHistory_xml)
academia_PostLinks_df %<-% PostLinks(academia_PostLinks_xml)
academia_Posts_df %<-% Posts(academia_Posts_xml)
academia_Tags_df %<-% Tags(academia_Tags_xml)
academia_Users_df %<-% Users(academia_Users_xml)
academia_Votes_df %<-% Votes(academia_Votes_xml)

#Creating data frames
academia_dfs <- lapply(ls(pattern = "academia"), get)

#Continue rest in sequential
plan(sequential)

#Exploratory Analysis of Posts
#Data View, Variables and Summary
Data_View(academia_Posts_df, 'Posts', "ccccccclccccccllcccccc")
str(academia_Posts_df, vec.len = 1, nchar.max = 80)

#Summary of Posts
Data_View(summary(academia_Posts_df), "Summary")

#Monthly total posts
#time series
ts_plot(data.frame(Monthly(academia_Posts_df)), line.mode = "lines", width = 1, dash = NULL,
  color = "#69b3a2", slider = TRUE, type = "single", Xtitle = NULL,
  Ytitle = NULL, title = "Monthly Post Volume", Xgrid = FALSE, Ygrid = FALSE)

#Total distribution of the posts by months
#barplot
plot_ly(x = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"), 
        y = Total_By("academia_Posts_df", "%m", "Month")$Volume, 
        name = "Months",
        type = "bar",
        marker = list(color = 'rgb(0, 128, 128)', line = list(color = 'rgb(8, 48, 107)', width = 1.5))) %>%
  layout(title = "Posts by Months",
         xaxis = list(categoryorder = "array", 
                      categoryarray = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                                        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"), 
                      tickmode = "linear"))

#Distribution of the posts by the years
#barplot
plot_ly(x = c(2011:2020), 
        y = Total_By("academia_Posts_df", "%Y", "Year")$Volume, 
        name = "Years",
        type = "bar",
        marker = list(color = 'rgb(0, 128, 128)', line = list(color = 'rgb(8, 48, 107)', width = 1.5))) %>%
  layout(title = "Posts by Years",
         xaxis = list(categoryorder = "array", 
                      categoryarray = c(2011:2020), 
                      tickmode = "linear"))

#Posts by their types
#Pie chart of Posts by their types
plot_ly(aca_df_GRP, labels = ~PostTypeId, values = ~Volume, type = 'pie') %>%
  layout(title = "Distribution of Posts by Their Types")

#Monthly question volume
#time series of questions
ts_plot(aca_df_TT[aca_df_TT$PostTypeId == 1, c("CreationDate", "Volume")], line.mode = "lines", width = 1, dash = NULL,
  color = "#69b3a2", slider = TRUE, type = "single", Xtitle = NULL,
  Ytitle = NULL, title = "Monthly Question Volume", Xgrid = FALSE, Ygrid = FALSE)

#Monthly answers volume
#time series of answers
ts_plot(aca_df_TT[aca_df_TT$PostTypeId == 2, c("CreationDate", "Volume")], line.mode = "lines", width = 1, dash = NULL,
  color = "#69b3a2", slider = TRUE, type = "single", Xtitle = NULL,
  Ytitle = NULL, title = "Monthly Answer Volume", Xgrid = FALSE, Ygrid = FALSE)

#Exploratory Analysis of Users
#Data View, Variables and Summary
Data_View(academia_Users_df, 'Users', "ccccclllccccc")
str(academia_Users_df, vec.len = 1, nchar.max = 80)

#Summary of Users
Data_View(summary(academia_Users_df), "Summary")

#Monthly new Users
#time series
ts_plot(within(Monthly(academia_Users_df), Cumulative <- cumsum(Volume)), line.mode = "lines", width = 1, dash = NULL,
  color = "#69b3a2", slider = TRUE, type = "single", Xtitle = NULL,
  Ytitle = NULL, title = "Monthly New User", Xgrid = FALSE, Ygrid = FALSE)

#Active to not active user ratio of last 180 days
#Last 180 days active users to not active users pie chart
plot_ly(data = data.frame(Activity = c(nrow(academia_Users_df[academia_Users_df$LastAccessDate >= as.Date(today(), format='%Y-%m-%d') - 180, ]), 
                                     nrow(academia_Users_df[academia_Users_df$LastAccessDate < as.Date(today(), format='%Y-%m-%d') - 180, ])),
                          row.names = c("Active", "Not Active")), labels = c("Active", "Not Active"), values = ~Activity, type = "pie") %>%
  layout(title = "Last 180 Days Active Users to Not Active Users Ratio",
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))

#Top 10 Users on academia.stackexchange.com based on their reputations
Data_View(Order_By("academia_Users_df", "Reputation")[1:10, c("Id", "DisplayName", "Reputation")], 'Top 10 Users', "ccc")

#Top 10 Poland Users
Data_View(Top_Users("academia_Users_df", "Poland"), 'Top 10 Poland Users', "cclc")

#Top 10 Answerers
Data_View(Top_Answerers(academia_Users_df, academia_Posts_df), 'Top Answerers', "llcc")

#Exploratory Analysis of Badges
#Data View, Variables and Summary
Data_View(academia_Badges_df, 'Badges', "cclccc")
str(academia_Badges_df, vec.len = 1, nchar.max = 80)

#Summary of Badges
Data_View(summary(academia_Badges_df), "Summary")

#Top 20 Badges on academia.stackexchange.com are shown in the figure below according to their usages
#barplot
plot_ly(x = Badge_Dist(academia_Badges_df)[1:20, "Name"], 
        y = Badge_Dist(academia_Badges_df)[1:20, "Volume"], 
        name = "Badges",
        type = "bar",
        marker = list(color = 'rgb(0, 128, 128)', line = list(color = 'rgb(8, 48, 107)', width = 1.5))) %>%
  layout(title = "Top 20 Badges",
         xaxis = list(categoryorder = "array", 
                      categoryarray = Badge_Dist(academia_Badges_df)[1:20, "Name"],
                      tickmode = "linear"))

#Exploratory Analysis of Comments
#Data View, Variables and Summary
Data_View(academia_Comments_df, 'Comments', "ccclcccc")
str(academia_Comments_df, vec.len = 1, nchar.max = 80)

#Summary of Comments
Data_View(summary(academia_Comments_df), "Summary")

#Ratio of users who has display name or user id in comments
#Where UserDisplayName exits UserId is NA and vice versa.
plot_ly(data = data.frame(Activity = c(nrow(academia_Comments_df) - nrow(No_NAs("academia_Comments_df", "UserDisplayName")),
                                       nrow(No_NAs("academia_Comments_df", "UserDisplayName"))),
                          row.names = c("User Display Name", "User Id")), labels = c("User Display Name", "User Id"), values = ~Activity, type = "pie") %>%
  layout(title = "Users with Display Name to Id Ratio",
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))

#Exploratory Analysis of Tags
#Data View, Variables and Summary
Data_View(academia_Tags_df, 'Tags', "clccc")
str(academia_Tags_df, vec.len = 1, nchar.max = 80)

#Summary of Tags
Data_View(summary(academia_Tags_df), "Summary")

#Most used tags on academia.stackexchange.com are shown as word cloud below
#Word Cloud
wordcloud(words = Words(academia_Tags_df)$TagName, freq = Words(academia_Tags_df)$Count, min.freq = 1, max.words = 200, random.order = FALSE, rot.per = 0.35, colors = brewer.pal(8, "Dark2"))

#Exploratory Analysis of Votes
#Data View, Variables and Summary
Data_View(academia_Votes_df, 'Votes', "ccccc")
str(academia_Votes_df, vec.len = 1, nchar.max = 80)

#Summary of Votes
Data_View(summary(academia_Votes_df), "Summary")

#Most controversial answers
Data_View(Controversial(academia_Votes_df, academia_Posts_df), 'Most Controversial Answers', "cccc")

#Exploratory Analysis of PostHistory
#Data View, Variables and Summary
Data_View(academia_PostHistory_df, 'PostHistory', "ccclcccclc")
str(academia_PostHistory_df, vec.len = 1, nchar.max = 80)

#summary of PostHistory
Data_View(summary(academia_PostHistory_df), "Summary")

#Exploratory Analysis of PostLinks
#Data View, Variables and Summary
Data_View(academia_PostLinks_df, 'PostLinks', "ccccc")
str(academia_PostLinks_df, vec.len = 1, nchar.max = 80)

#Summary of PostLinks
Data_View(summary(academia_PostLinks_df), "Summary")