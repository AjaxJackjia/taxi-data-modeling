#SQL详解

## 初始化数据库, 建schema, 建表

[create_database.sql](/sql/init/create_database.sql)

[create_schema.sql](/sql/init/create_schema.sql)

[create_tables_pg.sql](/sql/init/create_tables_pg.sql)

## 数据生成

1. [generate_grids().sql](/sql/procedure/data_generation/generate_grids().sql)

使用taxi.bounds中的基本数据生成taxi.grides数据.

2. [generate_sections_segments().sql](/sql/procedure/data_generation/generate_sections_segments().sql)

根据public schema中8张osm基本表, 生成section_way, sections, segment_section, segments四张表数据.

3. [generate_edges().sql](/sql/procedure/data_generation/generate_edges().sql)

导航的edges数据生成依赖 taxi.sections, taxi.section_way, ways, nodes中的数据.

使用到了[get_len_of_section(bigint).sql](/sql/procedure/data_retrieve/get_len_of_section(bigint).sql).

4. [generate_trips_id().sql](/sql/procedure/data_generation/generate_trips_id().sql)

从taxi.gps_raw表中提取trip id信息.

5. [generate_trips_od().sql](/sql/procedure/data_generation/generate_trips_od().sql)

从taxi.gps_filter表中提取trip_od的基本信息.

6. [generate_trips_od_grid().sql](/sql/init/generate_trips_od_grid().sql)

通过taxi.trips_od表产生tri_od_grid数据. 

使用到了[get_grid_id(v_x double precision, v_y double precision)](/sql/procedure/data_retrieve/get_grid_id(v_x double precision, v_y double precision).sql).

## 信息检索

### FUNCTION taxi.get_grid_id(v_x double precision, v_y double precision)

从grids表中获取点(v_x, v_y)所在的grid id.


### FUNCTION taxi.generate_trips_id

按uid和timestamp排序之后,顺序扫表产生每个trip id,产生带有trip id以及seq的taxi_filter表.


### FUNCTION get_od(character varying, timestamp without time zone, timestamp without time zone).sql

慢!!!

作用:从`taxi.gps_raw`表中找出是某用户在某时间段内的所有od记录.

详解:使用游标,从`taxi.gps_raw`表中获取出某用户在某时间段内的所有记录,然后分三种情况讨论:

默认之前的载客状态为false.

- 如果`v_pre_state`为false, 并且当前记录状态为true, 则该记录点为od起点;
- 如果`v_pre_state`为true, 并且当前记录状态为true, 则该记录点为od中的点;
- 如果`v_pre_state`为true, 并且当前记录状态为false, 则该记录点之前的一个点为od终点, 并且此时将od记录返回.




