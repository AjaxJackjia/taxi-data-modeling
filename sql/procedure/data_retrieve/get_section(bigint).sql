-- Function: taxi.get_section(bigint)

-- DROP FUNCTION taxi.get_section(bigint);

CREATE OR REPLACE FUNCTION taxi.get_section(v_id bigint)
  RETURNS refcursor AS
$BODY$
declare result refcursor;
begin
	open result for
	select
		st_x(T2.geom) from_lng, st_y(T2.geom) from_lat,
		st_x(T3.geom) to_lng, st_y(T3.geom) to_lat,
		T5.id way_id, 
		T5.tags->'name' way_name
	from
		taxi.sections T1,
		nodes T2,
		nodes T3,
		taxi.section_way T4,
		ways T5
	where
		T1.id = v_id and
		T1.from_node = t2.id and
		T1.to_node = t3.id and
		T1.id = T4.section_id and
		T4.way_id = t5.id
	;

	return result;
end;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
ALTER FUNCTION taxi.get_section(bigint)
  OWNER TO jgc;
 --select taxi.get_section(0)
