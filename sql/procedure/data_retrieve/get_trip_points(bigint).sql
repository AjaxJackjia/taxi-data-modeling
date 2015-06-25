-- Function: taxi.get_trip_points(bigint)

-- DROP FUNCTION taxi.get_trip_points(bigint);

CREATE OR REPLACE FUNCTION taxi.get_trip_points(v_trip_id bigint)
  RETURNS setof record  AS
$BODY$
begin
	return query
		select
			st_x(point) lng,
			st_y(point) lat
		from
			taxi.gps_raw
		where
			trip_id = v_trip_id
		order by
			timestamp
	;
	
end;
$BODY$
  LANGUAGE plpgsql IMMUTABLE STRICT
  COST 100
  ROWS 1000;
ALTER FUNCTION taxi.get_trip_points(bigint)
  OWNER TO jgc;
