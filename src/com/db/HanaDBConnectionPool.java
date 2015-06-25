package com.db;

import com.sap.db.jdbcext.DataSourceSAP;

public class HanaDBConnectionPool extends AbstractDBConnectionPool {
	
	public void initDBConnectionPool() {
		ds = new DataSourceSAP();
		((DataSourceSAP) ds).setServerName(serverName);
		((DataSourceSAP) ds).setPortNumber(port);
		((DataSourceSAP) ds).setSchema(schema);
		((DataSourceSAP) ds).setUser(user);
		((DataSourceSAP) ds).setPassword(password);
	}
}
