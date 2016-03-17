-- Create a table for highway types.
DROP TABLE IF EXISTS taxi.highway_types;
CREATE TABLE taxi.highway_types(
	id	INT PRIMARY KEY,
	type 	VARCHAR(50),
	is_used	SMALLINT
);

-- Insert data into table highway types.
INSERT INTO 
	taxi.highway_types
SELECT  
	row_number() OVER () , 
	highway_type, 
	CASE
		WHEN highway_type='living_street'	THEN 1
		WHEN highway_type='motorway' 	  	THEN 1
		WHEN highway_type='motorway_link'	THEN 1
		WHEN highway_type='service'		THEN 1
		WHEN highway_type='primary'		THEN 1
		WHEN highway_type='primary_link'	THEN 1
		WHEN highway_type='residential'		THEN 1
		WHEN highway_type='secondary'		THEN 1
		WHEN highway_type='secondary_link'	THEN 1
		WHEN highway_type='tertiary'		THEN 1
		WHEN highway_type='trunk'		THEN 1
		WHEN highway_type='trunk_link'		THEN 1
		WHEN highway_type='unclassified'	THEN 1
		ELSE 0
	END
FROM (
	SELECT  DISTINCT tags->'highway' AS highway_type FROM ways WHERE tags?'highway'
) T
;

-- Create a table for city bounds.
DROP TABLE IF EXISTS taxi.bounds;
CREATE TABLE taxi.bounds(
	id INTEGER NOT NULL,
	alias CHARACTER VARYING,
	x_min DOUBLE PRECISION,
	y_min DOUBLE PRECISION,
	x_max DOUBLE PRECISION,
	y_max DOUBLE PRECISION,
	grid_size DOUBLE PRECISION, -- latitude step gap
	CONSTRAINT bounds_pkey PRIMARY KEY (id)
);

-- Insert data into table bounds.
--INSERT INTO 
--	taxi.bounds
--VALUES(1, 'SF', -122.528, 37.7058, -122.346, 37.8174, 1000.0);

INSERT INTO 
	taxi.bounds
VALUES(1, 'SZ', 113.767, 22.445, 114.285, 22.679, 0.00585);
-- suppose that split the lat range into 40 pieces, then every piece is 0.00585
-- then the grid is 0.00585 * 0.00585, almost 0.64935km * 0.64935km(approximate)

-- Create a table for city grids.
DROP TABLE IF EXISTS taxi.grids;
CREATE TABLE taxi.grids(
  id BIGINT NOT NULL,
  x DOUBLE PRECISION,
  y DOUBLE PRECISION,
  o_occur INTEGER,
  d_occur INTEGER,
  CONSTRAINT grids_pkey PRIMARY KEY (id)
);

-- Create tables for gps raw data and filtered gps data.
DROP TABLE IF EXISTS taxi.gps_raw;
CREATE TABLE taxi.gps_raw(
	id VARCHAR(16),
	point GEOMETRY(POINT,4326),
	state BOOLEAN,
	timestamp TIMESTAMP,
	v DOUBLE PRECISION,
	angle INTEGER
);

DROP TABLE IF EXISTS taxi.gps_filter;
CREATE TABLE taxi.gps_filter(
	id VARCHAR(16),
	point GEOMETRY(POINT,4326),
	state BOOLEAN,
	timestamp TIMESTAMP,
	v DOUBLE PRECISION,
	angle INTEGER,
	trip_id BIGINT,
	seq INTEGER,
	segment_id BIGINT,
	section_id BIGINT
);
-- create index over trip id to improve efficiency
CREATE INDEX ON taxi.gps_filter (trip_id);


-- Create tables for city based road data.
DROP TABLE IF EXISTS taxi.sections;
CREATE TABLE taxi.sections(
	id BIGINT PRIMARY KEY,
	from_node BIGINT,
	to_node BIGINT
);

DROP TABLE IF EXISTS taxi.section_way;
CREATE TABLE taxi.section_way(
	section_id BIGINT REFERENCES taxi.sections(id),
	way_id BIGINT
);

DROP TABLE IF EXISTS taxi.segments;
CREATE TABLE taxi.segments(
	id BIGINT PRIMARY KEY,
	from_node BIGINT,
	to_node BIGINT
);

DROP TABLE IF EXISTS taxi.segment_section;
CREATE TABLE taxi.segment_section(
	segment_id BIGINT REFERENCES taxi.segments(id),
	section_id BIGINT
);


-- Create tables for basic trip info.
DROP TABLE IF EXISTS taxi.trips_od;
CREATE TABLE taxi.trips_od(
	id BIGINT PRIMARY KEY,
	uid CHARACTER VARYING(16),
	o_point GEOMETRY(POINT,4326),
	o_time TIMESTAMP,
	d_point GEOMETRY(POINT,4326),
	d_time TIMESTAMP,
	distance DOUBLE PRECISION,
	v DOUBLE PRECISION
);
-- create index over id to improve efficiency
CREATE INDEX ON taxi.trips_od (id);

DROP TABLE IF EXISTS taxi.trips_od_grid;
CREATE TABLE taxi.trips_od_grid(
	id BIGINT primary key,
	o_grid BIGINT,
	d_grid BIGINT
);
-- create index over id to improve efficiency
CREATE INDEX ON taxi.trips_od_grid (id);

-- Create tables for pgrouting.
DROP TABLE IF EXISTS taxi.edges;
CREATE TABLE taxi.edges(
	id BIGINT NOT NULL,
	source BIGINT,
	target BIGINT,
	len DOUBLE PRECISION,
	rlen DOUBLE PRECISION,
	x1 DOUBLE PRECISION,
	y1 DOUBLE PRECISION,
	x2 DOUBLE PRECISION,
	y2 DOUBLE PRECISION,
	the_geom GEOMETRY(LINESTRING,4326),
	maxspeed DOUBLE PRECISION,
	speed_kph DOUBLE PRECISION,
	cost_len DOUBLE PRECISION,
	cost_time DOUBLE PRECISION,
	rcost_len DOUBLE PRECISION,
	rcost_time DOUBLE PRECISION,
	to_cost DOUBLE PRECISION,
	rule TEXT,
	isolated INTEGER,
	CONSTRAINT edges_pkey PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
);

