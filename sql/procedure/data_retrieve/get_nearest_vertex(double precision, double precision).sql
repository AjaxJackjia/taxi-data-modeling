-- Function: taxi.get_nearest_vertex(double precision, double precision)

-- DROP FUNCTION taxi.get_nearest_vertex(double precision, double precision);

CREATE OR REPLACE FUNCTION taxi.get_nearest_vertex(
    v_x double precision,
    v_y double precision)
  RETURNS bigint AS
$BODY$
declare v_id bigint;
begin
	return(
		select
			id
		from
			taxi.edges_vertices_pgr
		order by
			st_distance_sphere(st_point(v_x, v_y), the_geom)
		limit 1
	)
	;
end;
$BODY$
  LANGUAGE plpgsql IMMUTABLE STRICT
  COST 100;
ALTER FUNCTION taxi.get_nearest_vertex(double precision, double precision)
  OWNER TO jgc;
