-- Function: taxi.get_trips(character varying)

-- DROP FUNCTION taxi.get_trips(character varying);
-- This procedure filles the field trip_id of taxi.gps_raw
CREATE OR REPLACE FUNCTION taxi.get_trips(
	in v_uid character varying,
	in v_begin timestamp,
	in v_end timestamp
)
  RETURNS void AS
$BODY$
declare v_id bigint default 0;
declare v_record record;
begin
	create temp table T1 on commit drop as
	select
		row_number() over (), id, point, timestamp
	from (
		select
			lead(state) over w,
			lag(state) over w,
			state,
			point, id,
			st_x(point) longitude,
			st_y(point) latitude,
			timestamp
		from
			taxi.gps_raw
		where
			timestamp between v_begin and v_end and
			id = v_uid
		window w as (
			order by
				timestamp
		)
	) as T
    where
        lead and
        not lag and
        state
    ;

    drop table if exists T2;
	create temp table T2 on commit drop as
	select
		row_number() over (), id, point, timestamp
	from (
		select
			lead(state) over w,
			lag(state) over w,
			state,
			point, id,
			st_x(point) longitude,
			st_y(point) latitude,
			timestamp
		from
			taxi.gps_raw
		where
			timestamp between v_begin and v_end and
			id = v_uid
		window w as (
			order by
				timestamp
		)
	) as T
    where
        not lead and
        lag and
        state and
        timestamp > (select min(timestamp) from T1)
	;
	for v_record in
	select
		T1.id, T1.point, T1.timestamp s, T2.point, T2.timestamp e
	from
		T1 inner join T2 on
			T1.row_number = T2.row_number
	loop
		update taxi.gps_raw 
		set 
			trip_id = v_id
		where
			id = v_record.id and
			timestamp >= v_record.s and
			timestamp <= v_record.e and
			state
		;
		v_id = v_id + 1;
	end loop
	;

end;
$BODY$
  LANGUAGE plpgsql
  COST 100
;
ALTER FUNCTION taxi.get_trips(character varying)
  OWNER TO jgc;
