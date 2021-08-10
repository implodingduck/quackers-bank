package com.quackers.bank.controllers;

import java.util.Date;
import java.util.concurrent.atomic.AtomicLong;

import com.quackers.bank.models.Hello;

import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.oidc.user.DefaultOidcUser;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloWorldController {
    private static final String template = "Hello, %s! The time is: %s! and ";
	private final AtomicLong counter = new AtomicLong();

	@GetMapping("/api")
	public Hello hello(@RequestParam(value = "name", defaultValue = "World") String name, Authentication  authentication ) {
		DefaultOidcUser userDetails = (DefaultOidcUser) authentication.getPrincipal();
		System.out.println(userDetails.toString());
		return new Hello(counter.incrementAndGet(), String.format(template, userDetails.getFullName(), new Date().toString()));
	}


	@GetMapping("/api/user")
	public DefaultOidcUser getUser(Authentication  authentication ) {
		//TODO this is probably too many details and we can cut back
		DefaultOidcUser userDetails = (DefaultOidcUser) authentication.getPrincipal();
		System.out.println(userDetails.toString());
		return userDetails;
	}
}