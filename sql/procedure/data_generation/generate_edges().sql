-- Function: taxi.generate_edges()

-- DROP FUNCTION taxi.generate_edges();

CREATE OR REPLACE FUNCTION taxi.generate_edges()
  RETURNS void AS
$BODY$
declare v_edge record;
declare v_id bigint := 0;
begin
	truncate table taxi.edges;
	for v_edge in
	select
		T1.from_node source,
		T1.to_node target,
		taxi.get_len_of_section(T1.id) len,
		st_x(T4.geom) x1,
		st_y(T4.geom) y1,
		st_x(T5.geom) x2,
		st_y(T5.geom) y2,		
		taxi.get_geometry_of_section(T1.id) the_geom,
		--default maxspeed = 60kph
		case when T3.tags ? 'maxspeed' then
				case when T3.tags->'maxspeed' like '%mph' then
					cast(substring(T3.tags->'maxspeed' from '\d+') as real) * 1.60934
				when T3.tags->'maxspeed' like '%kph' then
					cast(substring(T3.tags->'maxspeed' from '\d+') as real)
				end
			else
				null
		end maxspeed,
		case when T3.tags->'oneway'='yes' or T3.tags->'oneway'='1' then
				10000000
			else
				taxi.get_len_of_section(T1.id)
		end rlen
	from
		taxi.sections T1,
		taxi.section_way T2,
		ways T3,
		nodes T4,
		nodes T5
	where
		T1.id = T2.section_id and
		T2.way_id = T3.id and
		T1.from_node = T4.id and
		T1.to_node = T5.id
	--fetch first 30 rows only
	loop
		insert into
			taxi.edges
		values (
			v_id,
			v_edge.source,
			v_edge.target,
			v_edge.len,
			v_edge.rlen,
			v_edge.x1,
			v_edge.y1,
			v_edge.x2,
			v_edge.y2,
			v_edge.the_geom,
			v_edge.maxspeed,
			--speed defaults to maxspeed
			v_edge.maxspeed,
			--cost_len defaults to len
			v_edge.len,
			v_edge.len/v_edge.maxspeed*3.6,
			v_edge.rlen,
			v_edge.rlen/v_edge.maxspeed*3.6,
			v_edge.len,
			null,
			0
		);
		v_id = v_id+1;
	end loop
	;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION taxi.generate_edges()
  OWNER TO jgc;
