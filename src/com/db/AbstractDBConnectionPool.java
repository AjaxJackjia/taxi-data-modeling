package com.db;

import java.sql.Connection;
import java.sql.SQLException;

import javax.sql.DataSource;

public abstract class AbstractDBConnectionPool {
	protected DataSource ds;
	protected String serverName;
	protected String schema;
	protected int port;
	protected String user;
	protected String password;

	public void configConnectionPool(String serverName, String schema,
			String port, String user, String password) {
		this.serverName = serverName;
		this.schema = schema;
		this.port = Integer.valueOf(port);
		this.user = user;
		this.password = password;
		
		initDBConnectionPool();
	}
	
	public abstract void initDBConnectionPool();

	public Connection getConnection() throws Exception {
		return ds.getConnection();
	}

	public void putBackConnection(Connection conn) throws Exception {
		if (conn != null && !conn.isClosed()) {
			conn.close();
		}
	}
}
