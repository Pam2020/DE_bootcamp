
create type vertex_type 
	as enum('player', 'team','game');
 

create table vertices(
	identifier text,
	type vertex_type,
	properties JSON, 
	primary key (identifier, type)
);

create type edge_type
	as enum('plays_against', 
			'shares_team', 
			'plays_in',
			'plays_on');
			
create table edges(
	subject_identifier text, 
	subject_type vertex_type, 
	object_identifier text, 
	object_type vertex_type,
	edge_type edge_type, 
	properties JSON,
	primary key (subject_identifier, 
				 subject_type, 
				 object_identifier, 
				 object_type,
				 edge_type)
);

-- game vertices inserted
insert into vertices
select 
	game_id as identifier,
	'game' :: vertex_type as type,
	json_build_object(
		'pts_home', pts_home,
		'pts_away', pts_away,
		'winning_team' , case 
							when home_team_wins = 1 then home_team_id 
							else visitor_team_id
					   end
	) as properties

from games;

select * from vertices;

-- inserting player vertices
-- always start with the base query, then put it into a with clause (cte)
-- then cehck if the output is as expected and enter it into the table


select * from game_details
where player_name = 'Isaiah Livers';


insert into vertices
with players_agg as (
	select player_id as identifier, 
		   MAX(player_name) as player_name, 
		   COUNT(1) as number_of_games, 
		   SUM(pts) as total_points, 
		   ARRAY_AGG(distinct team_id) as teams
	from game_details 
	group by player_id
)
select identifier, 
	   'player' :: vertex_type, 
	   json_build_object(
	   		'player_name', player_name, 
	   		'number_of_games', number_of_games, 
	   		'total_points', total_points,
	   		'teams', teams
	   ) as properties
from players_agg;

select * from vertices
where type = 'player';

-- inserting teams vertices

select * from teams;

insert into vertices
with teams_dedupped as (
	select *, row_number() over (partition by team_id) as row_num
	from teams
)
select 
	team_id as identifier, 
	'team' :: vertex_type as type,
	json_build_object(
		'abbreviation', abbreviation,
		'nickname', nickname, 
		'year_founded', yearfounded,
		'city', city, 
		'arena', arena
	)
from teams_dedupped
where row_num = 1;

select count(distinct team_id)
from teams


select * from vertices 
where type = 'team';









