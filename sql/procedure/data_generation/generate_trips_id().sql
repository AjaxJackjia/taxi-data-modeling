-- Function: taxi.generate_trips_id()

-- DROP FUNCTION taxi.generate_trips_id();

CREATE OR REPLACE FUNCTION taxi.generate_trips_id()
  RETURNS void AS
$BODY$
declare v_record record;
declare v_pre_state boolean default false;
declare v_trip_id bigint default 0;
declare v_pre_id taxi.gps_raw.id%type default '';
declare	v_cur no scroll cursor for
		select 
			id, state, timestamp
		from
			taxi.gps_raw
		order by
			id, timestamp
	for update
;
begin
	for v_record in v_cur
	loop
		if(v_pre_id <> v_record.id) then
			v_pre_id = v_record.id;
			v_pre_state = false;
		end if;
		--continuous uncarried
		if(not v_pre_state and not v_record.state) then
			continue;
		end if;
		--carried to uncarried
		if(v_pre_state and not v_record.state) then
			v_pre_state = false;
			continue;
		end if;
		--uncarried to carried
		if(not v_pre_state and v_record.state) then
			v_trip_id = v_trip_id + 1;
			v_pre_state = true;
		end if;

		update 
			taxi.gps_raw
		set 
			trip_id = v_trip_id
		where
			current of v_cur
		;
	end loop;
	--Delete trips which are too short
	update taxi.gps_raw
	set
		trip_id = null
	where
		trip_id in (
			select 
				trip_id
			from
				taxi.gps_raw
			group by
				trip_id
			having
				count(*) <= 4
		)
	;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION taxi.generate_trips_id()
  OWNER TO jgc;
