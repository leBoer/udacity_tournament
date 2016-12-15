/* Creating the database and establishing the schema */
DROP DATABASE IF EXISTS tournament;
CREATE DATABASE tournament;
\c tournament;

CREATE TABLE Players(
    name text NOT NULL,
    player_id serial PRIMARY KEY,
    dateCreated timestamp DEFAULT current_timestamp
);

CREATE TABLE Matches(
    winner_id int REFERENCES players(player_id),
    loser_id int REFERENCES players(player_id),
    match_id serial PRIMARY KEY,
    dateCreated timestamp DEFAULT current_timestamp
);

CREATE VIEW v_results AS
    SELECT players.name, players.player_id, match_id
    FROM matches
    JOIN players 
    ON players.player_id = matches.winner_id;

CREATE VIEW v_points AS
    SELECT players.name, players.player_id, count(v_results.player_id) AS wins
    FROM players 
    LEFT JOIN v_results ON players.player_id = v_results.player_id
    GROUP BY players.player_id
    ORDER BY wins DESC;

CREATE VIEW v_matches AS
    SELECT players.player_id, count(matches.match_id) AS matches
    FROM players
    LEFT JOIN matches ON players.player_id = matches.winner_id
    OR players.player_id=matches.loser_id
    GROUP BY players.player_id;

CREATE VIEW v_standings AS
    SELECT v_points.player_id, v_points.name, v_points.wins, v_matches.matches
    FROM v_points
    LEFT JOIN v_matches ON v_matches.player_id = v_points.player_id
    ORDER BY wins DESC;

CREATE VIEW v_rownumber AS 
	SELECT ROW_NUMBER() OVER (ORDER BY wins DESC) AS Row, player_id, name, wins
	FROM v_standings;

CREATE VIEW v_odd AS
	SELECT player_id, name, wins, ROW_NUMBER() OVER (ORDER BY wins DESC) AS next_match
	FROM v_rownumber 
	WHERE (row % 2) <> 0;

CREATE VIEW v_even AS
	SELECT player_id, name, wins, ROW_NUMBER() OVER (ORDER BY wins DESC) AS next_match
	FROM v_rownumber 
	WHERE (row % 2) = 0;

CREATE VIEW v_pairings AS
	SELECT v_even.player_id AS id1, v_even.name AS name1, v_odd.player_id AS id2, v_odd.name AS name2
	FROM v_even
	JOIN v_odd ON v_even.next_match = v_odd.next_match;


/* Test data */
INSERT INTO Players VALUES ('Christian');
INSERT INTO Players VALUES ('Ragnhild');
INSERT INTO Players VALUES ('Henrik');
INSERT INTO Players VALUES ('Line');
INSERT INTO Players VALUES ('Hans Christian');
INSERT INTO Players VALUES ('Inger Elisabeth');
INSERT INTO Players VALUES ('Tone');
INSERT INTO Players VALUES ('Jan');

INSERT INTO Matches VALUES (1, 2);
INSERT INTO Matches VALUES (3, 4);
INSERT INTO Matches VALUES (5, 6);
INSERT INTO Matches VALUES (7, 8);

INSERT INTO Matches VALUES (1, 3);
INSERT INTO Matches VALUES (5, 7);
INSERT INTO Matches VALUES (2, 4);
INSERT INTO Matches VALUES (8, 6);
