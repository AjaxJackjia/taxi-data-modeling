-- Function: taxi.get_trips_with_od(double precision, double precision, double precision, double precision, integer, double precision)

-- DROP FUNCTION taxi.get_trips_with_od(double precision, double precision, double precision, double precision, integer, double precision);

CREATE OR REPLACE FUNCTION taxi.get_trips_with_od(
    v_lng1 double precision,
    v_lat1 double precision,
    v_lng2 double precision,
    v_lat2 double precision,
    v_limit integer,
    v_radius double precision DEFAULT 100)
  RETURNS SETOF bigint AS
$BODY$
begin
	return query
	select id
	from
		taxi.trips_od
	where
		st_distance_sphere(st_point(v_lng1, v_lat1), o_point) < v_radius and
		st_distance_sphere(st_point(v_lng2, v_lat2), d_point) < v_radius
	limit v_limit
	;
	/*
	select
		trip_id
	from(
		select distinct
			first_value(point) over w as s,
			last_value(point) over w as e,
			trip_id
		from
			--taxi.gps_raw
			(select * from taxi.gps_raw where trip_id < 10000 limit 10000) as t
		where
			trip_id is not null
		window w as (
			partition by
				trip_id
			order by
				timestamp
			range between UNBOUNDED PRECEDING and UNBOUNDED FOLLOWING
		)) as T
	where
		st_distance_sphere(s, st_point(v_lng1, v_lat1)) < v_radius and
		st_distance_sphere(e, st_point(v_lng2, v_lat2)) < v_radius
	limit v_limit
	;*/
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION taxi.get_trips_with_od(double precision, double precision, double precision, double precision, integer, double precision)
  OWNER TO jgc;
