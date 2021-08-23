package com.quackers.bank.controllers;

import static org.springframework.security.oauth2.client.web.reactive.function.client.ServletOAuth2AuthorizedClientExchangeFilterFunction.clientRegistrationId;

import java.util.List;

import com.quackers.bank.models.Account;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.oidc.user.DefaultOidcUser;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
@RestController
@RequestMapping("/api/accounts")
public class AccountController {

    @Autowired
    WebClient webClient;

    public AccountController(){

    }

    @PostMapping("/")
    @ResponseStatus(HttpStatus.CREATED)
    public Account createAccount(@RequestBody Account account,  Authentication  authentication) {
        DefaultOidcUser userDetails = (DefaultOidcUser) authentication.getPrincipal();
        account.setUid(userDetails.getSubject()); 
        Account body = webClient
            .post()
            .uri(String.format("http://accounts-api:8081/api/accounts/"))
            .attributes(clientRegistrationId("quackers-bank-accounts"))
            .contentType(MediaType.APPLICATION_JSON)
            .body(BodyInserters.fromValue(account))
            .retrieve()
            .bodyToMono(Account.class)
            .block();
        System.out.println(String.format("Response back: %s", body));
        return body;
    }

    @GetMapping("/")
    public Iterable<Account> getAccounts(Authentication  authentication) {
        DefaultOidcUser userDetails = (DefaultOidcUser) authentication.getPrincipal();
        System.out.println(userDetails);
        List<Account> body = webClient
            .get()
            .uri(String.format("http://accounts-api:8081/api/accounts/owner/%s/", userDetails.getSubject()))
            .attributes(clientRegistrationId("quackers-bank-accounts"))
            .retrieve()
            .bodyToMono(new ParameterizedTypeReference<List<Account>>() {})
            .block();
        System.out.println(String.format("Response back: %s", body.size()));
        return body;
    }

    @DeleteMapping("/{id}")
    public String deleteAccount(@PathVariable Long id){
        String body = webClient
            .delete()
            .uri(String.format("http://accounts-api:8081/api/accounts/%s/", id))
            .attributes(clientRegistrationId("quackers-bank-accounts"))
            .retrieve()
            .bodyToMono(String.class)
            .block();
        System.out.println(String.format("Response back: %s", body));
        return body;
    }
}
