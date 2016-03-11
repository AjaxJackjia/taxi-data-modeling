package com.util;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.sql.SQLException;
import java.text.ParseException;

public abstract class RecordReader {
	private String file_name;
	private String driver;
	private static GPSImporter importer = new GPSImporter();
	
	public String getFile_name() {
		return file_name;
	}

	public void setFile_name(String file_name) {
		this.file_name = file_name;
	}

	public String getDriver() {
		return driver;
	}

	public void setDriver(String driver) {
		this.driver = driver;
	}

	//handle file record
	abstract public TaxiRecord handleRecord(String record) throws Exception;
	
	//read file
	public void startRead() {
		importer.openStatement();
		try {
			BufferedReader input = null;
			try {
				input = new BufferedReader(new FileReader(this.file_name));
				String line;
				int cnt = 0;
				while ((line = input.readLine()) != null) {
					TaxiRecord record = handleRecord(line);
					if(!record.isValid()) continue;
					importer.setStatementParams(record);
					++cnt;
					if (cnt % importer.getBatch_size() == 0) {
						importer.executeBatch();
					}
				}
				importer.executeBatch();
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				if (input != null)
					input.close();
			}
			importer.closeStatement();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
