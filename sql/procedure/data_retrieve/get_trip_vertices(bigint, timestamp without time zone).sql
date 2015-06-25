-- Function: taxi.get_trip_vertices(bigint, timestamp without time zone)

-- DROP FUNCTION taxi.get_trip_vertices(bigint, timestamp without time zone);

CREATE OR REPLACE FUNCTION taxi.get_trip_vertices(
    v_trip_id bigint,
    v_time timestamp without time zone)
  RETURNS SETOF bigint AS
$BODY$
declare v_pre record;
declare v_trace record;
declare v_pre_vertex bigint := -1;
declare v_cur_vertex bigint;
begin
	select 
		T1.*
	from
		taxi.gps_raw T1,
		taxi.trips_od T2
	where
		T1.id = T2.uid and
		T2.id = v_trip_id and
		T1.timestamp = T2.o_time
	into v_pre
	;
	for v_trace in
	select
		T1.*
	from
		taxi.gps_raw T1,
		taxi.trips_od T2
	where
		T1.id = T2.uid and
		T2.id = v_trip_id and
		T1.timestamp > T2.o_time and
		T1.timestamp <= v_time
	order by
		T1.timestamp
	loop
	select 
		taxi.get_nearest_vertex(
			v_trace.point,
			sin(st_azimuth(v_pre.point, v_trace.point)),
			cos(st_azimuth(v_pre.point, v_trace.point))
		)
	into v_cur_vertex
	;
	if(v_cur_vertex <> v_pre_vertex) then
		return next v_cur_vertex;
	end if
	;
	v_pre_vertex = v_cur_vertex
	;
	end loop
	;

end;
$BODY$
  LANGUAGE plpgsql IMMUTABLE STRICT
  COST 100
  ROWS 1000;
ALTER FUNCTION taxi.get_trip_vertices(bigint, timestamp without time zone)
  OWNER TO jgc;
