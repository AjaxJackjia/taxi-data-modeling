-- Function: taxi.generate_trips_od(timestamp without time zone, timestamp without time zone)

-- DROP FUNCTION taxi.generate_trips_od(timestamp without time zone, timestamp without time zone);

CREATE OR REPLACE FUNCTION taxi.generate_trips_od(
    v_begin timestamp without time zone,
    v_end timestamp without time zone DEFAULT now())
  RETURNS void AS
$BODY$
declare v_trip_id bigint;
declare v_pre_point taxi.gps_raw.point%type;
declare v_point taxi.gps_raw.point%type;
declare v_distance double precision default 0;
declare v_cursor_trips_od no scroll cursor for
	select 
		id
	from
		taxi.trips_od
for update
;
declare v_cur no scroll cursor(v_trip_id bigint) for
	select
		point
	from
		taxi.gps_raw
	where
		trip_id = v_trip_id
	order by
		timestamp
;
begin
	truncate table taxi.trips_od;
	insert into taxi.trips_od
	select distinct
		trip_id,
		id,
		first_value(point) over w o,
		first_value(timestamp) over w s,
		last_value(point) over w d,
		last_value(timestamp) over w e
	from
		taxi.gps_raw
	where 
		trip_id is not null and 
		timestamp between v_begin and v_end
	window w as (
		partition by
			trip_id
		order by
			timestamp
		range between unbounded preceding and unbounded following
	);
	
	open v_cursor_trips_od;
	loop
		fetch v_cursor_trips_od into v_trip_id;
		if(not found) then
			exit;
		end if;
		v_distance = 0;
		open v_cur(v_trip_id);
		fetch v_cur into v_pre_point;
		loop
			fetch v_cur into v_point;
			if(not found) then
				exit;
			end if;
			v_distance = v_distance + st_distance_sphere(v_pre_point, v_point);
			v_pre_point = v_point;
		end loop;
		close v_cur;
		update taxi.trips_od
		set
			mileage = v_distance
		where
			current of v_cursor_trips_od
		;
	end loop;
	close v_cursor_trips_od;
end;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION taxi.generate_trips_od(timestamp without time zone, timestamp without time zone)
  OWNER TO jgc;
