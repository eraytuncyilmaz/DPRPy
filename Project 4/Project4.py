import pandas as pd
import numpy as np

Badges = pd.read_csv("travel_stackexchange_com/Badges.csv.gz", compression = "gzip")
Comments = pd.read_csv("travel_stackexchange_com/Comments.csv.gz", compression = "gzip")
PostLinks = pd.read_csv("travel_stackexchange_com/PostLinks.csv.gz", compression = "gzip")
Posts = pd.read_csv("travel_stackexchange_com/Posts.csv.gz", compression = "gzip")
Tags = pd.read_csv("travel_stackexchange_com/Tags.csv.gz", compression = "gzip")
Users = pd.read_csv("travel_stackexchange_com/Users.csv.gz", compression = "gzip")
Votes = pd.read_csv("travel_stackexchange_com/Votes.csv.gz", compression = "gzip")

import os, os.path
import sqlite3
import tempfile

# path to database file
baza = os.path.join(tempfile.mkdtemp(), 'example.db')
if os.path.isfile(baza): # if this file already exists...
    os.remove(baza) # ...we will remove it
    
conn = sqlite3.connect(baza) # create the connection

# import the data frame into the database
Badges.to_sql("Badges", conn) 
Comments.to_sql("Comments", conn)
PostLinks.to_sql("PostLinks", conn)
Posts.to_sql("Posts", conn)
Tags.to_sql("Tags", conn)
Users.to_sql("Users", conn)
Votes.to_sql("Votes", conn)

#1
query1 = pd.read_sql_query("""
SELECT 
    Posts.Title, 
    RelatedTab.NumLinks
FROM
    (SELECT 
        RelatedPostId AS PostId, 
        COUNT(*) AS NumLinks
    FROM 
        PostLinks
    GROUP BY 
        RelatedPostId) AS RelatedTab
JOIN 
    Posts ON RelatedTab.PostId = Posts.Id
WHERE 
    Posts.PostTypeId = 1
ORDER BY 
    NumLinks DESC
""", conn)
query1 = query1.sort_values(by = ['NumLinks', 'Title'], ascending = False).reset_index(drop = True)
query1

RelatedTab = PostLinks[['RelatedPostId']].rename(columns = {'RelatedPostId':'PostId'}).groupby(['PostId']).size().reset_index(name = 'NumLinks')
sol1 = RelatedTab.merge(Posts[Posts.PostTypeId == 1][['Id', 'Title']], left_on = 'PostId', right_on = 'Id', how = 'inner')[['Title', 'NumLinks']]
sol1 = sol1.sort_values(by = ['NumLinks', 'Title'], ascending = False).reset_index(drop = True)
sol1

sol1.equals(query1)

#2
query2 = pd.read_sql_query("""
SELECT
    Users.DisplayName,
    Users.Age,
    Users.Location,
    SUM(Posts.FavoriteCount) AS FavoriteTotal,
    Posts.Title AS MostFavoriteQuestion,
    MAX(Posts.FavoriteCount) AS MostFavoriteQuestionLikes
FROM 
    Posts
JOIN 
    Users ON Users.Id = Posts.OwnerUserId
WHERE 
    Posts.PostTypeId = 1
GROUP BY 
    OwnerUserId
ORDER BY 
    FavoriteTotal DESC
LIMIT 10
""", conn)
query2

sol21 = Posts.merge(Users, left_on = 'OwnerUserId', right_on = 'Id', how = 'inner', sort = False)
sol21 = sol21[sol21.PostTypeId == 1 & sol21.FavoriteCount.notnull()].rename(columns = {"Title": "MostFavoriteQuestion"})

sol22 = sol21.groupby(['OwnerUserId'], as_index = False).agg(FavoriteTotal = pd.NamedAgg(column = 'FavoriteCount', aggfunc = sum),
                                                             MostFavoriteQuestionLikes = pd.NamedAgg(column = 'FavoriteCount', aggfunc = max))
sol22 = sol22.sort_values(by = 'FavoriteTotal', ascending = False)
sol22 = sol22.merge(sol21, left_on = ['OwnerUserId', 'MostFavoriteQuestionLikes'], right_on = ['OwnerUserId', 'FavoriteCount'], how = 'inner', sort = False)
sol2 = sol22[['DisplayName', 'Age', 'Location', 'FavoriteTotal', 'MostFavoriteQuestion', 'MostFavoriteQuestionLikes']].nlargest(10, 'FavoriteTotal')
sol2

sol2.equals(query2)

#3
query3 = pd.read_sql_query("""
SELECT
    Posts.Title,
    CmtTotScr.CommentsTotalScore
FROM 
    (SELECT
        PostID,
        UserID,
        SUM(Score) AS CommentsTotalScore
    FROM 
        Comments
    GROUP BY 
        PostID, 
        UserID
    ) AS CmtTotScr
    JOIN 
        Posts ON Posts.ID = CmtTotScr.PostID AND Posts.OwnerUserId = CmtTotScr.UserID
    WHERE 
        Posts.PostTypeId = 1
    ORDER BY 
        CmtTotScr.CommentsTotalScore DESC
    LIMIT 10
""", conn)
query3 = query3.sort_values(by = ['CommentsTotalScore', 'Title'], ascending = False).reset_index(drop = True)
query3

CmtTotScr = Comments.groupby(['PostId', 'UserId'], as_index = False).agg(CommentsTotalScore = pd.NamedAgg(column = 'Score', aggfunc = sum))
sol3 = CmtTotScr.merge(Posts[Posts.PostTypeId == 1], left_on = ['PostId', 'UserId'], right_on = ['Id', 'OwnerUserId'], how = 'inner', sort = False)
sol3 = sol3.sort_values(by = ['CommentsTotalScore', 'Title'], ascending = False).reset_index(drop = True).nlargest(10, 'CommentsTotalScore')[['Title', 'CommentsTotalScore']]
sol3

sol3.equals(query3)

conn.close()