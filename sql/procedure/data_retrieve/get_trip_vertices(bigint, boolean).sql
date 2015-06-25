-- Function: taxi.get_trip_vertices(bigint, boolean)

-- DROP FUNCTION taxi.get_trip_vertices(bigint, boolean);

CREATE OR REPLACE FUNCTION taxi.get_trip_vertices(
    v_trip_id bigint,
    v_adjacent boolean DEFAULT false)
  RETURNS SETOF bigint AS
$BODY$
declare v_pre_rec record;
declare v_cur_rec record;
declare v_pre_vertex bigint := -1;
declare v_cur_vertex bigint;
declare v_cur no scroll cursor for
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
	open v_cur;
	fetch v_cur into v_pre_rec;
	fetch v_cur into v_cur_rec;
	if(not found) then
		exit;
	end if;
	--skip identical records
	while(v_cur_rec = v_pre_rec and found) loop
		fetch v_cur into v_cur_rec;
	end loop;

	select 
		taxi.get_nearest_vertex(
			v_cur_rec.point,
			sin(st_azimuth(v_pre_rec.point, v_cur_rec.point)),
			cos(st_azimuth(v_pre_rec.point, v_cur_rec.point))
		)
	into v_pre_vertex;
	return next v_pre_vertex;
	v_pre_rec = v_cur_rec;
	
	loop
		fetch v_cur into v_cur_rec;
		if(not found) then
			exit;
		end if;

		select 
			taxi.get_nearest_vertex(
				v_cur_rec.point,
				sin(st_azimuth(v_pre_rec.point, v_cur_rec.point)),
				cos(st_azimuth(v_pre_rec.point, v_cur_rec.point))
			)
		into v_cur_vertex;
		v_pre_rec = v_cur_rec;
		raise notice '%', v_cur_vertex;
		if(v_cur_vertex <> v_pre_vertex) then
			if(not v_adjacent) then
				return next v_cur_vertex;
			elsif(not (select taxi.is_adjacent(v_pre_vertex, v_cur_vertex))) then
				return query
					select
						id1::bigint
					from
						pgr_dijkstra('select id, source::int4, target::int4,
							len as cost, rlen as reverse_cost 
							from taxi.edges', 
							v_pre_vertex::int4, v_cur_vertex::int4, true, true)
					where
						seq > 0
				;
			else
				return next v_cur_vertex;
			end if;
			v_pre_vertex = v_cur_vertex;
		end if;
	end loop;
	close v_cur;
end;
$BODY$
  LANGUAGE plpgsql IMMUTABLE STRICT
  COST 100
  ROWS 1000;
ALTER FUNCTION taxi.get_trip_vertices(bigint, boolean)
  OWNER TO tx;
