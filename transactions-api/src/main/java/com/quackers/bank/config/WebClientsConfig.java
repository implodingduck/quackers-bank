package com.quackers.bank.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.client.web.reactive.function.client.ServletOAuth2AuthorizedClientExchangeFilterFunction;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.ExchangeFilterFunction;
import org.springframework.web.reactive.function.client.WebClient;

import reactor.core.publisher.Mono;

@Configuration
public class WebClientsConfig {
    @Bean
	public WebClient webClient(OAuth2AuthorizedClientManager oAuth2AuthorizedClientManager) {
		ServletOAuth2AuthorizedClientExchangeFilterFunction function =
			new ServletOAuth2AuthorizedClientExchangeFilterFunction(oAuth2AuthorizedClientManager);
		return WebClient.builder()
						.apply(function.oauth2Configuration())
						//.filter(logRequest())
						.build();
	}

	// private static ExchangeFilterFunction logRequest() {
	// 	return ExchangeFilterFunction.ofRequestProcessor(clientRequest -> {
    //        	System.out.println(String.format("Request: %s %s", clientRequest.method(), clientRequest.url()));
    //         clientRequest.headers().forEach((name, values) -> values.forEach(value -> System.out.println(String.format("%s=%s", name, value))));
	// 		System.out.println(String.format("The Body: %s", clientRequest.body()));
    //         return Mono.just(clientRequest);
    //     });
	// }
}
