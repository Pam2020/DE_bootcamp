

select player_name, scoring_class, is_active
from players 
where current_season = 2022;

drop table players_scd;
-- we want to create an SCD table to track changes in two columns at once - can be done by SCD
-- columns we want to track are scoring_class and is_active
create table players_scd(
	player_name text,
	scoring_class scoring_class, -- tracking column 1
	is_active BOOLEAN,  -- tracking column 2
	current_season INTEGER, 
	start_season INTEGER, 
	end_season INTEGER,
	primary key(player_name, start_season)
);

-- How do we create a players table
-- we want to calculate the streak of being in a current dimension
-- when you build a complex CTE, we define one cte and use it in the next, define another one and use it in the following one and so on
-- we are building this with data upto 2021, we will use 2022 data as incremental load

-- this query is more prone to out of memory exceptions, skew problems etc
-- contains 3 window function, we work with full histoiry until the end where we group by and compress the ddata
insert into players_scd
with with_previous as(
select 
	player_name, 
	current_season, 
	scoring_class, 
	is_active,
	LAG(scoring_class, 1) over (partition by player_name order by current_season) as previous_scoring_class, 
	LAG(is_active, 1) over (partition by player_name order by current_season) as previous_is_active
from players
where current_season <= 2021
), with_indicators as (
select *, 
	-- indicator of whether or not the two columns changed at each row-level
	case
		when scoring_class <> previous_scoring_class then 1
		when is_active <> previous_is_active then 1
		else 0
	end as change_indicator
from with_previous
), with_streaks as (
-- we want to keep track of the streak - if they are changing or remaining the same
select *,
	sum(change_indicator) over (partition by player_name order by current_season) as streak_identifier
from with_indicators
)
select player_name, 
	   scoring_class, 
	   is_active, 
	   2021 as current_season,
	   MIN(current_season) as start_season, 
	   MAX(current_season) as end_season	   
from with_streaks
group by player_name, streak_identifier, is_active, scoring_class
order by player_name,streak_identifier
	   
select * from players_scd;

-- create an scd type
CREATE TYPE scd_type AS (
                    scoring_class scoring_class,
                    is_active boolean,
                    start_season INTEGER,
                    end_season INTEGER
                        );

-- new way of doing the same thing

with last_season_scd as (
	select * from players_scd 
	where current_season = 2021
	and end_season =2021
), historical_scd as(
	select player_name, 
		   scoring_class, 
		   is_active, 
		   start_season,
		   end_season
	from players_scd 
	where current_season = 2021
	and end_season < 2021
), this_season_data as(
	select * from players
	where current_season =2022
),
unchanged_records AS (
         SELECT
                ts.player_name,
                ts.scoring_class,
                ts.is_active, 
                ls.start_season,
                ts.current_season as end_season
        FROM this_season_data ts
        JOIN last_season_scd ls
        ON ls.player_name = ts.player_name
         WHERE ts.scoring_class = ls.scoring_class
         AND ts.is_active = ls.is_active
), changed_records AS (
        select ts.player_name,
                -- unnest used to exapnd an array inot a set of rows
                UNNEST(ARRAY[
                    ROW(
                        ls.scoring_class,
                        ls.is_active,
                        ls.start_season,
                        ls.end_season

                        )::scd_type,
                    ROW(
                        ts.scoring_class,
                        ts.is_active, 
                        ts.current_season,
                        ts.current_season
                        )::scd_type
                ]) as records
        FROM this_season_data ts
        LEFT JOIN last_season_scd ls
        ON ls.player_name = ts.player_name
         WHERE (ts.scoring_class <> ls.scoring_class
          OR ts.is_active <> ls.is_active)
 ), unnested_changed_records as (
 	select player_name, 
 	(records :: scd_type).scoring_class,
 	(records :: scd_type).is_active,
 	(records :: scd_type).start_season,
 	(records :: scd_type).end_season
 	from changed_records
 ), new_records as (
	select 
		ts.player_name, 
		ts.scoring_class,
		ts.is_active, 
		ts.current_season as start_season, 
		ts.current_season as end_season
	from this_season_data ts left join last_season_scd ls
	on ts.player_name = ls.player_name
	where ls.player_name is null 
 )
select * from historical_scd
union all
select * from unchanged_records
union all
select * from unnested_changed_records
union all
select * from new_records
order by player_name, start_season

