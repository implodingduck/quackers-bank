package com.quackers.bank.controllers;

import com.quackers.bank.models.Account;
import com.quackers.bank.models.Transaction;

import com.quackers.bank.repositories.TransactionRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
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
import org.springframework.core.ParameterizedTypeReference;

import static org.springframework.security.oauth2.client.web.reactive.function.client.ServletOAuth2AuthorizedClientExchangeFilterFunction.clientRegistrationId;

@RestController
@RequestMapping("/api/transactions")
public class TransactionController {
    private final TransactionRepository transactionRepository;

    @Value("${quackers.accountsapi.baseurl}")
    private String BASEURL;

    @Autowired
    WebClient webClient;

    public TransactionController(TransactionRepository transactionRepository){
        this.transactionRepository = transactionRepository;
    }

    

    @PostMapping("/")
    @ResponseStatus(HttpStatus.CREATED)
    public Transaction createTransaction(@RequestBody Transaction t) {
        Transaction retVal = null;
        Account a = webClient
            .get()
            .uri(String.format("%s/api/accounts/%s/",BASEURL, t.getAccountId()))
            .attributes(clientRegistrationId("quackers-bank-accounts"))
            .retrieve()
            .bodyToMono(new ParameterizedTypeReference<Account>() {})
            .block();
        if (a != null) {
            if ( (a.getBalance() + t.getAmount()) > 0){
                a.setBalance(a.getBalance() + t.getAmount());
                System.out.println(String.format("The new balance will be: %s", a.getBalance()));
                
                Account body = webClient
                    .put()
                    .uri(String.format("%s/api/accounts/%s/", BASEURL, t.getAccountId()))
                    .attributes(clientRegistrationId("quackers-bank-accounts"))
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(BodyInserters.fromValue(a))
                    .retrieve()
                    .bodyToMono(new ParameterizedTypeReference<Account>() {})
                    .block();
                System.out.println(String.format("After update I got: %s", body.getBalance()));
                if (body != null && body.getBalance().equals(a.getBalance())){
                    System.out.println("I should save this transaction");
                    retVal = transactionRepository.save(t);
                }
            }else {
                throw new RuntimeException("Not enough funds!");
            }
        }else {
            throw new RuntimeException("Invalid Account!");
        }
        

        return retVal;
    }

    @GetMapping("/{accountId}")
    public Iterable<Transaction> getTransactions(@PathVariable Long accountId) {
        System.out.println(String.format("Trying to find transactions for account: %s", accountId));
        Iterable<Transaction> retVal = transactionRepository.findByAccountId(accountId);
        System.out.println(retVal);
        return retVal;
    }
}
