library(sqldf)
library(data.table)
library(dplyr)
library(rmarkdown)
library(knitr)
library(kableExtra)

options(stringsAsFactors = FALSE)

Badges <- read.csv("C:\\Users\\erayt\\Desktop\\Data Processing With R and Python\\datas\\Badges.csv.gz")
Comments <- read.csv("C:\\Users\\erayt\\Desktop\\Data Processing With R and Python\\datas\\Comments.csv.gz")
PostLinks <- read.csv("C:\\Users\\erayt\\Desktop\\Data Processing With R and Python\\datas\\PostLinks.csv.gz")
Posts <- read.csv("C:\\Users\\erayt\\Desktop\\Data Processing With R and Python\\datas\\Posts.csv.gz")
Tags <- read.csv("C:\\Users\\erayt\\Desktop\\Data Processing With R and Python\\datas\\Tags.csv.gz")
Users <- read.csv("C:\\Users\\erayt\\Desktop\\Data Processing With R and Python\\datas\\Users.csv.gz")
Votes <- read.csv("C:\\Users\\erayt\\Desktop\\Data Processing With R and Python\\datas\\Votes.csv.gz")


#SQL Query 1

#SELECT Posts.Title, RelatedTab.NumLinks FROM
#   (SELECT RelatedPostId AS PostId, COUNT(*) AS NumLinks
#   FROM PostLinks
#   GROUP BY RelatedPostId) AS RelatedTab
#JOIN Posts ON RelatedTab.PostId = Posts.Id
#WHERE Posts.PostTypeId = 1
#ORDER BY Numlinks DESC

#sqldf
sqldf1 <- sqldf("
SELECT 
  Posts.Title, 
  RelatedTab.NumLinks 
FROM
( SELECT 
    RelatedPostId AS PostId, 
    COUNT(*) AS NumLinks
  FROM PostLinks
  GROUP BY RelatedPostId
) AS RelatedTab
JOIN Posts ON RelatedTab.PostId = Posts.Id
WHERE Posts.PostTypeId = 1
ORDER BY NumLinks DESC")

#base functions
base1part1 <- merge(
  aggregate(list(NumLinks = PostLinks$RelatedPostId), by = list(PostId = PostLinks$RelatedPostId), FUN = length), 
  Posts,
  by.x = "PostId", by.y = "Id", all.x = FALSE, all.y = FALSE)

base1part2 <- base1part1[base1part1$PostTypeId == 1, c("Title", "NumLinks")]

basefunctions1 <- base1part2[order(-base1part2$NumLinks),]

#dplyr
dplyr1 <- inner_join(
  PostLinks %>% group_by(RelatedPostId) %>% summarise(NumLinks = n()) %>% select(PostId = RelatedPostId, NumLinks),
  Posts %>% filter(PostTypeId == 1), by = c("PostId" = "Id")) %>% 
  select(Title, NumLinks) %>% arrange(desc(NumLinks))
  
#data.table
datatable1 <- setDT(PostLinks)[ , list(PostId = RelatedPostId, NumLinks = .N), by = "RelatedPostId"][setDT(Posts)[PostTypeId == 1], 
on = list(PostId == Id)][order(-NumLinks), list(Title, NumLinks), ][!is.na(NumLinks)]

#benchmark
microbenchmark <- microbenchmark::microbenchmark(
  sqldf = sqldf_solution,
  base = base_functions_solution,
  dplyr = dplyr_solution,
  data.table = datatable_solution
)

#stats
as.data.table(microbenchmark)[,.(lowestTime = min(time),
             medianTime = median(time),
             meanTime = mean(time),
             stdeviation = sd(time),
             maximumTime = max(time),
             instance = .N), 
             by = "expr"]

#result check
all_equal(
  sqldf_solution(),
  base_functions_solution())

all_equal(
  sqldf_solution(),
  dplyr_solution())

all_equal(
  sqldf_solution(),
  datatable_solution())


#SQL Query 2

#SELECT
#  Users.DisplayName,
#  Users.Age,
#  UsersLocation,
#  SUM(Posts.FavoriteCount) AS FavoriteTotal,
#  Posts.Title AS MostFavoriteQuestion,
#  MAX(Posts.FavoriteCount) AS MostFavoriteQuestionLikes
#FROM Posts
#JOIN Users ON Users.Id = Posts.OwnerUserId
#WHERE Posts.PostTypeId = 1
#GROUP BY OwnerUserId
#ORDER BY FavoriteTotal DESC
#LIMIT 10

#sqldf
sqldf2 <- sqldf("
SELECT
  Users.DisplayName,
  Users.Age,
  Users.Location,
  SUM(Posts.FavoriteCount) AS FavoriteTotal,
  Posts.Title AS MostFavoriteQuestion,
  MAX(Posts.FavoriteCount) AS MostFavoriteQuestionLikes
FROM Posts
JOIN Users ON Users.Id = Posts.OwnerUserId
WHERE Posts.PostTypeId = 1
GROUP BY OwnerUserId
ORDER BY FavoriteTotal DESC
LIMIT 10")

#base functions
base2part1 <- merge(Posts, Users, by.x = "OwnerUserId", by.y = "Id")
base2part2 <- base2part1[base2part1$PostTypeId == 1 & !is.na(base2part1$FavoriteCount),]

base2part3 <- do.call(data.frame, aggregate(x = base2part2$FavoriteCount, by = list(OwnerUserId = base2part2$OwnerUserId), 
                                            FUN = function(x) c(FavoriteCount = max(x), FavoriteTotal = sum(x))))
base2part4 <- base2part3[order(-base2part3$x.FavoriteTotal), ]

base2part5 <- merge(base2part4, data.frame(OwnerUserId = base2part2$OwnerUserId,
                                           DisplayName = base2part2$DisplayName,
                                           Age = base2part2$Age,
                                           Location = base2part2$Location,
                                           FavoriteCount = base2part2$FavoriteCount,
                                           MostFavoriteQuestion = base2part2$Title), 
                    by.x = c("OwnerUserId", "x.FavoriteCount"), by.y = c("OwnerUserId", "FavoriteCount"),
                    sort = FALSE)[1:10, c("DisplayName", "Age", "Location", "x.FavoriteTotal", "MostFavoriteQuestion", "x.FavoriteCount")]

colnames(base2part5) <- c("DisplayName", "Age", "Location", "FavoriteTotal", "MostFavoriteQuestion", "MostFavoriteQuestionLikes")

#dplyr
dplyr2 <- inner_join(Posts %>% filter(PostTypeId == 1, !is.na(FavoriteCount)), Users, by = c("OwnerUserId" = "Id")) %>% 
  group_by(OwnerUserId) %>%
  select(DisplayName, Age, Location, FavoriteCount, MostFavoriteQuestion = Title) %>%
  mutate(FavoriteTotal = sum(FavoriteCount)) %>%
  slice(MostFavoriteQuestionLikes = which.max(FavoriteCount)) %>%
  arrange(desc(FavoriteTotal)) %>% head(10) %>% ungroup() %>%
  select(DisplayName, Age, Location, FavoriteTotal, MostFavoriteQuestion, MostFavoriteQuestionLikes = FavoriteCount)

#data.table
datatable2 <- setDT(Users)[][setDT(Posts)[!is.na(FavoriteCount)][PostTypeId == 1], on = list(Id == OwnerUserId), nomatch=0][ ,
list(DisplayName = DisplayName[which.max(FavoriteCount)], 
     Age = Age[which.max(FavoriteCount)], 
     Location = Location[which.max(FavoriteCount)], 
     FavoriteTotal = sum(FavoriteCount), 
     MostFavoriteQuestion = Title[which.max(FavoriteCount)],
     MostFavoriteQuestionLikes = max(FavoriteCount)),
by = "Id"][, !"Id"][order(-FavoriteTotal)][1:10]

#benchmark
microbenchmark <- microbenchmark::microbenchmark(
  sqldf = sqldf_solution,
  base = base_functions_solution,
  dplyr = dplyr_solution,
  data.table = datatable_solution
)

#stats
as.data.table(microbenchmark)[,.(lowestTime = min(time),
             medianTime = median(time),
             meanTime = mean(time),
             stdeviation = sd(time),
             maximumTime = max(time),
             instance = .N), 
             by = "expr"]

#result check
all_equal(
  sqldf_solution(),
  base_functions_solution())

all_equal(
  sqldf_solution(),
  dplyr_solution())

all_equal(
  sqldf_solution(),
  datatable_solution())


#SQL Query 3

#SELECT
#Posts.Title,
#CmtTotScr.CommentsTotalScore
#FROM (
#  SELECT
#  PostID,
#  UserID,
#  SUM(Score) AS CommentsTotalScore
#  FROM Comments
#  GROUP BY PostID, UserID
#) AS CmtTotScr
#JOIN Posts ON Posts.ID = CmtTotScr.PostID AND Posts.OwnerUserId = CmtTotScr.UserID
#WHERE Posts.PostTypeId = 1
#ORDER BY CmtTotScr.CommentsTotalScore DESC
#LIMIT 10

#sqldf
sqldf3 <- sqldf("
SELECT
  Posts.Title,
  CmtTotScr.CommentsTotalScore
FROM 
( SELECT 
    PostID, 
    UserID, 
    SUM(Score) AS CommentsTotalScore
  FROM Comments
  GROUP BY PostID, UserID
) AS CmtTotScr
JOIN Posts ON Posts.ID = CmtTotScr.PostID AND Posts.OwnerUserId = CmtTotScr.UserID
WHERE Posts.PostTypeId = 1
ORDER BY CmtTotScr.CommentsTotalScore DESC
LIMIT 10")

#base functions
base3part1 <- merge(
  aggregate(list(CommentsTotalScore = Comments$Score), by = list(PostId = Comments$PostId, UserId = Comments$UserId), FUN = sum),
  Posts,
  by.x = c("PostId", "UserId"), by.y = c("Id", "OwnerUserId"), all.x = FALSE, all.y = FALSE)

base3part2 <- base3part1[base3part1$PostTypeId == 1, c("Title", "CommentsTotalScore")]

basefunctions3 <- base3part2[order(-base3part2$CommentsTotalScore),][1:10,]
  
#dplyr
dplyr3 <- inner_join(
  Comments %>% group_by(PostId, UserId) %>% select(PostId, UserId, Score) %>% summarise(CommentsTotalScore = sum(Score)), 
  Posts %>% filter(PostTypeId == 1), by = c("PostId" = "Id", "UserId" = "OwnerUserId")) %>% 
  ungroup() %>% select(Title, CommentsTotalScore) %>% arrange(desc(CommentsTotalScore)) %>% head(10)

#data.table
datatable3 <- setDT(Comments)[ , list(CommentsTotalScore = sum(Score)), by = list(PostId, UserId)][setDT(Posts)[PostTypeId == 1], 
on = list(PostId == Id, UserId == OwnerUserId)][order(-CommentsTotalScore), list(Title, CommentsTotalScore), ][1:10]

#benchmark
microbenchmark <- microbenchmark::microbenchmark(
  sqldf = sqldf_solution,
  base = base_functions_solution,
  dplyr = dplyr_solution,
  data.table = datatable_solution
)

#stats
as.data.table(microbenchmark)[,.(lowestTime = min(time),
             medianTime = median(time),
             meanTime = mean(time),
             stdeviation = sd(time),
             maximumTime = max(time),
             instance = .N), 
             by = "expr"]

#result check
all_equal(
  sqldf_solution(),
  base_functions_solution())

all_equal(
  sqldf_solution(),
  dplyr_solution())

all_equal(
  sqldf_solution(),
  datatable_solution())


#SQL Query 4

#SELECT DISTINCT
#Users.Id,
#Users.DisplayName,
#Users.Reputation,
#Users.Age,
#Users.Location
#FROM (
#  SELECT
#  Name, UserID
#  FROM Badges
#  WHERE Name IN (
#    SELECT
#    Name
#    FROM Badges
#    WHERE Class = 1
#    GROUP BY Name
#    HAVING COUNT(*) BETWEEN 2 AND 10
#  )
#  AND Class = 1
#) AS ValuableBadges
#JOIN Users ON ValuableBadges.UserId = Users.Id

#sqldf
sqldf4 <- sqldf("
SELECT DISTINCT
  Users.Id,
  Users.DisplayName,
  Users.Reputation,
  Users.Age,
  Users.Location
FROM 
( SELECT 
    Name, 
    UserID
  FROM Badges
  WHERE Name IN 
  ( SELECT 
      Name
    FROM Badges
    WHERE Class = 1
    GROUP BY Name
    HAVING COUNT(*) BETWEEN 2 AND 10
  )
  AND Class = 1
) AS ValuableBadges
JOIN Users ON ValuableBadges.UserId = Users.Id")

#base functions
base4part1 <- Badges[Badges$Class == 1,]

base4part2 <- aggregate(list(Count = base4part1$Name), by = data.frame(list(Name = base4part1$Name)), FUN = length)

base4part3 <- base4part2[2 <= base4part2$Count & base4part2$Count <= 10, c("Name")]

base4part4 <- merge(
  Badges[is.element(Badges$Name, base4part3) & Badges$Class == 1,], 
  Users, 
  by.x = "UserId", by.y = "Id", all.x = FALSE, all.y = FALSE)
  
base4part5 <- base4part4[c("UserId", "DisplayName", "Reputation", "Age", "Location")]

basefunctions4 <- base4part5[!duplicated(base4part5$DisplayName), ]
  
#dplyr
dplyr4 <- distinct(inner_join(
  Badges %>% filter(Name %in% pull(Badges %>% filter(Class == 1) %>% group_by(Name) %>% summarise(N = n()) %>% select(Name, N) %>% filter(2 <= N & N <= 10), Name) & Class == 1) %>% 
  select(Name, UserId),
  Users, by = c("UserId" = "Id")) %>% 
  select(Id = UserId, DisplayName, Reputation, Age, Location))

#data.table
datatable4 <- unique(setDT(Badges)[Class == 1, list(Name, UserId, .N), by = "Name"][2 <= N & N <= 10][setDT(Users)[], 
on = list(UserId == Id), nomatch = 0][, list(Id = UserId, DisplayName = DisplayName, Reputation = Reputation, Age = Age, Location = Location), ])

#benchmark
microbenchmark <- microbenchmark::microbenchmark(
  sqldf = sqldf_solution,
  base = base_functions_solution,
  dplyr = dplyr_solution,
  data.table = datatable_solution
)

#stats
as.data.table(microbenchmark)[,.(lowestTime = min(time),
             medianTime = median(time),
             meanTime = mean(time),
             stdeviation = sd(time),
             maximumTime = max(time),
             instance = .N), 
             by = "expr"]

#result check
all_equal(
  sqldf_solution(),
  base_functions_solution())

all_equal(
  sqldf_solution(),
  dplyr_solution())

all_equal(
  sqldf_solution(),
  datatable_solution())


#SQL Query 5

#SELECT
#Questions.Id,
#Questions.Title,
#BestAnswers.MaxScore,
#Posts.Score AS AcceptedScore,
#BestAnswers.MaxScore-Posts.Score AS Difference
#FROM (
#  SELECT Id, ParentId, MAX(Score) AS MaxScore
#  FROM Posts
#  WHERE PostTypeId == 2
#  GROUP BY ParentId
#) AS BestAnswers
#JOIN (
#  SELECT * FROM Posts
#  WHERE PostTypeId == 1
#) AS Questions
#ON Questions.Id = BestAnswers.ParentId
#JOIN Posts ON Questions.AcceptedAnswerId = Posts.Id
#WHERE Difference > 50
#ORDER BY Difference DESC

sqldf5 <- sqldf("
SELECT
  Questions.Id,
  Questions.Title,
  BestAnswers.MaxScore,
  Posts.Score AS AcceptedScore,
  BestAnswers.MaxScore - Posts.Score AS Difference
FROM 
( SELECT 
    Id, 
    ParentId, 
    MAX(Score) AS MaxScore
  FROM Posts
  WHERE PostTypeId == 2
  GROUP BY ParentId
) AS BestAnswers
JOIN (
  SELECT 
    * 
  FROM Posts
  WHERE PostTypeId == 1
) AS Questions
ON Questions.Id = BestAnswers.ParentId
JOIN Posts ON Questions.AcceptedAnswerId = Posts.Id
WHERE Difference > 50
ORDER BY Difference DESC")

#base functions
baseSql5BestAnswers<-do.call(data.frame,aggregate(Score~ParentId,data = Posts[Posts$PostTypeId==2,],FUN=function(x)max(x)))
colnames(baseSql5BestAnswers)[2]<-"MaxScore"
baseSql5Questions<-Posts[Posts$PostTypeId==1,]

baseSql5FirstJoin<-merge(data.frame(ParentId=baseSql5Questions$Id,Title=baseSql5Questions$Title,AcceptedAnswerId=baseSql5Questions$AcceptedAnswerId),baseSql5BestAnswers,by="ParentId")

baseSql5SecondJoin<-merge(baseSql5FirstJoin,data.frame(AcceptedAnswerId=Posts$Id,AcceptedScore=Posts$Score),by="AcceptedAnswerId")

baseSql5SecondJoin$Difference <- baseSql5SecondJoin$MaxScore - baseSql5SecondJoin$AcceptedScore 
baseSql5SecondJoin <- baseSql5SecondJoin[baseSql5SecondJoin$Difference > 50,] #taking only Difference>50 values
baseSql5Final <-baseSql5SecondJoin[order(-baseSql5SecondJoin$Difference),]

rownames(baseSql5Final)<-1:length(rownames(baseSql5Final))
baseSql5Final$AcceptedAnswerId<-NULL #removing unnecessary column
colnames(baseSql5Final)[1]<-"Id"

base5part1 <- do.call(data.frame, aggregate(list(MaxScore = Posts[Posts$PostTypeId == 2,]$Score), by = list(ParentId = Posts[Posts$PostTypeId == 2,]$ParentId), FUN = max))
base5part2 <- Posts[Posts$PostTypeId == 1, ]

base5part3 <- merge(data.frame(ParentId = base5part2$Id, Title = base5part2$Title, AcceptedAnswerId = base5part2$AcceptedAnswerId), base5part1, by = "ParentId")
base5part3 <- merge(base5part1, base5part2, by.x = "ParentId", by.y = "Id")

base5part4 <- merge(base5part3, data.frame(AcceptedAnswerId = Posts$Id, AcceptedScore = Posts$Score), by = "AcceptedAnswerId")
base5part4 <- merge(base5part3, Posts, by.x = "AcceptedAnswerId", by.y = "Id", all.x = FALSE, all.y = FALSE)

base5part4$Difference <- base5part4$MaxScore - base5part4$AcceptedScore
base5part5 <- base5part4[base5part4$Difference > 50,]

basefunctions5 <- base5part5[order(-base5part5$Difference),]
basefunctions5 <- basefunctions5[c("ParentId", "Title", "MaxScore", "AcceptedScore", "Difference")]
colnames(basefunctions5)[1] <- "Id"

#dplyr
dplyr5 <- Posts %>% filter(PostTypeId == 2 & !is.na(Score)) %>% group_by(ParentId) %>%
  summarise(MaxScore = max(Score),.groups="keep") %>% ungroup() %>%
  inner_join(x = Posts %>% filter(PostTypeId == 1), by = c("Id"="ParentId")) %>%
  inner_join(y = Posts, by = c("AcceptedAnswerId" = "Id")) %>%
  mutate(Difference = MaxScore - Score.y) %>%
  select(Id, Title = Title.x, MaxScore, AcceptedScore = Score.y, Difference) %>%
  filter(Difference>50) %>% arrange(desc(Difference))

#data.table
datatable5 <- setDT(Posts)[PostTypeId == 2, list(Id = Id[which.max(Score)], ParentId = ParentId[which.max(Score)], MaxScore = max(Score)), 
by = "ParentId"][setDT(Posts)[PostTypeId == 1], on = list(ParentId == Id), nomatch = 0][setDT(Posts)[], on = list(AcceptedAnswerId == Id), 
nomatch = 0][ , list(Id = ParentId, Title = Title, MaxScore = MaxScore, AcceptedScore = i.Score, Difference = MaxScore - i.Score)][Difference > 50][order(-Difference)]

#benchmark
microbenchmark <- microbenchmark::microbenchmark(
  sqldf = sqldf_solution,
  base = base_functions_solution,
  dplyr = dplyr_solution,
  data.table = datatable_solution
)

#stats
as.data.table(microbenchmark)[,.(lowestTime = min(time),
             medianTime = median(time),
             meanTime = mean(time),
             stdeviation = sd(time),
             maximumTime = max(time),
             instance = .N), 
             by = "expr"]

#result check
all_equal(
  sqldf_solution(),
  base_functions_solution())

all_equal(
  sqldf_solution(),
  dplyr_solution())

all_equal(
  sqldf_solution(),
  datatable_solution())