package com.quackers.bank.controllers;

import java.util.ArrayList;
import java.util.List;

import com.quackers.bank.models.Transaction;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;

import static org.springframework.security.oauth2.client.web.reactive.function.client.ServletOAuth2AuthorizedClientExchangeFilterFunction.clientRegistrationId;

@RestController
@RequestMapping("/api/transactions")
public class TransactionController {
    
    @Autowired
    WebClient webClient;

    public TransactionController(){

    }

    

    @PostMapping("/")
    @ResponseStatus(HttpStatus.CREATED)
    public Transaction createTransaction(@RequestBody Transaction t) {
        System.out.println(String.format("createTransaction... %s: %s", t.getAccountId(), t.getAmount()));
        Transaction body = webClient
            .post()
            .uri(String.format("http://transactions-api:8082/api/transactions/"))
            .attributes(clientRegistrationId("quackers-bank-transactions"))
            .contentType(MediaType.APPLICATION_JSON)
            .body(BodyInserters.fromValue(t))
            .retrieve()
            .bodyToMono(Transaction.class)
            .block();
        System.out.println(String.format("Response back: %s", body));
        return body;
    }

    @GetMapping("/{accountId}")
    public Iterable<Transaction> getTransactions(@PathVariable Long accountId) {
        List<Transaction> body = webClient
            .get()
            .uri(String.format("http://transactions-api:8082/api/transactions/%s/", accountId))
            .attributes(clientRegistrationId("quackers-bank-transactions"))
            .retrieve()
            .bodyToMono(new ParameterizedTypeReference<List<Transaction>>() {})
            .block();
        System.out.println(String.format("Response back: %s", body.size()));
        return body;
    }
}
