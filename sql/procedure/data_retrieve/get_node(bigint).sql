-- Function: taxi.get_node(bigint)

-- DROP FUNCTION taxi.get_node(bigint);

CREATE OR REPLACE FUNCTION taxi.get_node(v_node_id bigint)
  RETURNS TABLE (
	id bigint,
	lng double precision,
	lat double precision,
	way_id bigint
  ) AS
$BODY$
begin
	return query 
		select
			T1.id,
			st_x(T1.geom) lng,
			st_y(T1.geom) lat,
			T2.way_id
		from
			nodes T1,
			way_nodes T2 
		where
			T1.id = v_node_id and
			T2.node_id = v_node_id
	;
	return;
end;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
ALTER FUNCTION taxi.get_node(bigint)
  OWNER TO jgc;
