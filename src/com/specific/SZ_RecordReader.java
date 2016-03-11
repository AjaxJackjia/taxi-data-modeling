package com.specific;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import com.util.RecordReader;
import com.util.TaxiRecord;

public class SZ_RecordReader extends RecordReader {
	
	public SZ_RecordReader(String driver, String file_name) {
		this.setDriver(driver);
		this.setFile_name(file_name);
	}

	public TaxiRecord handleRecord(String line) throws ParseException {
		//remove the last comma
		line = line.substring(0, line.length()-1);
		
		//use comma as separating character
		String words[] = line.split(",");
		
		//create taxi record
		TaxiRecord record = new TaxiRecord();
		
		//words[0] - 车牌
		//words[1] - 时间
		//words[2] - 经度
		//words[3] - 纬度
		//words[4] - 是否载客
		//words[5] - 即时车速
		//words[6] - 行车方向
		record.setId(words[0]);
		//mark the first line is invalid
		if(words[0].equals("name")) {
			record.setValid(false);
			return record;
		}
		
		DateFormat df = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");// 2011/04/26 11:41:58,
		Date gpsTime = df.parse(words[1]); 
		record.setGpsTime(gpsTime.getTime()/1000);
		record.setLng(Double.parseDouble(words[2]));
		record.setLat(Double.parseDouble(words[3]));
		record.setStatus(words[4].equals("1")?true:false);
		record.setV(Double.parseDouble(words[5]));
		record.setAngle(Integer.parseInt(words[6]));
		
		return record;
	}
}
