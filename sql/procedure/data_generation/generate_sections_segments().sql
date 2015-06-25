-- Function: taxi.generate_sections_segments()

-- DROP FUNCTION taxi.generate_sections_segments();

CREATE OR REPLACE FUNCTION taxi.generate_sections_segments()
  RETURNS void AS
$BODY$
declare
	v_way_nodes refcursor;
	v_across_ways refcursor;
	v_way_record record;
	v_node ways.id%type;
	v_node_pre ways.id%type;
	v_section_id bigint := 0;
	v_segment_id bigint := 0;
	v_section_pre bigint := 0;
begin
	--open v_way_nodes for
	truncate table taxi.segment_section cascade;
	truncate table taxi.segments cascade;
	truncate table taxi.section_way cascade;
	truncate table taxi.sections cascade;

	for v_way_record in
	select 
		id, nodes 
	from 
		ways
	where
		tags -> 'highway' in (
			select type 
			from 
				taxi.highway_types
			where
				is_used = 1
		)
	loop
		v_node_pre := v_way_record.nodes[1];
		v_section_pre := v_way_record.nodes[1];
		foreach v_node in array v_way_record.nodes[2 : array_length(v_way_record.nodes, 1)-1]
		loop
			insert into taxi.segments values(v_segment_id, v_node_pre, v_node);
			insert into taxi.segment_section values(v_segment_id, v_section_id);
			v_segment_id := v_segment_id + 1;
			v_node_pre := v_node;
			
			if(taxi.is_junction_of_highway(v_node))	then	
				insert into taxi.sections values(v_section_id, v_section_pre, v_node);
				insert into taxi.section_way values(v_section_id, v_way_record.id);
				v_section_pre = v_node;
				v_section_id := v_section_id + 1;				
			end if;
		end loop;
		if (v_node_pre <> v_way_record.nodes[array_length(v_way_record.nodes, 1)]) then 
			v_node := v_way_record.nodes[array_length(v_way_record.nodes, 1)];
			insert into taxi.segments values(v_segment_id, v_node_pre, v_node);
			insert into taxi.segment_section values(v_segment_id, v_section_id);
			v_segment_id := v_segment_id + 1;
			insert into taxi.sections values(v_section_id, v_section_pre, v_node);
			insert into taxi.section_way values(v_section_id, v_way_record.id);
			v_section_id := v_section_id + 1;
		end if;
	end loop;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION taxi.generate_sections_segments()
  OWNER TO jgc;
