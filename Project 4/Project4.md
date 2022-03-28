```python
import pandas as pd
import numpy as np
```


```python
Badges = pd.read_csv("travel_stackexchange_com/Badges.csv.gz", compression = "gzip")
Comments = pd.read_csv("travel_stackexchange_com/Comments.csv.gz", compression = "gzip")
PostLinks = pd.read_csv("travel_stackexchange_com/PostLinks.csv.gz", compression = "gzip")
Posts = pd.read_csv("travel_stackexchange_com/Posts.csv.gz", compression = "gzip")
Tags = pd.read_csv("travel_stackexchange_com/Tags.csv.gz", compression = "gzip")
Users = pd.read_csv("travel_stackexchange_com/Users.csv.gz", compression = "gzip")
Votes = pd.read_csv("travel_stackexchange_com/Votes.csv.gz", compression = "gzip")
```


```python
import os, os.path
import sqlite3
import tempfile
```


```python
# path to database file
baza = os.path.join(tempfile.mkdtemp(), 'example.db')
if os.path.isfile(baza): # if this file already exists...
    os.remove(baza) # ...we will remove it
    
conn = sqlite3.connect(baza) # create the connection

Badges.to_sql("Badges", conn) # import the data frame into the database
Comments.to_sql("Comments", conn)
PostLinks.to_sql("PostLinks", conn)
Posts.to_sql("Posts", conn)
Tags.to_sql("Tags", conn)
Users.to_sql("Users", conn)
Votes.to_sql("Votes", conn)
```


```python
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
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Title</th>
      <th>NumLinks</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Is there a way to find out if I need a transit...</td>
      <td>594</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Do I need a visa to transit (or layover) in th...</td>
      <td>585</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Should my first trip be to the country which i...</td>
      <td>331</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Should I submit bank statements when applying ...</td>
      <td>259</td>
    </tr>
    <tr>
      <th>4</th>
      <td>How much electronics and other valuables can I...</td>
      <td>197</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>4867</th>
      <td>"Speaking" Korean without really speaking Kore...</td>
      <td>1</td>
    </tr>
    <tr>
      <th>4868</th>
      <td>"Purpose of Travel" document for Canadian visa</td>
      <td>1</td>
    </tr>
    <tr>
      <th>4869</th>
      <td>"Mudflat hiking" (wadlopen in Dutch) in the Fr...</td>
      <td>1</td>
    </tr>
    <tr>
      <th>4870</th>
      <td>"Do not board" message at the airport check-in?</td>
      <td>1</td>
    </tr>
    <tr>
      <th>4871</th>
      <td>"Cheek kissing" between men in Mongolia</td>
      <td>1</td>
    </tr>
  </tbody>
</table>
<p>4872 rows × 2 columns</p>
</div>




```python
RelatedTab = PostLinks[['RelatedPostId']].rename(columns = {'RelatedPostId':'PostId'}).groupby(['PostId']).size().reset_index(name = 'NumLinks')
sol1 = RelatedTab.merge(Posts[Posts.PostTypeId == 1][['Id', 'Title']], left_on = 'PostId', right_on = 'Id', how = 'inner')[['Title', 'NumLinks']]
sol1 = sol1.sort_values(by = ['NumLinks', 'Title'], ascending = False).reset_index(drop = True)
sol1
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Title</th>
      <th>NumLinks</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Is there a way to find out if I need a transit...</td>
      <td>594</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Do I need a visa to transit (or layover) in th...</td>
      <td>585</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Should my first trip be to the country which i...</td>
      <td>331</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Should I submit bank statements when applying ...</td>
      <td>259</td>
    </tr>
    <tr>
      <th>4</th>
      <td>How much electronics and other valuables can I...</td>
      <td>197</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>4867</th>
      <td>"Speaking" Korean without really speaking Kore...</td>
      <td>1</td>
    </tr>
    <tr>
      <th>4868</th>
      <td>"Purpose of Travel" document for Canadian visa</td>
      <td>1</td>
    </tr>
    <tr>
      <th>4869</th>
      <td>"Mudflat hiking" (wadlopen in Dutch) in the Fr...</td>
      <td>1</td>
    </tr>
    <tr>
      <th>4870</th>
      <td>"Do not board" message at the airport check-in?</td>
      <td>1</td>
    </tr>
    <tr>
      <th>4871</th>
      <td>"Cheek kissing" between men in Mongolia</td>
      <td>1</td>
    </tr>
  </tbody>
</table>
<p>4872 rows × 2 columns</p>
</div>




```python
sol1.equals(query1)
```




    True




```python
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
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>DisplayName</th>
      <th>Age</th>
      <th>Location</th>
      <th>FavoriteTotal</th>
      <th>MostFavoriteQuestion</th>
      <th>MostFavoriteQuestionLikes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Mark Mayo</td>
      <td>37.0</td>
      <td>Sydney, New South Wales, Australia</td>
      <td>467.0</td>
      <td>Tactics to avoid getting harassed by corrupt p...</td>
      <td>42.0</td>
    </tr>
    <tr>
      <th>1</th>
      <td>hippietrail</td>
      <td>NaN</td>
      <td>Oaxaca, Mexico</td>
      <td>444.0</td>
      <td>OK we're all adults here, so really, how on ea...</td>
      <td>79.0</td>
    </tr>
    <tr>
      <th>2</th>
      <td>RoflcoptrException</td>
      <td>NaN</td>
      <td>None</td>
      <td>294.0</td>
      <td>How to avoid drinking vodka?</td>
      <td>29.0</td>
    </tr>
    <tr>
      <th>3</th>
      <td>JonathanReez</td>
      <td>26.0</td>
      <td>Prague, Czech Republic</td>
      <td>221.0</td>
      <td>What is the highest viewing spot in London tha...</td>
      <td>17.0</td>
    </tr>
    <tr>
      <th>4</th>
      <td>nsn</td>
      <td>NaN</td>
      <td>None</td>
      <td>214.0</td>
      <td>How do airlines determine ticket prices?</td>
      <td>40.0</td>
    </tr>
    <tr>
      <th>5</th>
      <td>Gagravarr</td>
      <td>NaN</td>
      <td>Oxford, United Kingdom</td>
      <td>151.0</td>
      <td>Are there other places with gardens like those...</td>
      <td>10.0</td>
    </tr>
    <tr>
      <th>6</th>
      <td>Andrew Grimm</td>
      <td>38.0</td>
      <td>Sydney, Australia</td>
      <td>120.0</td>
      <td>OK we're all nerds here, so really, how on ear...</td>
      <td>8.0</td>
    </tr>
    <tr>
      <th>7</th>
      <td>VMAtm</td>
      <td>33.0</td>
      <td>Tampa, FL, United States</td>
      <td>109.0</td>
      <td>Is there a good website to plan a trip via tra...</td>
      <td>34.0</td>
    </tr>
    <tr>
      <th>8</th>
      <td>jrdioko</td>
      <td>NaN</td>
      <td>None</td>
      <td>100.0</td>
      <td>What is the most comfortable way to sleep on a...</td>
      <td>21.0</td>
    </tr>
    <tr>
      <th>9</th>
      <td>Gayot Fow</td>
      <td>NaN</td>
      <td>London, United Kingdom</td>
      <td>98.0</td>
      <td>Should I submit bank statements when applying ...</td>
      <td>18.0</td>
    </tr>
  </tbody>
</table>
</div>




```python
sol21 = Posts.merge(Users, left_on = 'OwnerUserId', right_on = 'Id', how = 'inner', sort = False)
sol21 = sol21[sol21.PostTypeId == 1 & sol21.FavoriteCount.notnull()].rename(columns = {"Title": "MostFavoriteQuestion"})

sol22 = sol21.groupby(['OwnerUserId'], as_index = False).agg(FavoriteTotal = pd.NamedAgg(column = 'FavoriteCount', aggfunc = sum),
                                                             MostFavoriteQuestionLikes = pd.NamedAgg(column = 'FavoriteCount', aggfunc = max))
sol22 = sol22.sort_values(by = 'FavoriteTotal', ascending = False)
sol22 = sol22.merge(sol21, left_on = ['OwnerUserId', 'MostFavoriteQuestionLikes'], right_on = ['OwnerUserId', 'FavoriteCount'], how = 'inner', sort = False)
sol2 = sol22[['DisplayName', 'Age', 'Location', 'FavoriteTotal', 'MostFavoriteQuestion', 'MostFavoriteQuestionLikes']].nlargest(10, 'FavoriteTotal')
sol2
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>DisplayName</th>
      <th>Age</th>
      <th>Location</th>
      <th>FavoriteTotal</th>
      <th>MostFavoriteQuestion</th>
      <th>MostFavoriteQuestionLikes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Mark Mayo</td>
      <td>37.0</td>
      <td>Sydney, New South Wales, Australia</td>
      <td>467.0</td>
      <td>Tactics to avoid getting harassed by corrupt p...</td>
      <td>42.0</td>
    </tr>
    <tr>
      <th>1</th>
      <td>hippietrail</td>
      <td>NaN</td>
      <td>Oaxaca, Mexico</td>
      <td>444.0</td>
      <td>OK we're all adults here, so really, how on ea...</td>
      <td>79.0</td>
    </tr>
    <tr>
      <th>2</th>
      <td>RoflcoptrException</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>294.0</td>
      <td>How to avoid drinking vodka?</td>
      <td>29.0</td>
    </tr>
    <tr>
      <th>3</th>
      <td>JonathanReez</td>
      <td>26.0</td>
      <td>Prague, Czech Republic</td>
      <td>221.0</td>
      <td>What is the highest viewing spot in London tha...</td>
      <td>17.0</td>
    </tr>
    <tr>
      <th>4</th>
      <td>nsn</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>214.0</td>
      <td>How do airlines determine ticket prices?</td>
      <td>40.0</td>
    </tr>
    <tr>
      <th>5</th>
      <td>Gagravarr</td>
      <td>NaN</td>
      <td>Oxford, United Kingdom</td>
      <td>151.0</td>
      <td>Are there other places with gardens like those...</td>
      <td>10.0</td>
    </tr>
    <tr>
      <th>6</th>
      <td>Andrew Grimm</td>
      <td>38.0</td>
      <td>Sydney, Australia</td>
      <td>120.0</td>
      <td>OK we're all nerds here, so really, how on ear...</td>
      <td>8.0</td>
    </tr>
    <tr>
      <th>7</th>
      <td>VMAtm</td>
      <td>33.0</td>
      <td>Tampa, FL, United States</td>
      <td>109.0</td>
      <td>Is there a good website to plan a trip via tra...</td>
      <td>34.0</td>
    </tr>
    <tr>
      <th>8</th>
      <td>jrdioko</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>100.0</td>
      <td>What is the most comfortable way to sleep on a...</td>
      <td>21.0</td>
    </tr>
    <tr>
      <th>9</th>
      <td>Gayot Fow</td>
      <td>NaN</td>
      <td>London, United Kingdom</td>
      <td>98.0</td>
      <td>Should I submit bank statements when applying ...</td>
      <td>18.0</td>
    </tr>
  </tbody>
</table>
</div>




```python
sol2.equals(query2)
```




    True




```python
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
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Title</th>
      <th>CommentsTotalScore</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>How to intentionally get denied entry to the U...</td>
      <td>75</td>
    </tr>
    <tr>
      <th>1</th>
      <td>How can I deal with people asking to switch se...</td>
      <td>32</td>
    </tr>
    <tr>
      <th>2</th>
      <td>What is France's traditional costume?</td>
      <td>26</td>
    </tr>
    <tr>
      <th>3</th>
      <td>What's the longest scheduled public bus ride i...</td>
      <td>25</td>
    </tr>
    <tr>
      <th>4</th>
      <td>How does President Trump's travel ban affect n...</td>
      <td>25</td>
    </tr>
    <tr>
      <th>5</th>
      <td>Can I have a watermelon in hand luggage?</td>
      <td>25</td>
    </tr>
    <tr>
      <th>6</th>
      <td>Caught speeding 111 Mph (179 km/h) in Californ...</td>
      <td>24</td>
    </tr>
    <tr>
      <th>7</th>
      <td>Returning US Citizen lost passport in Canada</td>
      <td>23</td>
    </tr>
    <tr>
      <th>8</th>
      <td>Legalities and safety concerns of visiting pro...</td>
      <td>20</td>
    </tr>
    <tr>
      <th>9</th>
      <td>India just demonetized all Rs 500 &amp; 1000 notes...</td>
      <td>20</td>
    </tr>
  </tbody>
</table>
</div>




```python
CmtTotScr = Comments.groupby(['PostId', 'UserId'], as_index = False).agg(CommentsTotalScore = pd.NamedAgg(column = 'Score', aggfunc = sum))
sol3 = CmtTotScr.merge(Posts[Posts.PostTypeId == 1], left_on = ['PostId', 'UserId'], right_on = ['Id', 'OwnerUserId'], how = 'inner', sort = False)
sol3 = sol3.sort_values(by = ['CommentsTotalScore', 'Title'], ascending = False).reset_index(drop = True).nlargest(10, 'CommentsTotalScore')[['Title', 'CommentsTotalScore']]
sol3
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Title</th>
      <th>CommentsTotalScore</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>How to intentionally get denied entry to the U...</td>
      <td>75</td>
    </tr>
    <tr>
      <th>1</th>
      <td>How can I deal with people asking to switch se...</td>
      <td>32</td>
    </tr>
    <tr>
      <th>2</th>
      <td>What is France's traditional costume?</td>
      <td>26</td>
    </tr>
    <tr>
      <th>3</th>
      <td>What's the longest scheduled public bus ride i...</td>
      <td>25</td>
    </tr>
    <tr>
      <th>4</th>
      <td>How does President Trump's travel ban affect n...</td>
      <td>25</td>
    </tr>
    <tr>
      <th>5</th>
      <td>Can I have a watermelon in hand luggage?</td>
      <td>25</td>
    </tr>
    <tr>
      <th>6</th>
      <td>Caught speeding 111 Mph (179 km/h) in Californ...</td>
      <td>24</td>
    </tr>
    <tr>
      <th>7</th>
      <td>Returning US Citizen lost passport in Canada</td>
      <td>23</td>
    </tr>
    <tr>
      <th>8</th>
      <td>Legalities and safety concerns of visiting pro...</td>
      <td>20</td>
    </tr>
    <tr>
      <th>9</th>
      <td>India just demonetized all Rs 500 &amp; 1000 notes...</td>
      <td>20</td>
    </tr>
  </tbody>
</table>
</div>




```python
sol3.equals(query3)
```




    True




```python
conn.close()
```
