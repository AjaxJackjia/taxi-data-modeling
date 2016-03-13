package com.map.main;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.ClientResponse;
import com.sun.jersey.api.client.WebResource;

public class Request {
	public static void get(String url, String fileName) throws IOException {
		Client client = Client.create();
		WebResource wr = client.resource(url);
		ClientResponse clientResponse= wr.get(ClientResponse.class);
		
		if(clientResponse.getStatus() == 200) {
			File res= clientResponse.getEntity(File.class);
			File downloadfile = new File(fileName);
			res.renameTo(downloadfile);
			FileWriter fr = new FileWriter(res);
			fr.flush();
		}else{
			System.out.println(url + " request failed!");
		}
	}
}
