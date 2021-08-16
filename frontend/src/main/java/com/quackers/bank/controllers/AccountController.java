package com.quackers.bank.controllers;

import com.quackers.bank.models.Account;
import com.quackers.bank.repositories.AccountRepository;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.oidc.user.DefaultOidcUser;

@RestController
@RequestMapping("/api/accounts")
public class AccountController {
    private final AccountRepository accountRepository;

    public AccountController(AccountRepository accountRepository){
        this.accountRepository = accountRepository;
    }

    @PostMapping("/")
    @ResponseStatus(HttpStatus.CREATED)
    public Account createAccount(@RequestBody Account account,  Authentication  authentication) {
        DefaultOidcUser userDetails = (DefaultOidcUser) authentication.getPrincipal();
        account.setEmail(userDetails.getPreferredUsername());
        return accountRepository.save(account);
    }

    @GetMapping("/")
    public Iterable<Account> getAccounts(Authentication  authentication) {
        DefaultOidcUser userDetails = (DefaultOidcUser) authentication.getPrincipal();
        return accountRepository.findByEmail(userDetails.getPreferredUsername());
    }

    @DeleteMapping("/{id}")
    public String deleteAccount(@PathVariable Long id){
        accountRepository.deleteById(id);
        return "Deleted!";
    }
}
