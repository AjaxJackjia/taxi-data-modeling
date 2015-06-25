#基本数据导入

## 准备工作

因为OSM地图数据是导入默认public的schema，而之后的数据导入新建的taxi schema。

[创建taxi schema](/sql/init/create_schema.sql);


## OSM地图数据导入：

OSM地图数据导入使用Osmosis第三方工具, 主要参考: [http://wiki.openstreetmap.org/wiki/Osmosis](http://wiki.openstreetmap.org/wiki/Osmosis)

**简介**：Osmosis是用来处理OSM数据的一个java命令行应用。该工具中包含了多个插件模块，可以联合完成多个所需的操作。例如，它有可以读写数据库或者文件的组件、导出或者改变数据源的组件、排序数据的组件等等。

* 第一步, 获取Osmosis最新的稳定版本：

    [http://bretth.dev.openstreetmap.org/osmosis-build/osmosis-latest.zip](http://bretth.dev.openstreetmap.org/osmosis-build/osmosis-latest.zip)

    [http://bretth.dev.openstreetmap.org/osmosis-build/osmosis-latest.tgz](http://bretth.dev.openstreetmap.org/osmosis-build/osmosis-latest.tgz)

* 第二步, 在linux上安装Osmosis:

    Osmosis非常简单直接。它的安装需要系统预装java环境。

    ```
    tar xvfz osmosis-latest.tgz
    cd osmosis-*
    chmod a+x bin/osmosis
    bin/osmosis
    ```

    执行完毕之后，会有相应的使用信息。

* 第三步, 创建相关的schema sql语句:

    `psql -d sf_taxi_analysis -f pgsnapshot_schema_0.6.sql;`

    这个sql在osmosis的script目录下,这里应该将路径名补全. 执行完毕后会有8个table自动在public schema下建立。

* 第四步, 切换到非postgres用户jgc下,使用如下命令导入数据：

    `./osmosis --read-xml file=/home/jackjia/program/taxi-analysis-relative/data/MapData/sf_ssf.osm --write-pgsql host="127.0.0.1" database="test" user="jgc" password="jgc";`

    出现INFO: Total execution time: 128747 milliseconds.说明成功导入数据.


## 道路类型数据导入

在创建table的同时导入. 见[创建数据类型table](/sql/init/create_tables_pg.sql).


## 城市边界与城市网格数据导入

* 边界数据在创建table的同时导入. 见[创建数据类型table](/sql/init/create_tables_pg.sql).

* 城市网格数据[导入](/sql/procedure/data_generation/generate_grids(double precision, double precision, double precision, double precision, double precision).sql), 其中, procedure最后一个参数代表 grid 的经纬度 gap, 不是用距离km表示的.


## GPS数据导入

* 使用java代码 com.util.GPSImporter将GPS原始数据导入到gps_raw表中. 

* **gps_filter数据为计算后数据**, 其导入在[insert calculated data](/wiki/04_insert_calculated_data.md).


## 城市道路数据导入

该数据导入依赖OSM地图数据导入.

城市道路数据[导入](/sql/procedure/data_generation/generate_sections_segments().sql), 之后section_way, sections, segment_section, segments四张表被导入数据.


## Trip数据导入

**Trip数据为计算后的数据**, 具体过程在[insert calculated data](/wiki/04_insert_calculated_data.md).


## Routing数据导入

* edges数据生成使用[generate_edges().sql](/sql/procedure/data_generation/generate_edges().sql),并且edges数据生成依赖 taxi.sections, taxi.section_way, ways, nodes中的数据. [官方文档](http://docs.pgrouting.org/2.0/en/doc/src/tutorial/topology.html#topology).

* [edges_vertices_pgr数据生成](http://docs.pgrouting.org/2.0/en/src/common/doc/functions/create_topology.html#pgr-create-topology).

**PS**: edges_vertices_pgr表生成的时候会有副作用, 会将edges中的source和target的值重新计算.

#计算数据导入

[计算数据导入](/wiki/04_insert_calculated_data.md)
