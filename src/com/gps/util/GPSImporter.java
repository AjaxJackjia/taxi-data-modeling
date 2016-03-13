package com.gps.util;

import java.sql.PreparedStatement;
import java.sql.SQLException;

import com.db.DBUtil;

public class GPSImporter {
	private int batch_size = 1000;
	PreparedStatement insert_into_stmt;

	public int getBatch_size()
	{
		return batch_size;
	}

	public void setBatch_size(int batch_size)
	{
		this.batch_size = batch_size;
	}
	
	//comment: ST_Point(float x_lon, float y_lat);
	//to_timestamp() convert unix time stamp to postgres timestimp with time zone(computer's local time zone), 
	//so we should convert it to the time zone of San Franciscom(UTC-8).
	public void openStatement() {
		this.insert_into_stmt = DBUtil.getInstance().createSqlStatement(
				 "INSERT INTO " + 
				 "	taxi.gps_raw " + 
				 "VALUES(?, st_setsrid(st_point(?, ?), 4326), ?, to_timestamp(?) at time zone 'UTC-8', ?, ?)");
		try {
			this.insert_into_stmt.getConnection().setAutoCommit(false);
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	public void setStatementParams(TaxiRecord record) throws SQLException {
		insert_into_stmt.setString (1, record.getId()); 	//车牌
		insert_into_stmt.setDouble (2, record.getLng());	//经度
		insert_into_stmt.setDouble (3, record.getLat());	//纬度
		insert_into_stmt.setBoolean(4, record.getStatus()); //是否载客
		insert_into_stmt.setLong   (5, record.getGpsTime());//时间
		insert_into_stmt.setDouble (6, record.getV());		//即时车速
		insert_into_stmt.setInt    (7, record.getAngle());	//行车方向
		
		insert_into_stmt.addBatch();
	}
	
	public void executeBatch() throws SQLException {
		insert_into_stmt.executeBatch();
		insert_into_stmt.clearBatch();
		insert_into_stmt.getConnection().commit();
	}
	
	public void closeStatement() {
		DBUtil.getInstance().closeStatementResource(this.insert_into_stmt);
	}
}

