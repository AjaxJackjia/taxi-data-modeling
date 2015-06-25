-- Function: taxi.is_adjacent(bigint, bigint)

-- DROP FUNCTION taxi.is_adjacent(bigint, bigint);

CREATE OR REPLACE FUNCTION taxi.is_adjacent(
    v1 bigint,
    v2 bigint)
  RETURNS boolean AS
$BODY$
begin
	if((
		select
			count(*)
		from
			taxi.edges
		where
			source = v1 and
			target = v2
	)>0) then
		return true;
	elseif((
		select
			count(*)
		from
			taxi.edges
		where
			source = v2 and
			target = v1 and
			rlen = len
	)>0) then
		return true;
	else
		return false;
	end if
	;

end;
$BODY$
  LANGUAGE plpgsql IMMUTABLE STRICT
  COST 100;
ALTER FUNCTION taxi.is_adjacent(bigint, bigint)
  OWNER TO jgc;
