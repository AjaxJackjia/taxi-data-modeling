-- Function: taxi.get_geometry_of_section(bigint)

-- DROP FUNCTION taxi.get_geometry_of_section(bigint);

CREATE OR REPLACE FUNCTION taxi.get_geometry_of_section(v_id bigint)
  RETURNS geometry AS
$BODY$
declare v_way_id bigint;
declare v_section record;
declare v_return geometry;
declare v_start int;
declare v_end int;
begin
	select  way_id from taxi.section_way where section_id = v_id into v_way_id;
	--extract section's endpoint
	select *
	from
		taxi.sections
	where
		id = v_id
	into
		v_section
	;
	--locate start index
	select
		sequence_id
	from
		way_nodes T1
	where
		T1.way_id = v_way_id and
		T1.node_id = v_section.from_node
	order by
		sequence_id
	limit 1
	into
		v_start
	;
	--locate end index
	select
		sequence_id
	from
		way_nodes T1
	where
		T1.way_id = v_way_id and
		T1.node_id = v_section.to_node
	order by
		sequence_id desc
	limit 1
	into
		v_end
	;
	raise notice 's e % %', v_start, v_end;

	select
		st_makeline(geom)
	from (
		select
			T2.geom
		from
			way_nodes T1,
			nodes T2
		where
			T1.node_id = T2.id and
			T1.way_id = v_way_id and
			sequence_id >= v_start and
			sequence_id <= v_end
		order by
			sequence_id
	) T
	into v_return
	;
	return v_return;
end;
$BODY$
  LANGUAGE plpgsql IMMUTABLE STRICT
  COST 100;
ALTER FUNCTION taxi.get_geometry_of_section(bigint)
  OWNER TO jgc;
