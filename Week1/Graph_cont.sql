select * from teams;


select type, count(*)
from vertices 
group by type;

-- can also be written as 

select type, count(1)
from vertices 
group by 1;

-- here 1 refers to the first retrieved column in the select statement

select player_id, game_id, count(*) from game_details
group by 1,2;


-- creating edges table

insert into edges
select 
	player_id as subject_identifier, 
	'player' ::  vertex_type as subject_type,
	game_id as object_identifier, 
	'game' :: vertex_type as object_type,
	'plays_in':: edge_type as edge_type,
	json_build_object(
		'start_position', start_position, 
		'pts', pts,
		'team_id', team_id, 
		'team_abbreviation', team_abbreviation
	) as properties
from game_details;


select * from vertices v join edges e
on e.subject_identifier = v.identifier 
and e.subject_type = v.type

---


with aggregated as (
select g1.player_id as subject_player_id, 
	   g1.player_name as subject_player_name, 
	   g2.player_id as object_player_id, 
	   g2.player_name as object_player_name, 
	   case when g1.team_abbreviation = g2.team_abbreviation
	   		then 'shares_team' :: edge_type
	   else 'plays_against' :: edge_type
	   end as edge_type,
	   count(1) as num_games,
	   sum(g1.pts) as subject_points,
	   sum(g2.pts) as object_points	   
from game_details g1 join game_details g2
on g1.game_id = g2.game_id and g1.player_name <> g2.player_name
group by g1.player_id, 
	   g1.player_name, 
	   g2.player_id, 
	   g2.player_name, 
	   case when g1.team_abbreviation = g2.team_abbreviation
	   		then 'shares_team' :: edge_type
	   else 'plays_against' :: edge_type
	   end
)
select 
	subject_player_id as subject_identifier, 
	'player' :: vertex_type as subject_type, 
	object_player_id as object_identifier, 
	'player' :: vertex_type as object_type, 
	edge_type as edge_type, 
	json_build_object(
		'num_games', num_games, 
		'subject_points', subject_points, 
		'object_points', object_points
	)
	from aggregated;
	
	
	