package com.quackers.bank.controllers;

import com.quackers.bank.models.Hello;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {
    @GetMapping("/health")
	public Hello health() {
		String ik = System.getenv("APPINSIGHTS_INSTRUMENTATIONKEY");
		if (ik != null){
			return new Hello(200, ik);
		} else  {
			return new Hello(200, "healthy");
		}
		
	}
}
