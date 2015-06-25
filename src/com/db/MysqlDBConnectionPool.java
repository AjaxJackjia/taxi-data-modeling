package com.db;

import org.postgresql.ds.PGPoolingDataSource;

import com.mysql.jdbc.jdbc2.optional.MysqlDataSource;

public class MysqlDBConnectionPool extends AbstractDBConnectionPool {
	
	public void initDBConnectionPool() {
		ds = new MysqlDataSource();
		((MysqlDataSource) ds).setServerName(serverName);
		((MysqlDataSource) ds).setPortNumber(port);
		((MysqlDataSource) ds).setDatabaseName(schema);
		((MysqlDataSource) ds).setUser(user);
		((MysqlDataSource) ds).setPassword(password);
	}
}
