-- Function: taxi.generate_grids()

-- DROP FUNCTION taxi.generate_grids();

CREATE OR REPLACE FUNCTION taxi.generate_grids()
  RETURNS void AS
$BODY$
declare v_xmin taxi.bounds.x_min%type;
declare v_ymin taxi.bounds.y_min%type;
declare v_xmax taxi.bounds.x_max%type;
declare v_ymax taxi.bounds.y_max%type;
declare v_delta taxi.bounds.grid_size%type;
begin
	select
		x_min, y_min,
		x_max, y_max,
		grid_size
	from
		taxi.bounds
	into
		v_xmin, v_ymin, v_xmax, v_ymax, v_delta
	;
	truncate table taxi.grids cascade;
	insert into
		taxi.grids(id, x, y)
	select
		row_number() over() id,
		x/1000000.0,
		y/1000000.0
	from
		generate_series((v_xmin*1000000)::int4, (v_xmax*1000000)::int4, (v_delta*1000000)::int4) x,
		generate_series((v_ymin*1000000)::int4, (v_ymax*1000000)::int4, (v_delta*1000000)::int4) y
	;
	-- from west to east, from south to north, following is the grid id increasement trend.
	--   n    2n  .  .   .   .
	--   .    .   .  .   .   .
	--   .    .   .  .   .   .
	--   .    .   .  .   .   .
	--   .    .   .  .   .   .
	--   .    .   .  .   .   .
	--   .    .   .  .   .   .
	--   3   n+3  .  .   .   .
	--   2   n+2  .  .   .   .
	--   1   n+1  .  .   .   .
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION taxi.generate_grids()
  OWNER TO jgc;

-- execute
-- v_delta means the gap of lat or lng, not the distance in km.
-- select taxi.generate_grids();
