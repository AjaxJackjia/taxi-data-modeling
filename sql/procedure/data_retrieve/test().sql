-- Function: taxi.test()

-- DROP FUNCTION taxi.test();

CREATE OR REPLACE FUNCTION taxi.test()
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
ALTER FUNCTION taxi.test()
  OWNER TO jgc;
