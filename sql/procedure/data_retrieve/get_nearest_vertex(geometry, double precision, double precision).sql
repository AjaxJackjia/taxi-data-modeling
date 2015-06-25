-- Function: taxi.get_nearest_vertex(geometry, double precision, double precision)

-- DROP FUNCTION taxi.get_nearest_vertex(geometry, double precision, double precision);

CREATE OR REPLACE FUNCTION taxi.get_nearest_vertex(
    v_point geometry,
    v_x double precision,
    v_y double precision)
  RETURNS bigint AS
$BODY$
declare v_id bigint;
declare v_edge bigint;
begin
	raise notice '% %, %', st_asText(v_point), v_x, v_y;
	select
		target, id
	from
		taxi.edges
	where
		(x2 - st_x(v_point))*(x2 - x1) + (y2 - st_y(v_point))*(y2 - y1) >= 0 and
		(st_x(v_point) - x1)*(x2 - x1) + (st_y(v_point) - y1)*(y2 - y1) >= 0 and
		abs(len - rlen) >= 2*len and
		st_distance(v_point::geography, the_geom) < 50 and
		((x2 - x1)*v_x + (y2 - y1)*v_y )/ sqrt(
			(x2 - x1)*(x2 - x1) + (y2-y1)*(y2-y1))> 0.1 and
		not (x1=x2 and y1=y2)
	order by
		st_distance(v_point, the_geom)
	limit 1
	into v_id, v_edge;
	raise notice 'directed % % % ', FOUND, v_id, v_edge;
	if(FOUND) then
		return v_id;
	end if;
	select
		(case when (x2 - x1)*v_x + (y2 - y1)*v_y >=0 then 
			target
		else 
			source
		end) as target, 
		id 
	from
		taxi.edges
	where
		(x2 - st_x(v_point))*(x2 - x1) + (y2 - st_y(v_point))*(y2 - y1) >= 0 and
		(st_x(v_point) - x1)*(x2 - x1) + (st_y(v_point) - y1)*(y2 - y1) >= 0 and
		abs(len - rlen) <= 1000
	order by
		st_distance(v_point, the_geom)
	limit 1
	into v_id, v_edge;
	raise notice '% %', v_id, v_edge;
	if(FOUND) then
		return v_id;
	end if;	
	
end;
$BODY$
  LANGUAGE plpgsql IMMUTABLE STRICT
  COST 100;
ALTER FUNCTION taxi.get_nearest_vertex(geometry, double precision, double precision)
  OWNER TO jgc;
