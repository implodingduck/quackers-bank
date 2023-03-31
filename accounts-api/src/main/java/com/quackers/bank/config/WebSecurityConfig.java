package com.quackers.bank.config;

import com.azure.spring.autoconfigure.b2c.AADB2CJwtBearerTokenAuthenticationConverter;

import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;

@EnableWebSecurity
@EnableGlobalMethodSecurity(prePostEnabled = true)
public class WebSecurityConfig extends WebSecurityConfigurerAdapter  {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.authorizeRequests((requests) -> requests.antMatchers(HttpMethod.GET, "/health/**").permitAll().antMatchers(HttpMethod.GET, "/swagger/**").permitAll().anyRequest().authenticated())
        .oauth2ResourceServer()
        .jwt()
        .jwtAuthenticationConverter(new AADB2CJwtBearerTokenAuthenticationConverter());
    }  
}
