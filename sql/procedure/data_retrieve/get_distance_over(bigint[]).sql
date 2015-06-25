-- Function: taxi.get_distance_over(bigint[])

-- DROP FUNCTION taxi.get_distance_over(bigint[]);

CREATE OR REPLACE FUNCTION taxi.get_distance_over(v_vertex bigint[])
  RETURNS double precision AS
$BODY$
declare i int;
declare j int;
declare v_pgr_cost_result record;
declare v_distance double precision := 0;
begin
	for j in 2..array_length(v_vertex, 1) loop
		i = j-1;
		for v_pgr_cost_result in
		select seq, id1, id2, cost 
		from
			pgr_dijkstra(
				'select id, source::integer, target::integer, len as cost, rlen reverse_cost from taxi.edges',
				v_vertex[i]::int,
				v_vertex[j]::int,
				true,
				true
			)
		loop
			if(v_pgr_cost_result.id2 <> -1) then
				v_distance = v_distance + v_pgr_cost_result.cost;
			end if;
		end loop;
	end loop;
	return v_distance;
end;
$BODY$
  LANGUAGE plpgsql IMMUTABLE STRICT
  COST 100;
ALTER FUNCTION taxi.get_distance_over(bigint[])
  OWNER TO jgc;
