set schema taxi;
drop procedure get_node;
create procedure get_node(
	in v_id bigint
)language sqlscript as
begin
	select
		longitude, latitude
	from
		nodes
	where
		node_id = v_id
	;
	select
		k, v
	from
		node_tags
	where
		node_id = v_id
	;
end;
call get_node(305202328);

