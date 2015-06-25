-- Function: taxi.get_nearest_vertex(geometry)

-- DROP FUNCTION taxi.get_nearest_vertex(geometry);

CREATE OR REPLACE FUNCTION taxi.get_nearest_vertex(v_point geometry)
  RETURNS bigint AS
$BODY$
declare v_id bigint;
begin
	select
		id
	from
		taxi.edges_vertices_pgr
	order by
		st_distance_sphere(v_point, the_geom)
	limit 1
	into v_id
	;
	return v_id
	;
end;
$BODY$
  LANGUAGE plpgsql IMMUTABLE STRICT
  COST 100;
ALTER FUNCTION taxi.get_nearest_vertex(geometry)
  OWNER TO jgc;
