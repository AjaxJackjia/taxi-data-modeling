-- Function: taxi.get_way_across_node(bigint)

-- DROP FUNCTION taxi.get_way_across_node(bigint);

CREATE OR REPLACE FUNCTION taxi.get_ways_across_node(v_node_id bigint)
  RETURNS bigint[] AS
$BODY$
begin



end;$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
ALTER FUNCTION taxi.get_way_across_node(bigint)
  OWNER TO jgc;
