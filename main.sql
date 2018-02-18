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
SELECT over_id,SUM(runs_scored) AS over_runs_scored FROM Batsman_scored WHERE match_id = 335987 GROUP BY over_id HAVING SUM(runs_scored)<=7 ORDER BY over_runs_scored DESC,over_id

--5--
SELECT DISTINCT player_name FROM wicket_taken,player WHERE kind_out = 'bowled' AND player_out = player_id ORDER BY player_name

--14--
SELECT venue FROM Match WHERE win_type = 'wickets' GROUP BY venue ORDER BY count(match_id),venue

--15--
-- We need to select min from this query somehow conventional select min kaam nhi kar rha. ek baar dekh le--
SELECT player_name from (SELECT runs_bowler.bowler as bowler, runs_given*1000/wickets as average FROM (SELECT bowler,sum(runs_scored) AS runs_given FROM (SELECT match_id,over_id, bowler FROM ball_by_ball GROUP BY over_id,bowler,match_id) AS ball_ball, batsman_scored WHERE ball_ball.over_id = batsman_scored.over_id AND ball_ball.match_id = batsman_scored.match_id GROUP BY bowler) as runs_bowler, (SELECT bowler,count(kind_out) AS wickets FROM (SELECT match_id,over_id, bowler FROM ball_by_ball GROUP BY over_id,bowler,match_id) AS ball_ball, wicket_taken WHERE ball_ball.over_id = wicket_taken.over_id AND ball_ball.match_id = wicket_taken.match_id GROUP BY bowler) as wickets_bowler WHERE runs_bowler.bowler = wickets_bowler.bowler)as relevent, player WHERE player_id = bowler ORDER BY average,player_name

--16--
SELECT DISTINCT player_name, name from (SELECT player_name,team_id FROM (SELECT player_name,team_id,match_id FROM (SELECT player_id,team_id,match_id FROM player_match WHERE role = 'CaptainKeeper')as captainkeeper,player where captainkeeper.player_id = player.player_id) AS relevent_matches,match WHERE match.match_id = relevent_matches.match_id AND match.match_winner = relevent_matches.team_id)as relevent,team Where relevent.team_id = team.team_id ORDER BY player_name

