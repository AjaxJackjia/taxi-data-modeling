set schema taxi;
drop procedure get_way_by_name;
create procedure get_way_by_name(
	in v_way_name varchar(32)
)language sqlscript as
begin
	select
		longitude, latitude
	from
		nodes T1,
		way_tags T2,
		way_nodes T3
	where
		T2.k = 'name' and
		T2.v = v_way_name and
		T2.way_id = T3.way_id and
		T3.node_id = T1.node_id
	;
	select
		distinct T1.k, T1.v
	from
		way_tags T1,
		way_tags T2
	where
		T1.way_id = T2.way_id and
		T2.k = 'name' and
		T2.v = v_way_name
	;
		
end;
call get_way_by_name('中山东路')
