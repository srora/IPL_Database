/*CREATE TABLE Player(
	player_id integer,
	player_name text,
	dob date,
	batting_hand text,
	bowling_skill text,
	country_name text,
	PRIMARY KEY (player_id)
);

CREATE TABLE Team(
	team_id integer,
	name text,
	PRIMARY KEY (team_id)
);

CREATE TABLE Match(
	match_id integer,
	team_1 integer,
	team_2 integer,
	match_date date,
	season_id integer CHECK (season_id>=1 AND season_id<=9),
	venue text,
	toss_winner integer,
	toss_decision text,
	win_type text,
	win_margin integer,
	outcome_type text,
	match_winner integer,
	man_of_the_match integer,
	PRIMARY KEY (match_id)
);

CREATE TABLE Player_match(
	match_id integer,
	player_id integer,
	role text,
	team_id integer,
	PRIMARY KEY (match_id, player_id)
);

CREATE TABLE Ball_by_ball(
	match_id integer,
	over_id integer CHECK (over_id>=1 AND over_id<=20),
	ball_id integer CHECK (ball_id>=1 AND ball_id<=9),
	innings_no integer CHECK (innings_no>=1 AND innings_no<=4),
	team_batting integer,
	team_bowling integer,
	striker_batting_position integer,
	striker integer,
	non_striker integer,
	bowler integer,
	PRIMARY KEY (match_id, over_id, ball_id, innings_no)
);

CREATE TABLE Batsman_scored(
	match_id integer,
	over_id integer,
	ball_id integer,
	runs_scored integer,
	innings_no integer,
	PRIMARY KEY (match_id, over_id, ball_id, innings_no)
);

CREATE TABLE Wicket_taken(
	match_id integer,
	over_id integer,
	ball_id integer,
	player_out integer,
	kind_out text,
	innings_no integer,
	PRIMARY KEY (match_id, over_id, ball_id, innings_no)
);

CREATE TABLE Extra_runs(
	match_id integer,
	over_id integer,
	ball_id integer,
	extra_type text,
	extra_runs integer,
	innings_no integer,
	PRIMARY KEY (match_id, over_id, ball_id, innings_no)
);

COPY Player(player_id, player_name, dob, batting_hand, bowling_skill, country_name) 
FROM '/Users/sarishtwadhwa/Downloads/DATA/player.csv' DELIMITER ',';

COPY Team(team_id, name)
FROM '/Users/sarishtwadhwa/Downloads/DATA/team.csv' DELIMITER ',';

COPY Match(match_id, team_1, team_2, match_date, season_id, venue, toss_winner, toss_decision, win_type, win_margin, outcome_type, match_winner, man_of_the_match) 
FROM '/Users/sarishtwadhwa/Downloads/DATA/match.csv' DELIMITER ',';

COPY Player_match(match_id, player_id, role, team_id)
FROM '/Users/sarishtwadhwa/Downloads/DATA/player_match.csv' DELIMITER ',';

COPY Ball_by_ball(match_id, over_id, ball_id, innings_no, team_batting, team_bowling, striker_batting_position, striker, non_striker, bowler)
FROM '/Users/sarishtwadhwa/Downloads/DATA/ball_by_ball.csv' DELIMITER ',';

COPY Batsman_scored(match_id, over_id, ball_id, runs_scored, innings_no)
FROM '/Users/sarishtwadhwa/Downloads/DATA/batsman_scored.csv' DELIMITER ',';

COPY Wicket_taken(match_id, over_id, ball_id, player_out, kind_out, innings_no)
FROM '/Users/sarishtwadhwa/Downloads/DATA/wicket_taken.csv' DELIMITER ',';

COPY Extra_runs(match_id, over_id, ball_id, extra_type, extra_runs, innings_no)
FROM '/Users/sarishtwadhwa/Downloads/DATA/extra_runs.csv' DELIMITER ',';
*/
--1--

SELECT player_name FROM Player WHERE batting_hand LIKE 'Left%' AND country_name='England' ORDER BY player_name;

--2--
--doubt : is age rounded off or not 28 years 7 months is 28 years or 29??? our query considers 27.57 as 27 -- Reply This seems fine for both cases, since 28 yrs 7 months is still smaller than 29.
SELECT player_name, age FROM (SELECT player_name, dob, EXTRACT(YEAR FROM(AGE('2018-02-12', dob))) AS age FROM Player WHERE bowling_skill='Legbreak googly') AS dummy WHERE age>=28 ORDER BY age DESC, player_name ASC;

--3--
SELECT match_id, toss_winner FROM Match where toss_decision='bat' ORDER BY match_id;

--4--
SELECT over_id,SUM(runs_scored)+ COALESCE(SUM(extra_runs),0) AS over_runs_scored
FROM Batsman_scored NATURAL FULL OUTER JOIN extra_runs
WHERE match_id = 335987 
GROUP BY over_id,innings_no 
HAVING SUM(runs_scored)+COUNT(extra_runs)<=7.5
ORDER BY over_runs_scored DESC,over_id
--5--
SELECT DISTINCT player_name FROM wicket_taken,player WHERE kind_out = 'bowled' AND player_out = player_id ORDER BY player_name

--6--

SELECT Match.match_id, name_1 as team_1, name_2 as team_2, winning_team_name, win_margin FROM (SELECT match_id, name as name_1 FROM Match, Team where team_1=team_id AND win_margin>=60) as f1, (SELECT match_id, name as name_2 FROM Match, Team where team_2=team_id AND win_margin>=60) as f2, (SELECT match_id, name as winning_team_name FROM Match, Team where match_winner=team_id AND win_margin>=60) as f3, Match where Match.match_id=f1.match_id AND f2.match_id=f3.Match_id AND f1.match_id=f2.match_id AND f3.match_id=Match.match_id ORDER BY win_margin, match_id;

--7--

SELECT player_name FROM Player WHERE batting_hand='Left-hand bat' AND EXTRACT(YEAR FROM(AGE('2018-02-12', dob))) <30 ORDER BY player_name;

--8-- 

SELECT t1.match_id, t1.a+t2.b as total_runs FROM (SELECT match_id, sum(runs_scored)as a FROM Batsman_scored GROUP BY match_id) as t1,(SELECT match_id, sum(extra_runs) as b FROM Extra_runs GROUP BY match_id) as t2 WHERE t1.match_id=t2.match_id ORDER BY t1.match_id;

--9--

SELECT match_id, runs_scored, player_name
FROM(
	SELECT * FROM(
		SELECT match_id, max(runs_scored) as runs_scored
		FROM(
			SELECT match_id,innings_no,over_id,SUM(runs_scored)+ COALESCE(SUM(extra_runs),0) AS runs_scored
			FROM Batsman_scored NATURAL FULL OUTER JOIN extra_runs
			GROUP BY match_id,over_id,innings_no
			)as foo
		GROUP BY match_id
	)as abc
	NATURAL INNER JOIN(
		SELECT match_id,innings_no,over_id,SUM(runs_scored)+ COALESCE(SUM(extra_runs),0) AS runs_scored
		FROM Batsman_scored NATURAL FULL OUTER JOIN extra_runs
		GROUP BY match_id,over_id,innings_no
		)as foo
)as foo NATURAL INNER JOIN (
	SELECT match_id, innings_no, over_id, player_name
	FROM(
		SELECT match_id, innings_no, over_id, bowler as player_id 
		FROM ball_by_ball 
		GROUP BY match_id, innings_no, over_id,bowler) as abc NATURAL INNER JOIN player
	)as too 
ORDER BY match_id,over_id

--10--

SELECT player_name, run_out_count FROM (SELECT player_name, count(kind_out) as run_out_count FROM (SELECT * FROM Wicket_taken WHERE kind_out='run out')as W FULL OUTER JOIN Player ON  player_out=player_id GROUP BY player_name) as foo ORDER BY run_out_count DESC, player_name

--11--

SELECT kind_out as out_type, count(kind_out) as number FROM Wicket_taken GROUP BY kind_out ORDER BY number DESC, out_type;

--12--

Select name, number from team natural inner join (Select team_id, count(man_of_the_match)as number from player_match inner join (Select man_of_the_match, match_id from match )as ab on ab.match_id = player_match.match_id and man_of_the_match = player_id group by team_id) as abc order by name

--13--
Select venue from match natural inner join (Select match_id, count(extra_type) as num_wides from extra_runs where extra_type = 'wides' group by match_id) as abc group by venue order by sum(num_wides) desc limit 1 

--14--
SELECT venue FROM Match WHERE (match_winner = toss_winner and toss_decision = 'field') or (match_winner != toss_winner and toss_decision = 'bat')GROUP BY venue ORDER BY count(match_id) desc,venue 

--primary key includes innings and ball also--
--if you have joined without them its a problem--
--15--
SELECT player_name
FROM
	(SELECT player_name, average 
	 from (
		SELECT runs_bowler.bowler as bowler, round(runs_given/wickets,3) as average 
		FROM (
			SELECT bowler,sum(runs_scored)+coalesce(sum(extra_runs),0) AS runs_given 
			FROM (
				SELECT match_id,over_id, bowler, innings_no, ball_id 
				FROM ball_by_ball 
				GROUP BY over_id,bowler,match_id, innings_no, ball_id
			) AS ball_ball NATURAL INNER JOIN (batsman_scored NATURAL FULL OUTER JOIN extra_runs)
			GROUP BY bowler
		)as runs_bowler NATURAL INNER JOIN 
			(SELECT bowler,count(kind_out) AS wickets 
			FROM 
				(SELECT match_id,over_id, innings_no, ball_id , bowler FROM ball_by_ball 
				GROUP BY over_id,bowler,match_id, innings_no, ball_id )
				AS ball_ball NATURAL INNER JOIN wicket_taken 
				GROUP BY bowler)
			as wickets_bowler
	 )as relevent, player 
WHERE player_id = bowler 
ORDER BY average,player_name) as foo
WHERE average = 
(SELECT min(average) 
FROM(
	SELECT player_name, average 
	 from (
		SELECT runs_bowler.bowler as bowler, round(runs_given/wickets,3) as average 
		FROM (
			SELECT bowler,sum(runs_scored)+coalesce(sum(extra_runs),0) AS runs_given 
			FROM (
				SELECT match_id,over_id, bowler, innings_no, ball_id 
				FROM ball_by_ball 
				GROUP BY over_id,bowler,match_id, innings_no, ball_id
			) AS ball_ball NATURAL INNER JOIN (batsman_scored NATURAL FULL OUTER JOIN extra_runs)
			GROUP BY bowler
		)as runs_bowler NATURAL INNER JOIN 
			(SELECT bowler,count(kind_out) AS wickets 
			FROM 
				(SELECT match_id,over_id, innings_no, ball_id , bowler FROM ball_by_ball 
				GROUP BY over_id,bowler,match_id, innings_no, ball_id )
				AS ball_ball NATURAL INNER JOIN wicket_taken 
				GROUP BY bowler)
			as wickets_bowler
	 )as relevent)as mini)




--16--
SELECT  player_name, name from (SELECT player_name,team_id FROM (SELECT player_name,team_id,match_id FROM (SELECT player_id,team_id,match_id FROM player_match WHERE role = 'CaptainKeeper')as captainkeeper,player where captainkeeper.player_id = player.player_id) AS relevent_matches,match WHERE match.match_id = relevent_matches.match_id AND match.match_winner = relevent_matches.team_id)as relevent,team Where relevent.team_id = team.team_id ORDER BY player_name,name

--17--
SELECT player_name, total_runs FROM player, (SELECT striker, sum(innings_runs_scored) AS TOTAL_RUNS  FROM  (SELECT striker, match_id, sum(runs_scored) as innings_runs_scored FROM  batsman_scored NATURAL INNER JOIN (SELECT match_id,over_id,innings_no,striker, ball_id from ball_by_ball) as ball_ball GROUP BY striker, match_id ) AS hava GROUP BY striker HAVING max(innings_runs_scored) > 50) as relevant where relevant.striker = player.player_id order by total_runs desc, player_name

--18--
SELECT player_name from player,(SELECT striker from match natural inner join(SELECT striker, match_id,team_batting, sum(runs_scored) as innings_runs_scored FROM batsman_scored NATURAL INNER JOIN (SELECT match_id,over_id,innings_no,striker,team_batting, ball_id from ball_by_ball) as ball_ball GROUP BY striker, match_id,team_batting) as rel WHERE team_batting != match_winner and innings_runs_scored >= 100)as rele where rele.striker = player.player_id order by player_name asc

--19--
SELECT match_id, venue from match where (team_1 = 1 or team_2 = 1) and match_winner != 1 order by match_id

--20--
SELECT player_name 
FROM(
	SELECT player_id,count(distinct(match_id)) AS matches, SUM(runs) AS runs
	FROM(
		SELECT player_id, match_id ,SUM(runs) AS runs
		FROM (
			SElECT match_id,over_id,innings_no,ball_id,COALESCE(runs_scored,0) AS runs,striker as player_id
			FROM ball_by_ball
			NATURAL INNER JOIN batsman_scored
			NATURAL INNER JOIN match 
			WHERE match.season_id = 5
		) AS foo
		GROUP BY player_id,match_id
	) as foo
	GROUP BY player_id
)as foo
NATURAL INNER JOIN player
ORDER BY ROUND(runs/matches,3) DESC, player_name
LIMIT 10

--21--
SELECT country_name 
from(
	SELECT DISTINCT country_average 
	from(
		SELECT country_name,ROUND(SUM(average)/COUNT(player_name),3) as country_average
		FROM(
			SELECT player_name, country_name,matches_played,runs,ROUND(runs/matches_played,3) as average 
			FROM(
				SELECT player_id, count(distinct(match_id)) as matches_played, ROUND(sum(runs_scored),0) as runs
				FROM(
					SElECT match_id,over_id,innings_no,ball_id,COALESCE(runs_scored,0) AS runs_scored,striker as player_id
					FROM ball_by_ball
					NATURAL INNER JOIN batsman_scored
					NATURAL INNER JOIN match 
				)as foo
			GROUP BY player_id
			)as foo
			NATURAL INNER JOIN player
		) as foo
	GROUP BY country_name
	) as foo
	ORDER BY country_average DESC
	LIMIT 5
) as foo NATURAL LEFT JOIN (SELECT country_name, country_average 
	from(
		SELECT country_name,ROUND(SUM(average)/COUNT(player_name),3) as country_average
		FROM(
			SELECT player_name, country_name,matches_played,runs,ROUND(runs/matches_played,3) as average 
			FROM(
				SELECT player_id, count(distinct(match_id)) as matches_played, ROUND(sum(runs_scored),0) as runs
				FROM(
					SElECT match_id,over_id,innings_no,ball_id,COALESCE(runs_scored,0) AS runs_scored,striker as player_id
					FROM ball_by_ball
					NATURAL INNER JOIN batsman_scored
					NATURAL INNER JOIN match 
				)as foo
			GROUP BY player_id
			)as foo
			NATURAL INNER JOIN player
		) as foo
	GROUP BY country_name
	ORDER BY ROUND(SUM(average)/COUNT(player_name),3) DESC
	) as foo)as abc
