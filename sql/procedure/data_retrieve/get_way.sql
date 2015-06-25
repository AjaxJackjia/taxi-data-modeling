set schema taxi;
drop procedure get_way;
create procedure get_way(
	in v_id bigint
)language sqlscript as
begin
	select
		longitude, latitude, sequence_id
	from
		way_nodes T1,
		nodes T2
	where
		way_id = v_id and
		T1.node_id = T2.node_id
	;
	select
		k, v
	from
		way_tags
	where
		way_id = v_id
	;
end;
call get_way(155882943);
