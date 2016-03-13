package com.map.main;
import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.lang.reflect.Field;
import java.util.Arrays;

public class OSMDataRetriever {

	/*
	 * This class is mainly for retrieve OSM map data and merge these small 
	 * OSM files into a large one, then the large file is used by postgreSQL.
	 * 
	 * */
	public static void retrieve() {
		try {
			//step1. generate files
			generateOSMFiles();
			
			//step2. sort osm files
			sortOSMFiles();
			
			//step3. merge osm files
			mergeOSMFiles();
			
		} catch (IOException | InterruptedException | NoSuchFieldException | SecurityException | IllegalArgumentException | IllegalAccessException e) {
			e.printStackTrace();
		}
	}
	
	private static void generateOSMFiles() throws IOException {
		//init
		java.text.DecimalFormat	df = new java.text.DecimalFormat("#.0000");  
		double min_lng = 113.767, 
			   min_lat = 22.445, 
			   max_lng = 114.285, 
			   max_lat = 22.679;
		final int step = 20; //调节每个bounds的范围参数
		double lng_gap = Double.parseDouble(df.format((max_lng - min_lng)/step)),
			   lat_gap = Double.parseDouble(df.format((max_lat - min_lat)/step));
		
		//generate bounds and url
		String baseUrl = "http://193.63.75.100:80/api/0.6/map?bbox=";
		String baseDir = "/home/jackjia/program/taxi-analysis-relative/data/sz_map_data/origin/";

		for(int i = 0;i<step;i++) {
			double bottom 	= Double.parseDouble(df.format(min_lat + i*lat_gap)),
					up 		= Double.parseDouble(df.format(min_lat + (i+1)*lat_gap));
			for(int j = 0;j<step;j++) {
				double left 	= Double.parseDouble(df.format(min_lng + j*lng_gap)),
						right 	= Double.parseDouble(df.format(min_lng + (j+1)*lng_gap));
				
				//params
				String bounds = left + "," + bottom + "," + right + "," + up;
				System.out.println("Current bounds: " + bounds);
				String fileName = (i*step + j) + ".osm";
				
				//request
				System.out.println("begin request for " + fileName );
				Request.get(baseUrl + bounds, baseDir + fileName);
				
				//waiting for file finish downloading
				long preFilesize = 0, postFilesize = 0;
				File file = new File(baseDir + fileName);
				while(!file.exists() || (postFilesize == 0 && preFilesize != postFilesize)) {
					postFilesize = file.length();
					preFilesize = postFilesize;
				}
					
				System.out.println("end request for " + fileName + ", filesize: " + file.length()/1000 + "k");
				System.out.println();
			}
		}
	}
	
	private static void sortOSMFiles() throws IOException, InterruptedException {
		String originBaseDir = "/home/jackjia/program/taxi-analysis-relative/data/sz_map_data/origin/";
		String sortBaseDir = "/home/jackjia/program/taxi-analysis-relative/data/sz_map_data/sort/";
		
		File origin = new File(originBaseDir);
		File[] originFiles = origin.listFiles();
		
		Arrays.sort(originFiles);
		for(File f : originFiles) {
			System.out.println(f.getName());
			String command = "/home/jackjia/program/taxi-analysis-relative/lib/osmosis-latest/bin/osmosis " +
							 " --read-xml file=\"" + originBaseDir + f.getName() + "\"" + 
							 " --sort " + 
							 " --write-xml file=\"" + sortBaseDir + f.getName() + "\"";
			
			ProcessBuilder pb = new ProcessBuilder("bash", "-c", command);
			pb.redirectErrorStream(true);
			Process process=pb.start();
			BufferedReader inStreamReader = new BufferedReader(new InputStreamReader(process.getInputStream())); 
			String line = null;
			while((line = inStreamReader.readLine()) != null) {
				System.out.println(line);
			}
		}

		System.out.println("Sorting process complete!");
	}
	
	private static void mergeOSMFiles() throws IOException, InterruptedException, NoSuchFieldException, SecurityException, IllegalArgumentException, IllegalAccessException {
		String sortBaseDir = "/home/jackjia/program/taxi-analysis-relative/data/sz_map_data/sort/";
		File sort = new File(sortBaseDir);
		File[] sortFiles = sort.listFiles();
		
		Arrays.sort(sortFiles);
		for(int i = 1;i<sortFiles.length;i++) {
			System.err.println("File: " + sortFiles[i].getName());
			String command = "";
			if(i == 1) {
				command ="/home/jackjia/program/taxi-analysis-relative/lib/osmosis-latest/bin/osmosis " + 
						 "--read-xml file=\"" + sortBaseDir + sortFiles[i-1].getName() + "\" " + 
						 "--read-xml file=\"" + sortBaseDir + sortFiles[i].getName() + "\" " + 
						 "--merge " + 
						 "--write-xml file=\"" + sortBaseDir + "merge" + i + ".osm"  + "\"";
				
			}else{
				command ="/home/jackjia/program/taxi-analysis-relative/lib/osmosis-latest/bin/osmosis " + 
						 "--read-xml file=\"" + sortBaseDir + sortFiles[i].getName() + "\" " + 
						 "--read-xml file=\"" + sortBaseDir + "merge" + (i-1) + ".osm" + "\" " + 
						 "--merge " + 
						 "--write-xml file=\"" + sortBaseDir + "merge" + i + ".osm" + "\"";
			}
			
			ProcessBuilder pb = new ProcessBuilder("bash", "-c", command);
			pb.redirectErrorStream(true);
			Process process=pb.start();
			
			BufferedReader inStreamReader = new BufferedReader(new InputStreamReader(process.getInputStream())); 
			String line = null;
			while((line = inStreamReader.readLine()) != null) {
				System.out.println(line);
			}
		}
	}
}
