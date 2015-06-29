package com.util;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;

import com.db.DBUtil;

public class GPSImporter {
	private String file_name;
	private String driver;
	private int batch_size = 1000;
	PreparedStatement insert_into_stmt;

	public GPSImporter(String driver, String file_name) throws SQLException {
		this.driver = driver;
		this.file_name = file_name;
	}

	public void startImport() {
		openStatement();
		try {
			BufferedReader input = null;
			try {
				input = new BufferedReader(new FileReader(file_name));
				String line;
				String words[];
				int cnt = 0;
				while ((line = input.readLine()) != null) {
					words = line.split(" ");
					insert_into_stmt.setString(1, this.driver);
					insert_into_stmt.setDouble(2, Double.parseDouble(words[1]));
					insert_into_stmt.setDouble(3, Double.parseDouble(words[0]));
					insert_into_stmt.setBoolean(4, words[2].equals("1")?true:false);
					insert_into_stmt.setDouble(5, Double.parseDouble(words[3]));
					insert_into_stmt.addBatch();
					++cnt;
					if (cnt % batch_size == 0) {
						insert_into_stmt.executeBatch();
						insert_into_stmt.clearBatch();
						insert_into_stmt.getConnection().commit();
					}
				}
				insert_into_stmt.executeBatch();
				insert_into_stmt.clearBatch();
				insert_into_stmt.getConnection().commit();
			} finally {
				if (input != null)
					input.close();
			}
			closeStatement();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (SQLException e) {
			e.printStackTrace();
			e.getNextException().printStackTrace();
		}
	}

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
				 "VALUES(?, st_setsrid(st_point(?, ?), 4326), ?, to_timestamp(?) at time zone 'UTC-8')");
		try {
			this.insert_into_stmt.getConnection().setAutoCommit(false);
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	public void closeStatement() {
		DBUtil.getInstance().closeStatementResource(this.insert_into_stmt);
	}
}

