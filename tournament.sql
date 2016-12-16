/* Creating the database and establishing the schema */
DROP DATABASE IF EXISTS tournament;
CREATE DATABASE tournament;
\c tournament;

/* Creates the Players table */
CREATE TABLE Players(
    name text NOT NULL,
    player_id serial PRIMARY KEY,
    dateCreated timestamp DEFAULT current_timestamp
);

/* Creates the Matches table */
CREATE TABLE Matches(
    winner_id int REFERENCES players(player_id),
    loser_id int REFERENCES players(player_id),
    match_id serial PRIMARY KEY,
    dateCreated timestamp DEFAULT current_timestamp
);

/* A view to show the winner of each match. Component of v_points */
CREATE VIEW v_results AS
    SELECT players.name, players.player_id, match_id
    FROM matches
    JOIN players 
    ON players.player_id = matches.winner_id;

/* A view that shows how many points each player has. Component of v_standings */
CREATE VIEW v_points AS
    SELECT players.name, players.player_id, count(v_results.player_id) AS wins
    FROM players 
    LEFT JOIN v_results ON players.player_id = v_results.player_id
    GROUP BY players.player_id
    ORDER BY wins DESC;

/* A view that show how many matches each player has played. Component of v_standings */
CREATE VIEW v_matches AS
    SELECT players.player_id, count(matches.match_id) AS matches
    FROM players
    LEFT JOIN matches ON players.player_id = matches.winner_id
    OR players.player_id=matches.loser_id
    GROUP BY players.player_id;

/* A view that shows the standings. Combination of v_points and v_matches. Is called by playerStandings() */
CREATE VIEW v_standings AS
    SELECT v_points.player_id, v_points.name, v_points.wins, v_matches.matches
    FROM v_points
    LEFT JOIN v_matches ON v_matches.player_id = v_points.player_id
    ORDER BY wins DESC;

/* A view that adds row number to each player. Component of v_odd and v_even */
CREATE VIEW v_rownumber AS 
	SELECT ROW_NUMBER() OVER (ORDER BY wins DESC) AS Row, player_id, name, wins
	FROM v_standings;

/* A view that lists all the odd placements. Component of v_pairings */
CREATE VIEW v_odd AS
	SELECT player_id, name, wins, ROW_NUMBER() OVER (ORDER BY wins DESC) AS next_match
	FROM v_rownumber 
	WHERE (row % 2) <> 0;

/* A view that lists all even placements. Component of v_pairings */
CREATE VIEW v_even AS
	SELECT player_id, name, wins, ROW_NUMBER() OVER (ORDER BY wins DESC) AS next_match
	FROM v_rownumber 
	WHERE (row % 2) = 0;

/* A view that lists the next matchups based on the standings. Built from v_even and v_odd. Is called by swissPairings() */
CREATE VIEW v_pairings AS
	SELECT v_even.player_id AS id1, v_even.name AS name1, v_odd.player_id AS id2, v_odd.name AS name2
	FROM v_even
	JOIN v_odd ON v_even.next_match = v_odd.next_match;


/* Test data */
-- INSERT INTO Players VALUES ('Player1');
-- INSERT INTO Players VALUES ('Player2');
-- INSERT INTO Players VALUES ('Player3');
-- INSERT INTO Players VALUES ('Player4');
-- INSERT INTO Players VALUES ('Player5');
-- INSERT INTO Players VALUES ('Player6');
-- INSERT INTO Players VALUES ('Player7');
-- INSERT INTO Players VALUES ('Player8');

-- INSERT INTO Matches VALUES (1, 2);
-- INSERT INTO Matches VALUES (3, 4);
-- INSERT INTO Matches VALUES (5, 6);
-- INSERT INTO Matches VALUES (7, 8);

-- INSERT INTO Matches VALUES (1, 3);
-- INSERT INTO Matches VALUES (5, 7);
-- INSERT INTO Matches VALUES (2, 4);
-- INSERT INTO Matches VALUES (8, 6);
