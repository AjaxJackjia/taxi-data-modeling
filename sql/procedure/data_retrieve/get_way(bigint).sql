-- Function: taxi.get_way(bigint)

-- DROP FUNCTION taxi.get_way(bigint);

CREATE OR REPLACE FUNCTION taxi.get_way(v_way_id in bigint)
  RETURNS setof refcursor AS
$BODY$
declare 
	r_way_pos refcursor;
	r_way_tags refcursor;
begin
	open r_way_pos for
	select
		st_x(T2.geom) longitude,
		st_y(T2.geom) latitude
	from
		way_nodes T1,
		nodes T2
	where
		T1.node_id = T2.id and
		T1.way_id = v_way_id
	order by
		T1.sequence_id
	;
	return next r_way_pos;
	
	open r_way_tags for
	select 
		(each(tags)).key,
		(each(tags)).value		
	from
		ways
	where
		id = v_way_id
	;
	return next r_way_tags;
	
	
end;$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
ALTER FUNCTION taxi.get_way(bigint)
  OWNER TO jgc;