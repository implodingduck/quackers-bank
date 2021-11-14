package com.quackers.bank.config;

import com.azure.spring.autoconfigure.b2c.AADB2COidcLoginConfigurer;

import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;

@EnableWebSecurity
public class WebSecurityConfig extends WebSecurityConfigurerAdapter  {

    private final AADB2COidcLoginConfigurer configurer;

    public WebSecurityConfig(AADB2COidcLoginConfigurer configurer) {
        this.configurer = configurer;
    }


    @Override
    protected void configure(HttpSecurity http) throws Exception {
        // super.configure(http);
        
        http.oauth2Login().defaultSuccessUrl("/");

        http.csrf().disable();
        
        // http.authorizeRequests()
        //         .antMatchers(HttpMethod.GET, "/health/**").permitAll()
        //         .antMatchers(HttpMethod.GET, "/").permitAll()
        //         .antMatchers(HttpMethod.GET, "/static/**").permitAll()
        //         .antMatchers(HttpMethod.GET, "/**.jpg").permitAll()
        //         .antMatchers(HttpMethod.GET, "/**.png").permitAll();
        
        http.authorizeRequests()
            .antMatchers(HttpMethod.GET, "/health/**").permitAll()
            .antMatchers(HttpMethod.GET, "/static/**").permitAll()
            .antMatchers(HttpMethod.GET, "/**.jpg").permitAll()
            .antMatchers(HttpMethod.GET, "/**.png").permitAll()
            .antMatchers(HttpMethod.GET, "/**.json").permitAll()
            .antMatchers(HttpMethod.GET, "/").permitAll()
            .anyRequest().authenticated().and()
                .apply(configurer);
    }  
}
