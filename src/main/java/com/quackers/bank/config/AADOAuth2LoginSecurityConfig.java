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
        
        http.csrf().disable().authorizeRequests()
                .antMatchers(HttpMethod.GET, "/health/**").permitAll()
                .antMatchers(HttpMethod.GET, "/").permitAll()
                .antMatchers(HttpMethod.GET, "/static/**").permitAll()
                .anyRequest().authenticated()
                .and().oauth2Login().defaultSuccessUrl("/");
        // Do some custom configuration
    }  
}
