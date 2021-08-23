package com.quackers.bank.controllers;

import java.util.Optional;

import com.quackers.bank.models.Account;
import com.quackers.bank.models.Transaction;
import com.quackers.bank.repositories.AccountRepository;
import com.quackers.bank.repositories.TransactionRepository;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;



@RestController
@RequestMapping("/api/transactions")
public class TransactionController {
    private final TransactionRepository transactionRepository;
    private final AccountRepository accountRepository;

    public TransactionController(TransactionRepository transactionRepository, AccountRepository accountRepository){
        this.transactionRepository = transactionRepository;
        this.accountRepository = accountRepository;
    }

    

    @PostMapping("/")
    @ResponseStatus(HttpStatus.CREATED)
    public Transaction createTransaction(@RequestBody Transaction t) {
        Transaction retVal;
        Account a = accountRepository.findById(t.getAccountId()).orElse(null);
        if (a != null) {
            if ( (a.getBalance() + t.getAmount()) > 0){
                a.setBalance(a.getBalance() + t.getAmount());
                retVal = transactionRepository.save(t);
                Account updatedA = accountRepository.save(a);
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
        return transactionRepository.findByAccountId(accountId);
    }
}
