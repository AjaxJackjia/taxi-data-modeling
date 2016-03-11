package com.util;

public class TaxiRecord {
	private String id;
	private double lat;
	private double lng;
	private boolean status;
	private long gpsTime; //unix timestamp
	private double v;
	private int angle;
	private boolean isValid; //mark whether this record is correct
	
	public TaxiRecord() {
		this.v = 0;
		this.angle = -1;
		this.isValid = true;
	}
	
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public double getLat() {
		return lat;
	}
	public void setLat(double lat) {
		this.lat = lat;
	}
	public double getLng() {
		return lng;
	}
	public void setLng(double lng) {
		this.lng = lng;
	}
	public boolean getStatus() {
		return status;
	}
	public void setStatus(boolean status) {
		this.status = status;
	}
	public long getGpsTime() {
		return gpsTime;
	}
	public void setGpsTime(long gpsTime) {
		this.gpsTime = gpsTime;
	}
	public double getV() {
		return v;
	}
	public void setV(double v) {
		this.v = v;
	}
	public int getAngle() {
		return angle;
	}
	public void setAngle(int angle) {
		this.angle = angle;
	}
	public boolean isValid() {
		return isValid;
	}
	public void setValid(boolean isValid) {
		this.isValid = isValid;
	}
	
	public String toString() {
		return this.id + " " + this.lng + " " + this.lat + " " + this.gpsTime + " " + this.status;
	}
	
}
