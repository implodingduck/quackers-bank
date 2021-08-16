package com.quackers.bank.config;

import com.azure.spring.aad.webapp.AADWebSecurityConfigurerAdapter;

import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;

@EnableWebSecurity
@EnableGlobalMethodSecurity(prePostEnabled = true)
public class AADOAuth2LoginSecurityConfig extends AADWebSecurityConfigurerAdapter {
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        super.configure(http);
        
        http.oauth2Login().defaultSuccessUrl("/");

        http.csrf().disable();
        
        http.authorizeRequests()
                .antMatchers(HttpMethod.GET, "/health/**").permitAll()
                .antMatchers(HttpMethod.GET, "/").permitAll()
                .antMatchers(HttpMethod.GET, "/static/**").permitAll()
                .antMatchers(HttpMethod.GET, "/**.jpg").permitAll()
                .antMatchers(HttpMethod.GET, "/**.png").permitAll()
                .anyRequest().authenticated();
    }  
}
