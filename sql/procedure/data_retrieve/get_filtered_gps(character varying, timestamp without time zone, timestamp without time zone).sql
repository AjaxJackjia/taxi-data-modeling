-- Function: taxi.get_filtered_gps(character varying, timestamp without time zone, timestamp without time zone)

-- DROP FUNCTION taxi.get_filtered_gps(character varying, timestamp without time zone, timestamp without time zone);

CREATE OR REPLACE FUNCTION taxi.get_filtered_gps(
    v_uid character varying,
    v_begin timestamp without time zone,
    v_end timestamp without time zone DEFAULT now())
  RETURNS setof record AS
$BODY$
begin
	return query
	select
		st_x(point) lng,
		st_y(point) lat,
		timestamp,
		point
	from
		taxi.gps_raw
	where
		id = v_uid and
		timestamp between v_begin and v_end
	order by
		timestamp
	;

end;$BODY$
  LANGUAGE plpgsql IMMUTABLE STRICT
  COST 100;
ALTER FUNCTION taxi.get_filtered_gps(character varying, timestamp without time zone, timestamp without time zone)
  OWNER TO jgc;
