#计算数据导入

## GPS数据生成

该部分主要是生成gps_filter表.

因为gps_raw表中是原始GPS数据, 为了提高数据处理的效率, 将过滤原始GPS数据生成gps_filter表. gps_filter表中数据全部是载客数据, 并且相比于gps_raw表增加trip id, seq, assigned segment id与assigned section id.

* 第一步, 生成trip id. 调用sql为[taxi.generate_trips_id().sql](/sql/procedure/data_generation/generate_trips_id().sql);

该步骤生成gps_filter表中id, point, state, timestamp, trip_id, seq字段, 并且所有state都为true.

* 第二步, 生成assigned segment id与section id.

>assign算法 待优化


## Trip数据生成

该部分主要生成trips_od表, 以及trips_od_grid表.

* 第一步, 根据**GPS数据生成步骤中**生成的gps_filter, 可以在此表的基础上, 通过调用[generate_trips_od().sql](/sql/procedure/data_generation/generate_trips_od().sql), 产生每个表的起始点信息, 并且包括该trip的估计长度(根据trip的GPS点估算而来, 单位为m).

* 第二步, 根据上一步生成的trips_od表, 通过调用[generate_trips_od_grid(double precision).sql](/sql/procedure/data_generation/generate_trips_od_grid().sql)产生对应grid表格的od信息.

到此为止, 所有我们需要的数据已经生成完毕.

