package com.quackers.bank.controllers;

import com.quackers.bank.models.Hello;

import java.util.Date;
import java.util.concurrent.atomic.AtomicLong;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HellowWorldController {
    private static final String template = "Hello, the time is: %s!";
	private final AtomicLong counter = new AtomicLong();

	@GetMapping("/api")
	public Hello hello(@RequestParam(value = "name", defaultValue = "World") String name) {
		return new Hello(counter.incrementAndGet(), String.format(template, new Date().toString()));
	}

}