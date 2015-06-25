-- Function: taxi.is_junction_of_highway(bigint)

-- DROP FUNCTION taxi.is_junction_of_highway(bigint);

CREATE OR REPLACE FUNCTION taxi.is_junction_of_highway(v_node_id bigint)
  RETURNS boolean AS
$BODY$
declare
	result boolean default false;
	count int;
begin
	select
		count(distinct way_id)
	from
		way_nodes
	where
		node_id = v_node_id and 
		exists (
			select * 
			from
				ways
			where
				id = way_id and 
				tags -> 'highway' in (
					select type 
					from 
						taxi.highway_types
					where
						is_used = 1
				)
		)
	into
		count
	;
	if count > 1 then 
		result := true;
	end if
	;
	return result;
end;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
ALTER FUNCTION taxi.is_junction_of_highway(bigint)
  OWNER TO jgc;
