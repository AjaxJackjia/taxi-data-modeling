--Procedures 
--1. Import the OSM data into database
--		1.1 osmosis
--2. Generate segments and sections
--		2.1 select taxi.generate_sections_segments()
--3. Generate network topology
--		3.1	select taxi.generate_edges()
--		3.2 select pgr_createTopology('taxi.edges', 0.00001, 'the_geom', 'id', 'source', 'target')
--4. Decompose cities

select st_asText(the_geom),* from taxi.edges where source =11667;
select st_asText(the_geom),* from taxi.edges_vertices_pgr where id = 10679;
select * from taxi.sections 
where from_node = 742220572
select st_asText(taxi.get_geometry_of_section(12501));
select taxi.get_trip_points(1)
select taxi.test();
select * from taxi.gps_raw where trip_id = 5 order by timestamp
select dis from taxi.trips_od limit 3
select count(*) from taxi.get_trips_with_od(-122.410719,37.808292, -122.409003,37.788170, 300, 100.0);
select 
	T1.id as section_id, T4.* 
from 
	taxi.sections T1, 
	nodes T2, 
	nodes T3,(
		select 
			st_asText(the_geom) linestring,
			T2.seq,  
			T1.id as edge_id,
			T1.x1, T1.y1, T1.x2, T1.y2
		from  
			taxi.edges T1,( 
			SELECT 
				seq, id1 AS node, id2 AS edge, cost
			FROM  
				pgr_dijkstra(' 
					SELECT id, 
					source::integer, 
					target::integer, 
					len AS cost, 
					rlen AS reverse_cost 
					FROM taxi.edges', 10666, 10689, true, true)
			)T2 
		where
			T2.edge = T1.id 
		order by 
			T2.seq 
	) T4
where 
	T1.from_node = T2.id and 
	T1.to_node = T3.id and 
	T4.x1 = st_x(T2.geom) and 
	T4.y1 = st_y(T2.geom) and 
	T4.x2 = st_x(T3.geom) and 
	T4.y2 = st_y(T3.geom)order by T4.seq 


select id1, id2 from pgr_dijkstra('select 
					id::int, source::int, target::int, len as cost, rlen as reverse_cost 
				from
					taxi.edges', 11667, 8485, true, true)
			
select * from ( values(1, 2, 3))  as a (a, b, c);



select st_asText(the_geom) from taxi.edges where (source=9193 and target = 6453 ) or (source= 6453 and target =9193 )
select st_distance_sphere(st_point(-122.222, 37.7058), st_point(-122.222 + 0.5 * 0.0003, 37.7058 + sqrt(3) / 2.0 * 0.0003))
select st_distance_sphere(st_point(-122.410655,37.808224), st_point(-122.408359,37.788251))
select * from taxi.trips_od where id = 463901;
select taxi.get_trips();
select taxi.generate_trips_od('2008-05-17 18:00:04'::timestamp, '2008-06-10 17:25:34');
	select count(*) from taxi.trips_od;
select taxi.generate_grids(-122.528, 37.7058, -122.346, 37.8174, 0.002);
	select count(*) from taxi.grids;
select taxi.generate_trips_od_grid(0.002);
	select count(*) from taxi.trips_od_grid;
	select 
		o_grid, d_grid, count(*)
	from
		taxi.trips_od_grid
	group by
		o_grid, d_grid
	order by 3 desc, o_grid
	limit 100
	;
	select d_grid, count(*) 
	from 
		taxi.trips_od_grid
	group by
		d_grid
	order by
		2 desc
	limit 100;
	select st_asText(taxi.get_grid(3346));

	select 
		T1.id, st_asText(the_geom)
	from
		(select taxi.get_trip_vertices(123701, false) as id )T1,
		taxi.edges_vertices_pgr T2
	where
		T1.id = T2.id
	;
	select st_asText(the_geom) from
	(
		select the_geom from taxi.edges_vertices_pgr 
		where id = taxi.get_nearest_vertex(st_setSRID(st_point(-122.42005, 37.77874), 4326), -0.249693826313793, 0.968324838626366)
		) as T
	;

	select st_asText(the_geom),* from taxi.edges_vertices_pgr where id = 9064   ;
	select st_asText(the_geom), * from taxi.edges where id = 13886 ;
	
	select taxi.get_trip_vertices(43961, false);

	
	
	select st_asText(the_geom) from
	(
		select the_geom from taxi.edges_vertices_pgr 
		where id = taxi.get_nearest_vertex(st_setSRID(st_point(-122.40823, 37.78354), 4326), 0.778772098547458,0.627306957178054)
		) as T
	;
	select taxi.get_nearest_vertex(st_point( -122.41227, 37.8085), -1, 0)
	
	select *, st_asText(point) from taxi.gps_raw where trip_id = 72166 order by timestamp

	--from Pier 39 to Union Square
	select taxi.get_trips_with_od(-122.410719,37.808292, -122.409003,37.788170, 300, 100.0);
	select id
	from
		taxi.trips_od
	where
		st_distance_sphere(st_point(-122.391214,37.728876), o_point) < 300 and
		st_distance_sphere(st_point(-122.410676,37.728400), d_point) < 300

select * from taxi.edges where st_distance_sphere(the_geom, st_point(-122.39724, 37.74977))<1000

select * from (
select row_number() over() id, x/1000000.0, y/1000000.0
from
	generate_series((-122.528*1000000)::int4, (-122.346*1000000)::int4, 4000) as x ,
	generate_series((37.7058*1000000)::int4, (37.8174*1000000)::int4, 4000) as y) as t
limit 100;
