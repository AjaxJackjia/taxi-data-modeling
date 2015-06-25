# Preparation

## 安装环境
linux：ubuntu 14.10

## PostgreSQL PostGIS pgRouting安装

### PostgreSQL安装

主要参考了[getting_started_with_postgresql](http://www.ruanyifeng.com/blog/2013/12/getting_started_with_postgresql.html)

* 下载安装PostgreSQL, 以及PostGis和pgRouting插件
`sudo apt-get install postgresql-9.4 postgresql-9.4-postgis-2.1 postgresql-9.4-pgrouting`

    备注:这里使用的是PostgreSQL 9.4, PostGis 2.1.3, pgRouting 2.0

* 因为在postgresql安装到linux的时候，会默认生成一个名为postgres的数据库和一个名为postgres的数据库用户名，然后还会在系统中生成一个名为postgres的linux系统用户。
    
* 新建用户与数据库；

    `CREATE USER jgc WITH ENCRYPTED PASSWORD 'jgc' SUPERUSER;//创建用户`
    
    `CREATE DATABASE sf_taxi_analysis OWNER jgc;//创建数据库`
    
    `GRANT ALL PRIVILEGES ON DATABASE sf_taxi_analysis to jgc; //赋予权限`

* 登陆数据库， `psql -U dbuser -d exampledb -h 127.0.0.1 -p 5432`

参数意义： -U指定用户，-d指定数据库，-h指定服务器，-p指定端口。

* 控制台命令：

    `\password user`：修改用户user的密码。
    
    `\q`：退出控制台。
    
    `\h`：查看SQL命令的解释，比如`\h select`。
    
    `\?`：查看psql命令列表。
    
    `\l`：列出所有数据库。
    
    `\c [database_name]`：连接其他数据库。
    
    `\d`：列出当前数据库的所有表格。
    
    `\d [table_name]`：列出某一张表格的结构。
    
    `\du`：列出所有用户。
    
    `\dx`：列出安装的extension。
    
    `\e`：打开文本编辑器。
    
    `\conninfo`：列出当前数据库和连接的信息。

* 基本数据库操作请参考[postgresql官方文档](http://www.postgresql.org/docs/9.4/interactive/index.html).

### PostGis和pgRouting扩展安装

[PostGis官方安装文档](http://postgis.net/docs/postgis_installation.html);

[pgRouting官方安装文档](http://docs.pgrouting.org/2.0/en/doc/index.html);

因为需要用到相关的gis包，所以需要在目标数据库上建立相关的扩展。

切换到postgres用户，然后建立extension：

`psql -d sf_taxi_analysis -c "CREATE EXTENSION postgis;" `

`psql -d sf_taxi_analysis -c "CREATE EXTENSION hstore;"`

`psql -d sf_taxi_analysis -c "CREATE EXTENSION pgrouting;"`


### pgadmin3安装

因为控制台没有GUI容易操作，所以我们需要安装pgadmin3可视化工具。

pgadmin3只有v1.20.0支持postgresql 9.4 ，所以安装时注意pgadmin的版本号。

由于ubuntu下的pgadmin3只有v1.18.0,所以需要手动编译.

这个编译过程比较繁琐:

1. 首先去[pgadmin官网](http://www.pgadmin.org/index.php)下载v1.20.0版本的源码.

2. 解压软件包.

    `tar -xzvf pgadmin3-1.20.0.tar.gz`

3. 然后按照pgadmin3-1.20.0目录下的INSTALL来进行配置安装,并且注意版本号.

4. 在安装wxGTK时,需要注意有两部分需要进行make和make install.

4. 遇到的问题:

	在编译完pgadmin3之后, 会生成/usr/local/pgadmin3目录,其中的bin为pgadmin3的启动程序. 而且,在/usr/local/lib目录下会生成相关的lib文件, 但在执行pgadmin3时,遇到了错误: 
	./pgadmin3: error while loading shared libraries: libwx_gtk2u_stc-2.8.so.0: cannot open shared object file: No such file or directory.

    在网上搜索得到答案,软件在运行时没有找到自己需要的动态运行库,也就是说虽然在/usr/local/lib中生成来相关lib, 但是系统却没办法找到该lib. 解决方法如下:

    运行时使用非标准位置/usr/lib和/lib下的库的方式有三种：

    * 设置$LD_LIBRARY_PATH=库所在目录（多个目录用:分隔），系统加载工具ld.so/ld-linux.so将顺序搜索变量指定的目录。例如export $LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH;
    
    * 以root身份把库路径加入/etc/ld.so.conf或在/etc/ld.so.conf.d中创建特定的.conf文件，然后运行 ldconfig更新/etc/ld.so.cache。例如：在/etc/ld.so.conf.d下创建文件pgadmin3.conf写入/usr /local/lib;
    
    * 另一种办法就是把需要的库copy到/usr/lib或/lib，但这不是建议的方法，特别是尽量避免copy发到/lib。但这种方法可以在编译时免去用-L选项。

    PS: 共享库搜索顺序一般是$LDLIBRARY_PATH，/etc/ld.so.cache, /usr/lib, /lib


# 基本数据类型
[基本数据类型](/wiki/02_data_types.md)