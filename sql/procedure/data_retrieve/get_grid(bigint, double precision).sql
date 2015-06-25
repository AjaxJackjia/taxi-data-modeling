-- Function: taxi.get_grid(bigint, double precision)

-- DROP FUNCTION taxi.get_grid(bigint, double precision);

CREATE OR REPLACE FUNCTION taxi.get_grid(
    v_id bigint,
    v_delta double precision DEFAULT 0.002)
  RETURNS geography AS
$BODY$
declare v_x taxi.grids.x%type;
declare v_y taxi.grids.y%type;
begin
	select
		x, y
	from
		taxi.grids
	where
		id = v_id
	into 
		v_x, v_y
	;
	return (
	select
		ST_Polygon(
			st_makeLine(
				Array[
					st_point(v_x, v_y),
					st_point(v_x, v_y + v_delta),
					st_point(v_x + v_delta, v_y + v_delta),
					st_point(v_x + v_delta, v_y),
					st_point(v_x, v_y)
				]
			), 4326
		)
	);

end;

$BODY$
  LANGUAGE plpgsql IMMUTABLE STRICT
  COST 100;
ALTER FUNCTION taxi.get_grid(bigint, double precision)
  OWNER TO jgc;
