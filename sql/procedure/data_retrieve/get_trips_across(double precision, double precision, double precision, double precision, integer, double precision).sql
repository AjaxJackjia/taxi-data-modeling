-- Function: taxi.get_trips_across(double precision, double precision, double precision, double precision, integer, double precision)

-- DROP FUNCTION taxi.get_trips_across(double precision, double precision, double precision, double precision, integer, double precision);

CREATE OR REPLACE FUNCTION taxi.get_trips_across(
    v_lng1 double precision,
    v_lat1 double precision,
    v_lng2 double precision,
    v_lat2 double precision,
    v_limit integer,
    v_radius double precision DEFAULT 100)
  RETURNS SETOF bigint AS
$BODY$
declare v_record record;
declare v_cnt int default 0;
declare v_pre_trip_id bigint default -1;
declare v_on_trip_b boolean default false;
declare v_on_trip_e boolean default false;
declare v_cur no scroll cursor for
	select 
		point, trip_id
	from
		taxi.gps_raw
	where
		trip_id < 10000
	order by
		trip_id, timestamp
;
begin
	for v_record in v_cur
	loop
		if(v_record.trip_id <> v_pre_trip_id) then
			v_on_trip_b = false;
			v_on_trip_e = false;
			v_pre_trip_id = v_record.trip_id;
		end if;

		if(st_distance_sphere(v_record.point, st_point(v_lng1, v_lat1)) < 50) then
			v_on_trip_b = true;
		end if;
		
		if(st_distance_sphere(v_record.point, st_point(v_lng2, v_lat2)) < 100) then
			v_on_trip_e = true;
			if(v_on_trip_b) then
				return next v_record.trip_id;
				v_cnt = v_cnt + 1;
				if(v_cnt >= v_limit) then
					return;
				end if;
				-- Try another trip
				continue;
			end if;
		end if;
	end loop;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION taxi.get_trips_across(double precision, double precision, double precision, double precision, integer, double precision)
  OWNER TO jgc;
