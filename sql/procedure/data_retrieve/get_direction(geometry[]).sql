-- Function: taxi.get_direction(geometry[])

-- DROP FUNCTION taxi.get_direction(geometry[]);

CREATE OR REPLACE FUNCTION taxi.get_direction(v_points geometry[])
  RETURNS record AS
$BODY$
declare j int;
declare v_x double precision := 0;
declare v_y double precision := 0;
declare v_cur_x double precision;
declare v_cur_y double precision;
declare v_temp double precision;
declare v_return record;
begin
	for i in 1..array_length(v_points, 1)-1 loop
		j = i+1;
		v_cur_x = st_x(v_points[j]) - st_x(v_points[i]);
		v_cur_y = st_y(v_points[j]) - st_y(v_points[i]);
		if(v_cur_x=0 and v_cur_y=0) then
			continue;
		end if;
		v_temp = sqrt(v_cur_x*v_cur_x + v_cur_y*v_cur_y);
		v_cur_x = v_cur_x / v_temp;
		v_cur_y = v_cur_y / v_temp;
		v_x = v_x + v_cur_x;
		v_y = v_y + v_cur_y;
		v_x = v_x / (|/(v_x*v_x + v_y*v_y));
		v_y = v_y / (|/(v_x*v_x + v_y*v_y));
	end loop;
	select
		v_x, v_y
	into
		v_return;

	return v_return;
end;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
ALTER FUNCTION taxi.get_direction(geometry[])
  OWNER TO jgc;
