-- Function: taxi.get_grid_id(double precision, double precision)

-- DROP FUNCTION taxi.get_grid_id(double precision, double precision);

CREATE OR REPLACE FUNCTION taxi.get_grid_id(
    v_x double precision,
    v_y double precision)
  RETURNS bigint AS
$BODY$
declare v_grid_size taxi.bounds.grid_size%type;
begin
	select
		grid_size
	from
		taxi.bounds
	into
		v_grid_size
	;
	return (
	select
		id
	from
		taxi.grids	
	where
		x <= v_x and
		v_x <= (x + v_grid_size) and
		y <= v_y and
		v_y <= (y + v_grid_size)
	limit 1
	);
end;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION taxi.get_grid_id(double precision, double precision)
  OWNER TO jgc;
