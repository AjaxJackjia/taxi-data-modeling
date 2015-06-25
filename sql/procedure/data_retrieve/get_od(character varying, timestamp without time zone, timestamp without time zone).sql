-- Function: taxi.get_od(character varying, timestamp without time zone, timestamp without time zone)

-- DROP FUNCTION taxi.get_od(character varying, timestamp without time zone, timestamp without time zone);

CREATE OR REPLACE FUNCTION taxi.get_od(
    v_uid character varying,
    v_begin timestamp without time zone,
    v_end timestamp without time zone DEFAULT now())
  RETURNS setof record AS
$BODY$
declare v_record record;
declare v_pre_state boolean default false;
declare v_o_point taxi.gps_raw.point%type;
declare v_o_time timestamp;
declare v_d_point taxi.gps_raw.point%type;
declare v_d_time timestamp;
declare	v_cur no scroll cursor for
		select 
			id, state, point, timestamp
		from
			taxi.gps_raw
		where
			id = v_uid
		order by
			timestamp
;
begin
	open v_cur;
	--fetch next from v_cur into v_record;
	--raise notice 'begin %', found;
	loop
		fetch v_cur into v_record;
		if(not found) then
			exit;
		end if;
		if(not v_pre_state and v_record.state) then
			v_o_point = v_record.point;
			v_o_time = v_record.timestamp;
			v_pre_state = true;
		elsif(v_pre_state and v_record.state) then
			v_d_point = v_record.point;
			v_d_time = v_record.timestamp;
		elsif(v_pre_state and not v_record.state) then
			return next row(v_uid, v_o_point, v_o_time, v_d_point, v_d_time);
			v_pre_state = false;
		end if;
		fetch v_cur into v_record;
	end loop;
	close v_cur;
	/*
	drop table if exists T1;
	create temp table  T1 on commit drop as
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
	
	return query
	select
		T1.id, T1.point, T1.timestamp, T2.point, T2.timestamp
	from
		T1 inner join T2 on
			T1.row_number = T2.row_number
	;*/

end;
$BODY$
  LANGUAGE plpgsql
  COST 100;
ALTER FUNCTION taxi.get_od(character varying, timestamp without time zone, timestamp without time zone)
  OWNER TO jgc;
