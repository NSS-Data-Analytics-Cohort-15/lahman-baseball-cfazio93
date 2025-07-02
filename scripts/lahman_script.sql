--1. What range of years for baseball games played does the provided database cover?
--answer: 1871-2016
SELECT MIN(yearid), MAX(yearid) from teams; 

--2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
--answer: Eddie Gaedel, 43 in, 1 game, St Louis Browns 

SELECT people.namefirst, people.namelast, people.height, appearances.g_all, appearances.teamid, teams.name
from people
INNER JOIN appearances
ON people.playerid = appearances.playerid
INNER JOIN teams 
ON appearances.teamid = teams.teamid
WHERE height IS NOT NULL
ORDER BY height asc
LIMIT 1

--3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

--answer: David Price

SELECT * from salaries
WHERE player

SELECT
		people.namefirst,
		people.namelast,
		CAST(CAST(SUM(DISTINCT(salaries.salary)) AS numeric) AS money),
		collegeplaying.schoolid AS school
from people 
INNER JOIN salaries
ON people.playerid = salaries.playerid
JOIN collegeplaying
ON people.playerid = collegeplaying.playerid
WHERE collegeplaying.schoolid = 'vandy'
GROUP BY people.namefirst, people.namelast, collegeplaying.schoolid
ORDER BY SUM(salaries.salary) desc

--returns 15 rows only b/c 9 rows were NULL 

--did below to CHECK

SELECT 
    people.playerid, 
    people.namefirst AS first_name, 
    people.namelast AS last_name, 
    CAST(CAST(SUM(salaries.salary) AS numeric) AS money) AS total_salary
FROM people
INNER JOIN collegeplaying ON people.playerid = collegeplaying.playerid
LEFT JOIN salaries ON people.playerid = salaries.playerid
WHERE collegeplaying.schoolid = 'vandy'
GROUP BY people.playerid, people.namefirst, people.namelast
ORDER BY SUM(salaries.salary) DESC;

--should be 24 total from vandy, but i'm getting only 15
SELECT DISTINCT(playerid)
FROM collegeplaying
WHERE schoolid = 'vandy'
GROUP BY playerid


--4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

--answer: Battery 41424, Infield 58934, Outfield 29560

SELECT 
    CASE
        WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
        WHEN pos = 'OF' THEN 'Outfield'
        WHEN pos IN ('P', 'C') THEN 'Battery'
        ELSE 'Other'
    END AS Position, 
	 SUM(po) AS putouts
FROM 
    fielding
WHERE yearid = '2016'
GROUP BY Position
ORDER BY putouts desc;

--can use COMMAS for CASE WHEN if input is the same 

--5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT * from teams

--below is strikeouts by BATTERS 
SELECT 
	CASE
		WHEN yearid between 1870 and 1879 THEN '1870s'
		WHEN yearid between 1880 and 1889 THEN '1880s'
		WHEN yearid between 1890 and 1899 THEN '1890s'
		WHEN yearid between 1900 and 1909 THEN '1900s'
		WHEN yearid between 1910 and 1919 THEN '1910s'
		WHEN yearid between 1920 and 1929 THEN '1920s'
		WHEN yearid between 1930 and 1939 THEN '1930s'
		WHEN yearid between 1940 and 1949 THEN '1940s'
		WHEN yearid between 1950 and 1959 THEN '1950s'
		WHEN yearid between 1960 and 1969 THEN '1960s'
		WHEN yearid between 1970 and 1979 THEN '1970s'
		WHEN yearid between 1980 and 1989 THEN '1980s'
		WHEN yearid between 1990 and 1999 THEN '1990s'
		WHEN yearid between 2000 and 2009 THEN '2000s'
		WHEN yearid between 2010 and 2019 THEN '2010s'
		END AS decade,
	ROUND(avg(so), 2) AS avg_so_per_game
from teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade asc

--below is HR by BATTERS 
SELECT 
	CASE
		WHEN yearid between 1870 and 1879 THEN '1870s'
		WHEN yearid between 1880 and 1889 THEN '1880s'
		WHEN yearid between 1890 and 1899 THEN '1890s'
		WHEN yearid between 1900 and 1909 THEN '1900s'
		WHEN yearid between 1910 and 1919 THEN '1910s'
		WHEN yearid between 1920 and 1929 THEN '1920s'
		WHEN yearid between 1930 and 1939 THEN '1930s'
		WHEN yearid between 1940 and 1949 THEN '1940s'
		WHEN yearid between 1950 and 1959 THEN '1950s'
		WHEN yearid between 1960 and 1969 THEN '1960s'
		WHEN yearid between 1970 and 1979 THEN '1970s'
		WHEN yearid between 1980 and 1989 THEN '1980s'
		WHEN yearid between 1990 and 1999 THEN '1990s'
		WHEN yearid between 2000 and 2009 THEN '2000s'
		WHEN yearid between 2010 and 2019 THEN '2010s'
		END AS decade,
	ROUND(avg(hr), 2) AS avg_hr_per_game
from teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade asc

--TREND: increase over time 
--confused about per game - is this correct?

--6. Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.

--answer: Chris Owings

--sb stolen bases (successful)
--cs caught stealing (unsuccessful)
SELECT 
		batting.playerid,
		people.namefirst, 
		people.namelast,
		sb AS stolen,
		cs AS attempted,
		ROUND(sb::numeric / NULLIF(sb + cs, 0), 2) AS pct_stolen
from batting
INNER JOIN people
ON batting.playerid = people.playerid
WHERE yearid = '2016'
		AND (sb + cs) >= '20'
ORDER BY pct_stolen desc 

--from cami (she also added the count of )
SELECT p.namefirst,
       p.namelast,
	   b.playerid,
	   (SUM(sb) * 100.0) / SUM(sb + cs) AS percentage_sb
	   --SUM(b.sb) AS stolen_bases
FROM batting AS b
JOIN people AS p
USING (playerid)
WHERE yearid = 2016
  AND (sb+cs) >= 20
GROUP BY p.namefirst,p.namelast,b.playerid
ORDER BY percentage_sb DESC
LIMIT 1;

SELECT 
    playerid,
    sb AS stolen,
    cs AS caught,
    ROUND(sb::numeric / NULLIF(sb + cs, 0), 3) AS pct_stolen
FROM batting
WHERE yearid = 2016
  AND (sb + cs) >= 20
ORDER BY pct_stolen DESC;

--7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

SELECT yearid, teamid, W AS most_wins_but_not_WS
from teams
WHERE WSWin = 'N' AND yearid between 1970 and 2016
ORDER BY w desc
LIMIT 1
--largest # of wins for team that did NOT win world series: 116

SELECT yearid, teamid AS world_series_champ, W as total_wins
from teams
WHERE WSWin = 'Y' AND yearid between 1970 and 2016
ORDER BY w asc
-- LIMIT 1
--smallest # of wins for world series winner: 63

--world series winners 
SELECT yearid, teamid, W
from teams
WHERE WSWin = 'Y' AND yearid between 1970 and 2016
ORDER BY w asc

--there were 12 years that a team won the most games and the world series (12/47 = 26%)...am I supposed to add a query to figure out the percentage? (2nd query has percentage)
SELECT 
    yearid,
    teamid,
    W,
    WSWin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
  AND (yearid, W) IN (
        SELECT yearid, MAX(W)
        FROM teams
        WHERE yearid BETWEEN 1970 AND 2016
        GROUP BY yearid
    )
	AND WSWin = 'Y'
ORDER BY yearid ASC;

WITH temptable AS (
SELECT DISTINCT
    yearid,
    --teamid,
    W,
    WSWin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
AND yearid != 1981
  AND (yearid, W) IN (
        SELECT yearid, MAX(W)
        FROM teams
        WHERE yearid BETWEEN 1970 AND 2016
		AND yearid != 1981
        GROUP BY yearid
    )
	--AND WSWin = 'Y'
ORDER BY yearid ASC)
SELECT 
	COUNT(CASE WHEN WSWin = 'Y' THEN 1 ELSE NULL
	END) * 1.0 
/count(distinct(yearid))
FROM temptable

--had to distinct bc some teams tied on # of wins

--got help from dibran and adell below but need to filter for years
SELECT
	yearid, 
	teamid,
	WSWin, 
	most_wins_that_year
FROM (SELECT yearid, teamid, WSWin,
		MAX(W) AS most_wins_that_year
	FROM teams
	GROUP BY yearid, teamid, WSWin) AS most_wins
WHERE yearid between 1970 and 2016 AND WSWin = 'Y' 
ORDER BY yearid desc

SELECT
	yearid, 
	teamid,
	WSWin, 
	most_wins_that_year
FROM (SELECT yearid, teamid, WSWin,
		MAX(W) AS most_wins_that_year
	FROM teams
	GROUP BY yearid, teamid, WSWin) AS most_wins
WHERE yearid between 1970 and 2016 AND WSWin = 'Y' 
ORDER BY yearid desc

---from marvin below: 

WITH highest_wins_by_season AS ( ---CTE to create table with year, max # of wins, max win season flag
SELECT yearid,
MAX(W) as W,
'max win season' as max_win_season
FROM teams as t2
where yearid >= 1970
GROUP BY yearid
ORDER BY yearid)

SELECT
	teams.yearid, 
	teams.teamid,
	teams.WSWin, 
	teams.w
FROM teams
INNER JOIN highest_wins_by_season
ON teams.yearid = highest_wins_by_season.yearid
WHERE teams.WSWin = 'Y'
ORDER BY yearid desc

--need to make sure outer query and subquery match

--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

--largest attendance: 
SELECT 
	team,
	park,
	ROUND(attendance * 1.0 / games, 2) AS avg_attendance
from homegames
WHERE year = '2016' AND games >= '10'
ORDER BY avg_attendance desc
LIMIT 5

--lowest attendance: 
SELECT 
	team,
	park,
	ROUND(attendance * 1.0 / games, 2) AS avg_attendance
from homegames
WHERE year = '2016' AND games >= '10'
ORDER BY avg_attendance asc
LIMIT 5

--default is NULL?

--use some logic from 6?

--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
--first, last, teams, year (should get 6 rows)
--IN for list (NL, AL)

--from dibran

select playerid from awardsmanagers
WHERE awardid = 'TSN Manager of the Year'

select * from people
where playerid IN ('johnsda02', 'leylaji99')
--firstname
--lastname

select *
from awardsmanagers
where playerid IN ('johnsda02', 'leylaji99') and awardid IN ('TSN Manager of the Year')
--join to people 

--my work 
WITH AL_mgr_of_year AS 
(SELECT playerid, awardid, lgid
from awardsmanagers
WHERE awardid = 'TSN Manager of the Year' AND lgid = 'AL'
GROUP BY playerid, awardid, lgid)

SELECT 
	--AL_mgr_of_year.playerid,
	awardsmanagers.playerid, 
	people.namefirst, 
	people.namelast,
	awardsmanagers.awardid,
	awardsmanagers.yearid,
	awardsmanagers.lgid,  
	teams.teamid
from awardsmanagers
INNER JOIN AL_mgr_of_year
ON awardsmanagers.playerid = AL_mgr_of_year.playerid
INNER JOIN people
ON awardsmanagers.playerid = people.playerid
LEFT JOIN managershalf
ON awardsmanagers.playerid = managershalf.playerid
LEFT JOIN teams
ON managershalf.teamid = teams.teamid
WHERE awardsmanagers.awardid = 'TSN Manager of the Year' AND awardsmanagers.lgid = 'NL' --OR AL_mgr_of_year.lgid = 'AL')
GROUP BY awardsmanagers.playerid, awardsmanagers.awardid, awardsmanagers.lgid, people.namefirst, people.namelast, teams.teamid, awardsmanagers.yearid --AL_mgr_of_year.playerid
ORDER BY people.namelast asc

--dibran/krithika:


with award as 
(
select
	distinct playerid
	from awardsmanagers
	where awardid = 'TSN Manager of the Year' and lgid IN ('AL', 'NL')
	group by playerid HAVING count(distinct lgid)>=2
)
select
	distinct awardsmanagers.yearid, 
	people.playerid, 
	teams.name,
	people.namefirst, 
	people.namelast
FROM awardsmanagers
JOIN award ON awardsmanagers.playerid = award.playerid
join people ON award.playerid = people.playerid
join managers on people.playerid = managers.playerid and awardsmanagers.yearid = managers.yearid
join teams on managers.teamid = teams.teamid and managers.yearid = teams.yearid


--CTE for just these two coaches ?
WITH bothleagues AS 
(SELECT 
	playerid, 
	yearid
FROM awardsmanagers
WHERE playerid IN ('johnsda02', 'leylaji99') AND awardid = 'TSN Manager of the Year'
GROUP BY playerid, yearid),

-- WITH AL_mgr_of_year AS 
-- (SELECT playerid, awardid, lgid
-- from awardsmanagers
-- WHERE awardid = 'TSN Manager of the Year' AND lgid = 'AL'
-- GROUP BY playerid, awardid, lgid)

SELECT 
	awardsmanagers.playerid, 
	people.namefirst, 
	people.namelast,
	awardsmanagers.awardid,
	t.teamid
from awardsmanagers
INNER JOIN AL_mgr_of_year
ON awardsmanagers.playerid = AL_mgr_of_year.playerid
INNER JOIN people
ON awardsmanagers.playerid = people.playerid
INNER JOIN managershalf as mh
ON awardsmanagers.playerid = mh.playerid
INNER JOIN teams as t
ON mh.teamid = t.teamid
WHERE awardsmanagers.awardid = 'TSN Manager of the Year' AND awardsmanagers.lgid = 'NL' --OR AL_mgr_of_year.lgid = 'AL')
GROUP BY awardsmanagers.playerid, awardsmanagers.awardid, awardsmanagers.lgid, people.namefirst, people.namelast, t.teamid, awardsmanagers.yearid --AL_mgr_of_year.playerid
ORDER BY people.namelast asc


--10. Find all players who hit their career highest number of home runs in 2016. 
--		Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. 
--		Report the players' first and last names and the number of home runs they hit in 2016.

--below to check max hr
-- select playerid from people
-- where namefirst = 'Robinson' and namelast = 'Cano'
-- "canoro01"
--max hr for Cano 39...same as in query 

select distinct (playerid), hr
from batting
where yearid = '2016' and hr > 0
ORDER BY hr desc
--yearid 2016
--playerid
--hr

--trying other methods...got help from dibran: 

SELECT 
    b.playerid AS player,
    MAX(b.hr) AS max_hr, 
	CASE WHEN
		MAX(CASE WHEN b.yearid = 2016 THEN b.hr ELSE null end) = MAX(b.hr)
		THEN 'y'
		ELSE 'n'
	END AS max_year
FROM batting as b
INNER JOIN (select playerid from batting group by playerid having count (distinct yearid) >= 10) as c
USING (playerid) --only joining on players who played 10+ years
WHERE b.hr > 0
group by playerid
having
	max(case when yearid = 2016 then hr else null end) = max(hr) 
--for above...would need to join to get names



	
GROUP BY 
    playerid
ORDER BY 
    max_hr DESC;

select playerid, max(hr)
from batting
group by playerid
order by max desc
--max hr for each player

select count(distinct yearid) as years, playerid
from batting
group by playerid
order by years desc
--how many years each player played

select max(hr)
from batting
where playerid = 'canoro01'


--from cami:
with playeryears AS
(
	SELECT playerid, COUNT(DISTINCT yearid) AS years_played
	from batting
	group by playerid
), 

hr_2016 AS
(select playerid, hr AS hr_2016
from batting
where yearid = 2016 and hr >0
),

max_career_hr AS
(
	select playerid, max (HR) as career_high_hr
	from batting
	group by playerid
)

select p.namefirst, p.namelast, h.hr_2016
from hr_2016 as h
join max_career_hr as m
	on h.playerid = m.playerid
	and h.hr_2016 = m.career_high_hr
join playeryears as py
	on h.playerid = py.playerid
	and py.years_played >= 10
join people as p
	on p.playerid = h.playerid

----duplicate below: 

-- 	with playeryears AS
-- (
-- 	SELECT playerid, COUNT(DISTINCT yearid) AS years_played
-- 	from batting
-- 	group by playerid
-- ), 

-- hr_2016 AS
-- (select playerid, hr AS hr_2016
-- from batting
-- where yearid = 2016 and hr >0
-- ),

-- max_career_hr AS
-- (
-- 	select playerid, max (HR) as career_high_hr
-- 	from batting
-- 	group by playerid
-- )

-- select p.namefirst, p.namelast, h.hr_2016
-- from hr_2016 as h
-- join max_career_hr as m
-- 	on h.playerid = m.playerid
-- 	and h.hr_2016 = m.career_high_hr
-- join playeryears as py
-- 	on h.playerid = py.playerid
-- 	and py.years_played >= 10
-- join people as p
-- 	on p.playerid = h.playerid
