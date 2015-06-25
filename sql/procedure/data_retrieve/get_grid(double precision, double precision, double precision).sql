-- Function: taxi.get_grid(double precision, double precision, double precision)

-- DROP FUNCTION taxi.get_grid(double precision, double precision, double precision);

CREATE OR REPLACE FUNCTION taxi.get_grid(
    v_x double precision,
    v_y double precision,
    v_delta double precision DEFAULT 0.002)
  RETURNS bigint AS
$BODY$
declare v_xmin taxi.bounds.x_min%type;
declare v_ymin taxi.bounds.y_min%type;
declare v_xmax taxi.bounds.x_max%type;
declare v_ymax taxi.bounds.y_max%type;
begin
	select
		x_min, y_min,
		x_max, y_max
	from
		taxi.bounds
	into
		v_xmin, v_ymin, v_xmax, v_ymax
	;
	return (
	select
		(floor((v_x - v_xmin) / v_delta)*
			ceil((v_ymax - v_ymin) / v_delta)
		+ (v_y - v_ymin) / v_delta + 1)::bigint
		/*
	from
		taxi.grids	
	where
		st_x(v_point) - x between 0 and v_delta and
		st_y(v_point) - y between 0 and v_delta
	limit 1*/
	);
end;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION taxi.get_grid(double precision, double precision, double precision)
  OWNER TO tx;
