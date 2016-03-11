package com.specific;

import java.text.ParseException;

import com.util.RecordReader;
import com.util.TaxiRecord;

public class SF_RecordReader extends RecordReader {
	
	public SF_RecordReader(String driver, String file_name) {
		this.setDriver(driver);
		this.setFile_name(file_name);
	}

	public TaxiRecord handleRecord(String line) throws ParseException {
		//use Space as separating character
		String words[] = line.split(" ");
		
		//create taxi record
		TaxiRecord record = new TaxiRecord();
		
		//driver   - id
		//words[0] - 纬度
		//words[1] - 经度
		//words[2] - 是否载客
		//words[3] - 时间
		record.setId(this.getDriver());
		record.setLat(Double.parseDouble(words[0]));
		record.setLng(Double.parseDouble(words[1]));
		record.setStatus(Integer.parseInt(words[2])==1?true:false);
		record.setGpsTime(Long.parseLong(words[3]));
		
		return record;
	}
}
