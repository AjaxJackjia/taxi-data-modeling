package com.db;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

public class DBUtil {
	private static DBUtil dbInstance;
	private static Properties properties;
	private static AbstractDBConnectionPool pool;

	private DBUtil() {
		dbInstance = null;
		properties = getProperties();
		pool = getPool();
	}
	
	public static DBUtil getInstance() {
		if (null == dbInstance) {
			dbInstance = new DBUtil();
		}
		return dbInstance;
	}
	
	private Properties getProperties() {
		if(properties == null) {
			try{
				InputStream prop_in_s = DBUtil.class.getResourceAsStream("/db.properties");
				properties = new Properties();
				properties.load(prop_in_s);
				prop_in_s.close();
			}catch (Exception e) {
				e.printStackTrace();
			}
		}
		return properties;
	}
	
	private AbstractDBConnectionPool getPool() {
		if(pool == null) {
			try{
				String connectionpool = properties.getProperty("connectionpool");
				String serverName = properties.getProperty("servername");
				String schema = properties.getProperty("schema");
				String port = properties.getProperty("port");
				String user = properties.getProperty("user");
				String password = properties.getProperty("password");
				
				Class c = Class.forName(connectionpool);
				pool = (AbstractDBConnectionPool) c.newInstance();
				pool.configConnectionPool(serverName, schema, port, user, password);
			}catch (Exception e) {
				e.printStackTrace();
			}
		}
		return pool;
	}
	
	private Connection getConnection() {
		try {
			return pool.getConnection();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	public void closeConn(Connection conn) {
		try {
			pool.putBackConnection(conn);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public void closeStatementResource(Statement stmt)
	{
		//From the javadocs:
		//    1. When a Statement object is closed, its current ResultSet object, if one exists, is also closed.
		//	  2. However, the javadocs are not very clear on whether the Statement and 
		//	     ResultSet are closed when you close the underlying Connection. 
		ResultSet rs = null;
		Connection conn = null;
		try {
			if (!stmt.isClosed()) {
				rs = stmt.getResultSet();
				conn = stmt.getConnection();
			}
		} catch (SQLException ex) {
			ex.printStackTrace();
		}
		try {
			if(rs != null && !rs.isClosed()) {
				rs.close();
			}
			if (stmt != null) {
				stmt.close();
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		closeConn(conn);
	}
	
	public void closeResultSetResource(ResultSet rs) {
		Statement stmt = null;
		Connection conn = null;
		try {
			if (!rs.isClosed()) {
				stmt = rs.getStatement();
				conn = stmt.getConnection();
			}
		} catch (SQLException ex) {
			ex.printStackTrace();
		}
		try {
			if (rs != null) {
				rs.close();
				stmt.close();
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		closeConn(conn);
	}

	public PreparedStatement createSqlStatement(String p_sql,
			Object... p_parameters)
	{
		Connection connection = getConnection();
		PreparedStatement statement = null;
		try {
			statement = connection.prepareStatement(p_sql);
			for (int i = 0; i < p_parameters.length; i++) {
				Object param = p_parameters[i];
				statement.setObject(i + 1, param);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}

		return statement;
	}

	public ResultSet executeSQL(String sql, Object... params)
	{
		try {
			PreparedStatement pst = createSqlStatement(sql);
			for (int i = 1; i <= params.length; i++) {
				pst.setObject(i, params[i - 1]);
			}
			return pst.executeQuery();
		} catch (Exception ex) {
			System.out.println("Execute sql error!");
			ex.printStackTrace();
		}
		return null;
	}

	public PreparedStatement executeUpdate(String sql, Object... params)
	{
		try {
			PreparedStatement pst = createSqlStatement(sql);
			for (int i = 0; i < params.length; i++) {
				pst.setObject(i + 1, params[i]);
			}
			pst.executeUpdate();
			return pst;
		} catch (Exception ex) {
			System.out.println("Execute update error!");
			ex.printStackTrace();
		}
		return null;
	}
}
