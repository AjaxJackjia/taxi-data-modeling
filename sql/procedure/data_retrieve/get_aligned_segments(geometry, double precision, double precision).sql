-- Function: taxi.get_aligned_segments(geometry, double precision, double precision)

-- DROP FUNCTION taxi.get_aligned_segments(geometry, double precision, double precision);

CREATE OR REPLACE FUNCTION taxi.get_aligned_segments(
    v_point geometry(Point,4326),
    v_x double precision,
    v_y double precision)
  RETURNS setof record AS
$BODY$
declare v_result record;

begin
	--return acute segments in the same direction
	--return query
	select T1.*
	from
		taxi.segments T1,
		taxi.segment_section T2,
		taxi.section_way T3,
		ways T4,
		nodes T5,
		nodes T6
	where
		T1.id = T2.segment_id and
		T2.section_id = T3.section_id and
		T3.way_id = T4.id and
		T1.from_node = T5.id and
		T1.to_node = T6.id and
		T4.tags->'highway' in (
			select type from taxi.highway_types where id in (select id from taxi.driving_highway_types)
		)and
		T4.tags->'oneway' = 'yes' and
		--same direction
		(st_x(T6.geom)-st_x(T5.geom)) * v_x
			+ (st_y(T6.geom)-st_y(T5.geom)) * v_y  >= 0 and
		((st_x(T6.geom)-st_x(T5.geom)) * v_x
			+ (st_y(T6.geom)-st_y(T5.geom)) * v_y
		)/sqrt((st_x(T6.geom)-st_x(T5.geom))*(st_x(T6.geom)-st_x(T5.geom))
				+ (st_y(T6.geom)-st_y(T5.geom))*(st_y(T6.geom)-st_y(T5.geom)))
		-->= 0.707106 and
		>=0.5 and

		--projection is on segment
		(st_x(v_point)-st_x(T5.geom)) * (st_x(T6.geom)-st_x(T5.geom))
			+ (st_y(v_point)-st_y(T5.geom)) * (st_y(T6.geom)-st_y(T5.geom)) >= 0 and
		(st_x(T6.geom)-st_x(v_point)) *(st_x(T6.geom)-st_x(T5.geom))
			+ (st_y(T6.geom)-st_y(v_point)) * (st_y(T6.geom)-st_y(T5.geom)) >= 0 and
		--nearby
		abs(st_x(v_point) - (st_x(T5.geom) + st_x(T6.geom))/2) <= 0.0015 and
		abs(st_y(v_point) - (st_y(T5.geom) + st_y(T6.geom))/2) <= 0.0015 and
		st_distance_sphere(v_point, st_makeline(T5.geom, T6.geom)) < 20
	order by
		st_distance_sphere(v_point, st_makeline(T5.geom, T6.geom))
		--abs(st_x(v_point) - (st_x(T5.geom) + st_x(T6.geom))/2),
		--abs(st_y(v_point) - (st_y(T5.geom) + st_y(T6.geom))/2)
	into v_result
	;
	if(v_result is not null) then
		return next v_result;
		return;
	end if;
	--in the same direction but not acute
	v_result = null;
	--return query
	select T1.*
	from
		taxi.segments T1,
		taxi.segment_section T2,
		taxi.section_way T3,
		ways T4,
		nodes T5,
		nodes T6
	where
		T1.id = T2.segment_id and
		T2.section_id = T3.section_id and
		T3.way_id = T4.id and
		T1.from_node = T5.id and
		T1.to_node = T6.id and
		T4.tags->'highway' in (
			select type from taxi.highway_types where id in (select id from taxi.driving_highway_types)
		)and
		T4.tags->'oneway' = 'yes' and
		--same direction
		(st_x(T6.geom)-st_x(T5.geom)) * v_x
			+ (st_y(T6.geom)-st_y(T5.geom)) * v_y  >= 0 and
		((st_x(T6.geom)-st_x(T5.geom)) * v_x 
			+ (st_y(T6.geom)-st_y(T5.geom)) * v_y)
		/sqrt(
			(st_x(T6.geom)-st_x(T5.geom))*(st_x(T6.geom)-st_x(T5.geom))
			+ (st_y(T6.geom)-st_y(T5.geom))*(st_y(T6.geom)-st_y(T5.geom))
		) >= 0.707106 and
		--projection is on segment
		not (
		(st_x(v_point)-st_x(T5.geom)) * (st_x(T6.geom)-st_x(T5.geom))
			+ (st_y(v_point)-st_y(T5.geom)) * (st_y(T6.geom)-st_y(T5.geom)) >= 0 and
		(st_x(T6.geom)-st_x(v_point)) *(st_x(T6.geom)-st_x(T5.geom))
			+ (st_y(T6.geom)-st_y(v_point)) * (st_y(T6.geom)-st_y(T5.geom)) >= 0) and
		--nearby
		abs(st_x(v_point) - (st_x(T5.geom) + st_x(T6.geom))/2) <= 0.0015 and
		abs(st_y(v_point) - (st_y(T5.geom) + st_y(T6.geom))/2) <= 0.0015 and
		st_distance_sphere(v_point, st_makeline(T5.geom, T6.geom)) < 20
	order by
		st_distance_sphere(v_point, st_makeline(T5.geom, T6.geom))
		--abs(st_x(v_point) - (st_x(T5.geom) + st_x(T6.geom))/2),
		--abs(st_y(v_point) - (st_y(T5.geom) + st_y(T6.geom))/2)
	into v_result
	;
	if(v_result is not null) then
		return next v_result;
		return;
	end if;
	--Those does not bear direction information
	--return query
	select T1.*
	from
		taxi.segments T1,
		taxi.segment_section T2,
		taxi.section_way T3,
		ways T4,
		nodes T5,
		nodes T6
	where
		T1.id = T2.segment_id and
		T2.section_id = T3.section_id and
		T3.way_id = T4.id and
		T1.from_node = T5.id and
		T1.to_node = T6.id and
		T4.tags->'highway' in (
			select type from taxi.highway_types where id in (select id from taxi.driving_highway_types)
		)and
		(T4.tags->'oneway' <> 'yes' or not T4.tags?'oneway') and
		--nearby
		abs(st_x(v_point) - (st_x(T5.geom) + st_x(T6.geom))/2) <= 0.0015 and
		abs(st_y(v_point) - (st_y(T5.geom) + st_y(T6.geom))/2) <= 0.0015 and
		st_distance_sphere(v_point, st_makeline(T5.geom, T6.geom)) < 20
	order by
		st_distance_sphere(v_point, st_makeline(T5.geom, T6.geom)),
		abs((st_x(T6.geom)-st_x(T5.geom))*v_x + (st_y(T6.geom)-st_y(T5.geom))*v_y)
		/ sqrt(
			(st_x(T6.geom)-st_x(T6.geom))*(st_x(T6.geom)-st_x(T6.geom))
			+(st_y(T6.geom)-st_y(T5.geom))*(st_y(T6.geom)-st_y(T5.geom)
		)) desc
		--abs(st_x(v_point) - (st_x(T5.geom) + st_x(T6.geom))/2),
		--abs(st_y(v_point) - (st_y(T5.geom) + st_y(T6.geom))/2)
	into v_result;
	
	if(v_result is not null) then
		return next v_result;
		return;
	end if;
end;
$BODY$
  LANGUAGE plpgsql IMMUTABLE strict
  COST 100;
ALTER FUNCTION taxi.get_aligned_segments(geometry, double precision, double precision)
  OWNER TO jgc;
