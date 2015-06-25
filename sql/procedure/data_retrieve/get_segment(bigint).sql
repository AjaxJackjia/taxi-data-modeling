-- Function: taxi.get_segment(bigint)

-- DROP FUNCTION taxi.get_segment(bigint);

CREATE OR REPLACE FUNCTION taxi.get_segment(v_id bigint)
  RETURNS refcursor AS
$BODY$
declare result refcursor;
begin
	open result for
	select
		T1.from_node, T1.to_node,
		st_x(T2.geom) from_lng, st_y(T2.geom) from_lat,
		st_x(T3.geom) to_lng, st_y(T3.geom) to_lat,
		T4.section_id,
		T5.way_id,
		T6.tags->'name' way_name
	from
		taxi.segments T1,
		nodes T2,
		nodes T3,
		taxi.segment_section T4,
		taxi.section_way T5,
		ways T6
	where
		T1.id = v_id and
		T1.from_node = T2.id and
		T1.to_node = T3.id and
		T1.id = T4.segment_id and
		T4.section_id = T5.section_id and
		T5.way_id = T6.id
	;
		
	return result;	
end;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
ALTER FUNCTION taxi.get_segment(bigint)
  OWNER TO jgc;
--select taxi.get_segment(1)