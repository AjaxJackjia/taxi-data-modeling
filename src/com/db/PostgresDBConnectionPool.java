package com.db;

import org.postgresql.ds.PGPoolingDataSource;

public class PostgresDBConnectionPool extends AbstractDBConnectionPool {
	
	public void initDBConnectionPool() {
		ds = new PGPoolingDataSource();
		((PGPoolingDataSource) ds).setServerName(serverName);
		((PGPoolingDataSource) ds).setPortNumber(port);
		((PGPoolingDataSource) ds).setDatabaseName(schema);
		((PGPoolingDataSource) ds).setUser(user);
		((PGPoolingDataSource) ds).setPassword(password);
	}
}
