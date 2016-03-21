-- Function: taxi.get_section(bigint)

-- DROP FUNCTION taxi.get_section(bigint);

CREATE OR REPLACE FUNCTION taxi.get_section(v_id bigint)
  RETURNS refcursor AS
$BODY$
declare result refcursor;
begin
	open result for
	select
		st_x(T4.geom) from_lng, st_y(T4.geom) from_lat,
		st_x(T5.geom) to_lng, st_y(T5.geom) to_lat,
		T1.id section_id,
		T2.id segment_id,
		T7.id way_id, 
		T7.tags->'name' way_name
	from
		taxi.sections T1,
		taxi.segments T2,
		taxi.segment_section T3,
		nodes T4,
		nodes T5,
		taxi.section_way T6,
		ways T7
	where
		T1.id = v_id and
		T1.id = T3.section_id and
		T2.id = T3.segment_id and
		T1.from_node = T4.id and
		T1.to_node = T5.id and
		T1.id = T6.section_id and
		T6.way_id = T7.id
	;

	return result;
end;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
ALTER FUNCTION taxi.get_section(bigint)
  OWNER TO jgc;
