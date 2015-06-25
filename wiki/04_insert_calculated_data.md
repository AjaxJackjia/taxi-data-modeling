#计算数据导入

## GPS数据生成

gps_filter表中数据全部是载客数据.


## Trip数据生成

[trip id 生成](/sql/procedure/postgres/generate_trips_id().sql);

[trip od 生成1](/sql/procedure/postgres/generate_trips_od_grid(double precision).sql);

[trip od 生成2](/sql/procedure/postgres/generate_trips_od(character varying, timestamp without time zone, timestamp without time zone).sql);

[trip od 生成3](/sql/procedure/postgres/generate_trips_od(timestamp without time zone, timestamp without time zone).sql);
