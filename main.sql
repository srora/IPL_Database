CREATE TABLE Player(
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
FROM 'F:\sem8\col362\Assignments\assign2\player.csv' DELIMITER ',';

COPY Team(team_id, name)
FROM 'F:\sem8\col362\Assignments\assign2\team.csv' DELIMITER ',';

COPY Match(match_id, team_1, team_2, match_date, season_id, venue, toss_winner, toss_decision, win_type, win_margin, outcome_type, match_winner, man_of_the_match) 
FROM 'F:\sem8\col362\Assignments\assign2\match.csv' DELIMITER ',';

COPY Player_match(match_id, player_id, role, team_id)
FROM 'F:\sem8\col362\Assignments\assign2\player_match.csv' DELIMITER ',';

COPY Ball_by_ball(match_id, over_id, ball_id, innings_no, team_batting, team_bowling, striker_batting_position, striker, non_striker, bowler)
FROM 'F:\sem8\col362\Assignments\assign2\ball_by_ball.csv' DELIMITER ',';

COPY Batsman_scored(match_id, over_id, ball_id, runs_scored, innings_no)
FROM 'F:\sem8\col362\Assignments\assign2\batsman_scored.csv' DELIMITER ',';

COPY Wicket_taken(match_id, over_id, ball_id, player_out, kind_out, innings_no)
FROM 'F:\sem8\col362\Assignments\assign2\wicket_taken.csv' DELIMITER ',';

COPY Extra_runs(match_id, over_id, ball_id, extra_type, extra_runs, innings_no)
FROM 'F:\sem8\col362\Assignments\assign2\extra_runs.csv' DELIMITER ',';

--1--

SELECT player_name FROM Player WHERE batting_hand LIKE 'Left%' AND country_name='England' ORDER BY player_name;

--2--
--doubt : is age rounded off or not 28 years 7 months is 28 years or 29??? our query considers 27.57 as 27
SELECT player_name, age FROM (SELECT player_name, dob, EXTRACT(YEAR FROM(AGE('2018-02-12', dob))) AS age FROM Player WHERE bowling_skill='Legbreak googly') AS dummy WHERE age>=28 ORDER BY age DESC, player_name ASC;

--3--

SELECT match_id, match_winner FROM Match where toss_decision='bat' ORDER BY match_id;

--4--
