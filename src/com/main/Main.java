package com.main;

import java.io.BufferedReader;
import java.io.FileReader;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import com.db.DBUtil;
import com.util.GPSImporter;

public class Main {

	public static void main(String[] args) throws SQLException {
		Main m = new Main();
		m.importGPSData();
	}	
	
	//import GPS data
	public void importGPSData() {
		//1. get drivers from file
		String dir = "/home/jackjia/program/taxi-analysis-relative/data/cabspottingdata/";
		String driversFileName = dir + "_cabs.txt";
		ArrayList<String> drivers = new ArrayList<String>();
		BufferedReader input = null;
		try {
			input = new BufferedReader(new FileReader(driversFileName));
			String line;
			String words[];
			while ((line = input.readLine()) != null) {
				words = line.split("\"");
				drivers.add(words[1]);
			}
			input.close();
		} catch (Exception ex) {
			ex.printStackTrace();
		}
		
		//2. import every driver's GPS data
		int count = 0;
		for(String driver : drivers) {
			count++;
			System.out.println("Begin " + driver + " inserting, the " + count + " th dirver.");
			
			String datafileName = dir + "new_" + driver + ".txt";
			try {
				GPSImporter pgsImporter = new GPSImporter(driver, datafileName);
				pgsImporter.setBatch_size(750);
				pgsImporter.startImport();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			System.out.println(driver + " complete inserting!");
			System.out.println();
		}
	}
}
