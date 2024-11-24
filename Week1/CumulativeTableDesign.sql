select * from player_seasons;

create type season_stats as(
	season INTEGER,
	gp INTEGER,
	pts real,
	reb real,
	ast real
)

-- ignore weight and height for the moment as it keeps changing
create table players(
	player_name text,
	height text,
	college text,
	country text,
	draft_year text,
	draft_round text,
	draft_number text,
	season_stats season_stats[],
	current_season INTEGER,
	primary key(player_name, current_season)
)

-- think about the full outer join logic

select min(season) from player_seasons;




-- seed for the cumulative table design, yesterday table is empty as we are startig with the min season data in the today's table
-- once the seed is ready we insert this data into the new table created earlier
insert into players
WITH yesterday as(
	SELECT * FROM players
	WHERE current_season = 1995
),
today AS (
	SELECT * FROM player_seasons
	WHERE season = 1996
)
SELECT 
	coalesce(t.player_name, y.player_name) as player_name,
	coalesce(t.height, y.height) as height,
	coalesce(t.college, y.college) as college,
	coalesce(t.country, y.country) as country,
	coalesce(t.draft_year, y.draft_year) as draft_year,
	coalesce(t.draft_round, y.draft_round) as draft_round,
	coalesce(t.draft_number, y.draft_number) as draft_number,
	case when y.season_stats IS null
		then ARRAY[row(
			t.season,
			t.gp,
			t.pts,
			t.reb,
			t.ast
		) :: season_stats]
	when t.season is not null then y.season_stats || ARRAY[row(
			t.season,
			t.gp,
			t.pts,
			t.reb,
			t.ast
		) :: season_stats]
	else y.season_stats
	end as season_stats,
	coalesce(t.season, y.current_season +1) as current_season

FROM yesterday y FULL OUTER JOIN today t
ON y.player_name = t.player_name;


select * from players;


-- cumulative begins by changing the years in these two CTEs
insert into players
WITH yesterday as(
	SELECT * FROM players
	WHERE current_season = 2000
),
today AS (
	SELECT * FROM player_seasons
	WHERE season = 2001
)
SELECT 
	coalesce(t.player_name, y.player_name) as player_name,
	coalesce(t.height, y.height) as height,
	coalesce(t.college, y.college) as college,
	coalesce(t.country, y.country) as country,
	coalesce(t.draft_year, y.draft_year) as draft_year,
	coalesce(t.draft_round, y.draft_round) as draft_round,
	coalesce(t.draft_number, y.draft_number) as draft_number,
	case when y.season_stats IS null
		then ARRAY[row(
			t.season,
			t.gp,
			t.pts,
			t.reb,
			t.ast
		) :: season_stats]
	when t.season is not null then y.season_stats || ARRAY[row(
			t.season,
			t.gp,
			t.pts,
			t.reb,
			t.ast
		) :: season_stats]
	else y.season_stats
	end as season_stats,
	coalesce(t.season, y.current_season +1) as current_season

FROM yesterday y FULL OUTER JOIN today t
ON y.player_name = t.player_name;

-- checking the history of Michael Jordan in 2001
select * from players where current_season = 2001 and player_name ='Michael Jordan';


-- unnesting the struct and getting all the values in the array
-- useful for run length encoding - maintains sorting
-- even when we perform joins, the temporal components stay together and once we join we can unnest them and the sorting remains intact

with unnested as(
select player_name, unnest(season_stats) :: season_stats as season_stats
from players 
where current_season = 2001 
)

select player_name, (season_stats :: season_stats).*
from unnested;


-- new players table

drop table players;

create type scoring_class as enum ('star', 'good', 'average', 'bad');

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
	primary key(player_name, current_season)
);

insert into players
WITH yesterday as(
	SELECT * FROM players
	WHERE current_season = 2000
),
today AS (
	SELECT * FROM player_seasons
	WHERE season = 2001
)
SELECT 
	coalesce(t.player_name, y.player_name) as player_name,
	coalesce(t.height, y.height) as height,
	coalesce(t.college, y.college) as college,
	coalesce(t.country, y.country) as country,
	coalesce(t.draft_year, y.draft_year) as draft_year,
	coalesce(t.draft_round, y.draft_round) as draft_round,
	coalesce(t.draft_number, y.draft_number) as draft_number,
	case when y.season_stats IS null
		then ARRAY[row(
			t.season,
			t.gp,
			t.pts,
			t.reb,
			t.ast
		) :: season_stats]
	when t.season is not null then y.season_stats || ARRAY[row(
			t.season,
			t.gp,
			t.pts,
			t.reb,
			t.ast
		) :: season_stats]
	else y.season_stats
	end as season_stats,
	case 
		when t.season is not null then
		case when t.pts > 20 then 'star'
		when t.pts > 15 then 'good'
		when t.pts > 10 then 'average'
		else 'bad'
		end :: scoring_class
	else y.scoring_class 
	end as scoring_class,
	
	case 
		when t.season is null then years_since_last_season + 1 
		else 0
		end as years_since_last_season, 
	coalesce(t.season, y.current_season +1) as current_season

FROM yesterday y FULL OUTER JOIN today t
ON y.player_name = t.player_name;


select 
* from players where current_season = 2001;


select player_name,
--	   season_stats[1].pts as first_season_points,
--	   season_stats[cardinality(season_stats)].pts as last_season_points, 
	   season_stats[cardinality(season_stats)].pts/
	   case when season_stats[1].pts = 0 then 1
	   ELSE season_stats[1].pts end  as growth
from players where current_season = 2001
order by 2 desc;
	   
--and player_name = 'Don MacLean';

-- Incrementally build history and makes historical data analysis extremely quick