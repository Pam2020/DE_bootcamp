select * from player_seasons; -- player_seasons is the original table

drop table players;

-- players table does not exist, we will create it
select * from players; -- players is the target cumulative table

-- creating a struct to store cumulative season statistics
create type season_stats as(
	season INTEGER,
	gp INTEGER,
	pts real,
	reb real,
	ast real
)

-- create a type scoring_class
create type scoring_class as enum ('star', 'good', 'average', 'bad');

-- create players table
create table players(
	player_name text,
	height text,
	college text,
	country text,
	draft_year text,
	draft_round text,
	draft_number text,
	season_stats season_stats[],
	scoring_class scoring_class,
	years_since_last_season integer,
	current_season INTEGER,
	is_active BOOLEAN,
	primary key(player_name, current_season)
);

-- creating the cumulative table for seasons starting from 1996 to 2022
insert into players
WITH years AS (
    SELECT *
    FROM GENERATE_SERIES(1996, 2022) AS season
), p AS (
    SELECT
        player_name,
        MIN(season) AS first_season
    FROM player_seasons
    GROUP BY player_name
), players_and_seasons AS (
    SELECT *
    FROM p
    JOIN years y
        ON p.first_season <= y.season
), windowed AS(
SELECT
        pas.player_name,
        pas.season,
        ARRAY_REMOVE(
        -- removes elements equal to specified value -- in this case removes array that contains NULLs
            ARRAY_AGG(
            -- ARRAY_AGG combines values from multiple rows into an array
                CASE
                    WHEN ps.season IS NOT NULL
                        THEN ROW(
                            ps.season,
                            ps.gp,
                            ps.pts,
                            ps.reb,
                            ps.ast
                        )::season_stats
                END)
            -- The below window function ensures that the data of a player and a particular season 
            -- comes with a column that contains a cumulative of all the season stats so far    
            OVER (PARTITION BY pas.player_name ORDER BY COALESCE(pas.season, ps.season)),
            NULL
        ) AS seasons
    FROM players_and_seasons pas
    LEFT JOIN player_seasons ps
        ON pas.player_name = ps.player_name
        AND pas.season = ps.season
    ORDER BY pas.player_name, pas.season
 ), static as (
 SELECT
        player_name,
        MAX(height) AS height,
        MAX(college) AS college,
        MAX(country) AS country,
        MAX(draft_year) AS draft_year,
        MAX(draft_round) AS draft_round,
        MAX(draft_number) AS draft_number
    FROM player_seasons
    GROUP BY player_name
 )
 SELECT
    w.player_name,
    s.height,
    s.college,
    s.country,
    s.draft_year,
    s.draft_round,
    s.draft_number,
    seasons AS season_stats,
    CASE
        WHEN (seasons[CARDINALITY(seasons)]::season_stats).pts > 20 THEN 'star'
        WHEN (seasons[CARDINALITY(seasons)]::season_stats).pts > 15 THEN 'good'
        WHEN (seasons[CARDINALITY(seasons)]::season_stats).pts > 10 THEN 'average'
        ELSE 'bad'
    END::scoring_class AS scoring_class,
    w.season - (seasons[CARDINALITY(seasons)]::season_stats).season as years_since_last_active,
    w.season,
    (seasons[CARDINALITY(seasons)]::season_stats).season = season AS is_active
FROM windowed w
JOIN static s
    ON w.player_name = s.player_name;
   
   
select * from players where current_season  = 2022;
 