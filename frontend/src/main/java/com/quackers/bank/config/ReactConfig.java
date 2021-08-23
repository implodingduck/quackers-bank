package com.quackers.bank.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class ReactConfig implements WebMvcConfigurer {

  //Thanks to https://stackoverflow.com/a/47704160
  @Override
  public void addViewControllers(ViewControllerRegistry registry) {
      registry.addViewController("/{spring:\\w+}")
            .setViewName("forward:/");
      registry.addViewController("/**/{spring:\\w+}")
            .setViewName("forward:/");
      registry.addViewController("/{spring:\\w+}/**{spring:?!(\\.js|\\.css)$}")
            .setViewName("forward:/");
  }
}