# Data Types

这里主要使用到了如下几种类型的数据:

1. OSM地图数据, 要分析的城市的OSM数据;

2. 道路类型数据, 要分析的OSM道路类型;

3. 城市边界与城市网格数据, 包括了城市边界以及城市网格分解的基本数据;

4. GPS数据, 原始的GPS数据以及过滤处理之后的GPS数据;

5. 城市道路数据, 根据OSM地图数据生成的路网segment与section基本信息;

6. Trip数据, 原始的GPS的数据生成的载客trajectory数据;

7. Routing数据, 导航所需要的基本数据.


# Postgres Database Table Definition

## OSM地图数据table

表格使用osmosis工具中的script文件夹中pgsimple_schema_0.6.sql生成, 共8张table.

## 道路类型数据table

共1张table.

--------------------------------

**TableName**: highway_types.

**作用**: 存储所有道路类型,以及分析中使用到的道路类型.

| Column Name   | Type        	         | Comment               |
| :-----------: |:----------------------:| :-------------------: |
| id      		| integer	             | highway类型标识         |
| type      	| character varying(50)	 | highway名称            |
| is_used      	| integer		         | 该highway是否在分析中使用 |

## 城市边界与城市网格数据table

共2张table.

--------------------------------

**TableName**: bounds.

**作用**: 存储目标城市的经纬度范围.

| Column Name   | Type        	         | Comment               |
| :-----------: |:----------------------:| :-------------------: |
| id      		| integer	             | 城市标识	             |
| alias      	| character varying		 | 城市别名	             |
| x_min      	| double precision       | 最小经度		         |
| x_max      	| double precision       | 最大经度		         |
| y_min      	| double precision       | 最小纬度		         |
| y_max      	| double precision       | 最大纬度		         |
| grid_size    	| double precision       | 网格边长(in degree) 	 |

--------------------------------
**TableName**: grids.

**作用**: 存储目标城市的网格.

| Column Name   | Type        	         | Comment               |
| :-----------: |:----------------------:| :-------------------: |
| id      		| bigint	             | grid标识    		     |
| x   		   	| double precision		 |        			     |
| y  	    	| double precision       | 						 |
| o_occur    	| integer     			 | 						 |
| d_occur    	| integer     			 | 						 |

## GPS数据table

共2张table.

--------------------------------

**TableName**: gps_raw.

**作用**: 存储原始GPS数据.

| Column Name   | Type        	              | Comment               |
| :-----------: |:---------------------------:| :-------------------: |
| id      		| character varying(16)       | 司机标识	              |
| point      	| geometry(Point,4326)	      | GPS坐标点	              |
| state      	| boolean		              | 是否载客		          |
| timestamp   	| timestamp without time zone | GPS时间		          |

--------------------------------

**TableName**: gps_filter.

**作用**: 存储根据gps_raw处理之后的数据,而且全部数据都是载客的.

| Column Name   | Type        	              | Comment                 |
| :-----------: |:---------------------------:| :---------------------: |
| id      		| character varying(16)       | 司机标识	                |
| point      	| geometry(Point,4326)	      | GPS坐标点	                |
| state      	| boolean		              | 是否载客		            |
| timestamp   	| timestamp without time zone | GPS时间		            |
| trip_id  		| bigint			          | 司机载客trajectory标识    |
| seq      		| integer				      | GPS点在trajectory中的次序 |
| segment_id    | bigint		              | GPS assigned segment    |
| section_id   	| bigint					  | GPS assigned section    |

## 城市道路数据table

共4张table.

--------------------------------

**TableName**: section_way.

**作用**: 存储section与way对应关系.

| Column Name   | Type        	              | Comment               |
| :-----------: |:---------------------------:| :-------------------: |
| section_id    | bigint			          | section标识            |
| way_id      	| bigint			          | 引用ways表中的id   	  |

--------------------------------

**TableName**: sections.

**作用**: 存储section标识, 起始点与终点node id.

| Column Name   | Type        	              | Comment               |
| :-----------: |:---------------------------:| :-------------------: |
| id		    | bigint			          | section标识            |
| from_node		| bigint			          | 引用nodes表中的id		  |
| to_node		| bigint			          | 引用nodes表中的id   	  |

--------------------------------

**TableName**: segment_section.

**作用**: 存储segment与section对应关系.

| Column Name   | Type        	              | Comment               |
| :-----------: |:---------------------------:| :-------------------: |
| segment_id	| bigint			          | segment标识            |
| section_id	| bigint			          | section标识			  |

--------------------------------

**TableName**: segments.

**作用**: 存储segment标识,起始点与终点node id.

| Column Name   | Type        	              | Comment               |
| :-----------: |:---------------------------:| :-------------------: |
| id		    | bigint			          | segment标识            |
| from_node		| bigint			          | 引用nodes表中的id		  |
| to_node		| bigint			          | 引用nodes表中的id   	  |


## Trip数据table

共2张table.

--------------------------------

**TableName**: trips_od.

**作用**: 存储载客trajectory基本信息.

| Column Name   | Type        	              | Comment               |
| :-----------: |:---------------------------:| :-------------------: |
| id		    | bigint			          | 载客trajecotory标识	  |
| uid	      	| character varying(16)       | 司机标识   			  |
| o_point	    | geometry(Point,4326)        | 起点GPS坐标点   	  	  |
| o_time	    | timestamp without time zone | 起点时间   	 		  |
| d_point	    | geometry(Point,4326)        | 终点GPS坐标点   	  	  |
| d_time     	| timestamp without time zone | 终点时间			  	  |

--------------------------------

**TableName**: trips_od_grid.

**作用**: 存储trajecotory对应grid的信息.

| Column Name   | Type        	              | Comment               |
| :-----------: |:---------------------------:| :-------------------: |
| id		    | bigint			          | trajecotory标识        |
| o_grid      	| bigint			          | 起点所在grid标识   	  |
| d_grid      	| bigint			          | 终点所在grid标识   	  |

## Routing数据table

共2张table.

--------------------------------

**TableName**: edges.

**作用**: 存储根据OSM基本数据生成的有向图信息.

| Column Name   | Type        	              | Comment               |
| :-----------: |:---------------------------:| :-------------------: |
| id		    | bigint			          | 有向图边id			  |
| source	    | bigint      				  | 起点标识   			  |
| target	    | bigint     				  | 终点标识   	  	  	  |
| len	    	| double precision 			  | 边长   	 		      |
| rlen	    	| double precision        	  | 反向边长(若很大,则说明该向不通) |
| x1     		| double precision 			  | 起点经度			  	  |
| y1     		| double precision 			  | 起点纬度			  	  |
| x2     		| double precision 			  | 终点经度			  	  |
| y2     		| double precision 			  | 终点纬度			  	  |
| the_geom     	| geometry(LineString,4326)   | 该边LineString信息  	  |
| maxspeed     	| double precision 			  | 最大行驶速度		  	  |
| speed_kph     | double precision 			  | 行驶速度			  	  |
| cost_len     	| double precision 			  | 损耗距离		  	 	  |
| cost_time     | double precision 			  | 损耗时间			  	  |
| rcost_len     | double precision 			  | 反向损耗距离		  	  |
| rcost_time    | double precision 			  | 反向损耗时间		  	  |
| to_cost     	| double precision 			  | 				  	  |
| rule     		| text 						  | 				  	  |
| isolated     	| integer 					  | 				  	  |

--------------------------------

**TableName**: edges_vertices_pgr.

**作用**: pgrouting插件生成的有向图edge与vertex之间的关系表.

## 创建相应table

使用[create_tables_pg.sql](/sql/init/create_tables_pg.sql)创建数据类型table.


# 基本数据导入
[基本数据导入](/wiki/03_insert_base_data.md)
