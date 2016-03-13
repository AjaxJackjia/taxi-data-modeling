package com.main;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.sql.SQLException;
import java.util.ArrayList;

import com.gps.main.ImportGPSData;
import com.gps.specific.SF_RecordReader;
import com.gps.specific.SZ_RecordReader;
import com.map.main.OSMDataRetriever;

public class Main {

	public static void main(String[] args) throws SQLException {
		//GPS data import
//		ImportGPSData.import_SF_GPSData();
//		ImportGPSData.import_SZ_GPSData();
		
		//OSM data retrieve
		OSMDataRetriever.retrieve();
	}
	
	
}
