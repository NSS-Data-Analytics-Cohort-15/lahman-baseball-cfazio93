--1. What range of years for baseball games played does the provided database cover?
--answer: 1871-2016
SELECT MIN(yearid), MAX(yearid) from teams; 

--2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
--answer: Eddie Gaedel, 43 in, 1 game, St Louis Browns 
SELECT * from people
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

SELECT people.namefirst,
		people.namelast,
		CAST(CAST(SUM(salaries.salary) AS numeric) AS money),
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

--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
SELECT playerid, awardid, lgid 
from awardsmanagers
WHERE awardid = 'TSN Manager of the Year'
GROUP BY playerid, awardid, lgid

--10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.