-- Function: taxi.get_node(bigint)

-- DROP FUNCTION taxi.get_node(bigint);

CREATE OR REPLACE FUNCTION taxi.get_node(v_node_id bigint)
  RETURNS SETOF refcursor AS
$BODY$
declare 
	r_node_pos refcursor;
	r_node_tags refcursor;
begin
	open r_node_pos for
	select
		st_x(geom) longitude,
		st_y(geom) latitude
	from
		nodes
	where
		id = v_node_id
	;
	return next r_node_pos;
	
	open r_node_tags for
	select 
		(each(tags)).key,
		(each(tags)).value		
	from
		nodes
	where
		id = v_node_id
	;
	return next r_node_tags;
	
	
end;$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100
  ROWS 1000;
ALTER FUNCTION taxi.get_node(bigint)
  OWNER TO jgc;
