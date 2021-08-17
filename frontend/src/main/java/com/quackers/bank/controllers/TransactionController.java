package com.quackers.bank.controllers;

import java.util.ArrayList;
import java.util.Optional;

import com.quackers.bank.models.Account;
import com.quackers.bank.models.Transaction;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;

@RestController
@RequestMapping("/api/transactions")
public class TransactionController {
    
    public TransactionController(){

    }

    

    @PostMapping("/")
    @ResponseStatus(HttpStatus.CREATED)
    public Transaction createTransaction(@RequestBody Transaction t) {
        return null;
    }

    @GetMapping("/{accountId}")
    public Iterable<Transaction> getTransactions(@PathVariable Long accountId) {
        return new ArrayList<Transaction>();
    }
}
