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
			timestamp between v_begin and v_end and
			id = v_uid
		order by
			timestamp
;
begin
	open v_cur;
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
	end loop;
	close v_cur;

end;
$BODY$
  LANGUAGE plpgsql
  COST 100;
ALTER FUNCTION taxi.get_od(character varying, timestamp without time zone, timestamp without time zone)
  OWNER TO jgc;
