package com.main;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.sql.SQLException;
import java.util.ArrayList;

import com.specific.SF_RecordReader;
import com.specific.SZ_RecordReader;

public class Main {

	public static void main(String[] args) throws SQLException {
		Main m = new Main();
//		m.import_SF_GPSData();
		m.import_SZ_GPSData();
	}
	
	//import GPS data for San Francisco
	public void import_SF_GPSData() {
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
			SF_RecordReader reader = new SF_RecordReader(driver, datafileName);
			reader.startRead();
			
			System.out.println(driver + " complete inserting!");
			System.out.println();
		}
	}
	
	//import GPS data for Shenzhen
	public void import_SZ_GPSData() {
		String dir = "/home/jackjia/program/taxi-analysis-relative/data/sz_taxi_data/data/sample-utf8/";
		File dataDir = new File(dir);
		File[] driversData = dataDir.listFiles();
		
		// import every driver's GPS data
		int count = 0;
		long startTime = System.currentTimeMillis();
		long previousTime = startTime;
		
		for(File driverData : driversData) {
			count++;
			String fileName = driverData.getName();
			String driver = fileName.substring(0, fileName.indexOf("."));
			System.out.println("Begin " + driver + " inserting, the " + count + " th dirver.");
			
			
			String datafileName = dir + fileName;
			SZ_RecordReader pgsImporter = new SZ_RecordReader(driver, datafileName);
			pgsImporter.startRead();
			
			long currentTime = System.currentTimeMillis();
			System.out.println(driver + " complete inserting!  Timecost: " + (currentTime - previousTime)/1000 + "s. ");
			System.out.println();
			previousTime = currentTime;
		}
		
		System.out.println("Total time cost: " + (System.currentTimeMillis() - startTime)/1000 + "s. ");
	}
}
