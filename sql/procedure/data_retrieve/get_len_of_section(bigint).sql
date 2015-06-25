-- Function: taxi.get_len_of_section(bigint)

-- DROP FUNCTION taxi.get_len_of_section(bigint);

CREATE OR REPLACE FUNCTION taxi.get_len_of_section(v_id bigint)
  RETURNS real AS
$BODY$
declare v_len real := 0;
declare v_way_id bigint;
declare v_section record;
declare v_pre_node geometry;
declare v_next_node geometry;
declare v_node_id bigint;
declare v_cursor_way_nodes no scroll CURSOR 
	(in_way_id bigint, in_from_node bigint) for
	select
		node_id
	from
		way_nodes
	where
		way_id = in_way_id
	order by
		sequence_id
;
declare v_cursor_nodes no scroll CURSOR (in_id bigint) for
	select
		geom
	from
		nodes
	where
		id = in_id
;
begin
	select  
		way_id 
	from 
		taxi.section_way 
	where 
		section_id = v_id 
	into 
		v_way_id;
	--extract section's endpoint
	select 
		from_node, to_node
	from
		taxi.sections
	where
		id = v_id
	into
		v_section
	;
	
	open v_cursor_nodes(v_section.from_node);
	fetch v_cursor_nodes into v_pre_node;
	close v_cursor_nodes;
	open v_cursor_way_nodes(v_way_id, v_section.from_node);
	fetch v_cursor_way_nodes into v_node_id;
	while(v_node_id <> v_section.from_node) loop
		fetch v_cursor_way_nodes into v_node_id;
	end loop;
	
	loop
		fetch v_cursor_way_nodes into v_node_id;
		open v_cursor_nodes(v_node_id);
		fetch v_cursor_nodes into v_next_node;
		close v_cursor_nodes;
	
		v_len = v_len + 
					st_distance_sphere(
						v_pre_node, v_next_node);
		v_pre_node = v_next_node;
		if(v_node_id = v_section.to_node) then
			close v_cursor_way_nodes;
			exit;
		end if;
	end loop;
	
	return v_len;
end;
$BODY$
  LANGUAGE plpgsql IMMUTABLE STRICT
  COST 100;
ALTER FUNCTION taxi.get_len_of_section(bigint)
  OWNER TO jgc;
