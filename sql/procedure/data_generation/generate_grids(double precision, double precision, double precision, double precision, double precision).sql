-- Function: taxi.generate_grids(double precision, double precision, double precision, double precision, double precision)

-- DROP FUNCTION taxi.generate_grids(double precision, double precision, double precision, double precision, double precision);

CREATE OR REPLACE FUNCTION taxi.generate_grids(
    v_xmin double precision,
    v_ymin double precision,
    v_xmax double precision,
    v_ymax double precision,
    v_delta double precision)
  RETURNS void AS
$BODY$
begin
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
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION taxi.generate_grids(double precision, double precision, double precision, double precision, double precision)
  OWNER TO jgc;

-- execute
-- v_delta means the gap of lat or lng, not the distance in km.
--select taxi.generate_grids(-122.528, 37.7058, -122.346, 37.8174, 0.002);
