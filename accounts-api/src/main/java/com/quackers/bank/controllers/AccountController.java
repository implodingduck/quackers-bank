package com.quackers.bank.controllers;

import com.azure.spring.autoconfigure.b2c.AADB2COAuth2AuthenticatedPrincipal;
import com.quackers.bank.models.Account;
import com.quackers.bank.repositories.AccountRepository;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
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
    public Account createAccount(@RequestBody Account account) {
        return accountRepository.save(account);
    }

    @GetMapping("/{id}")
    public Account getAccountById(@PathVariable Long id, Authentication  authentication) {
        System.out.println("Lets see if we can find some accounts");
        AADB2COAuth2AuthenticatedPrincipal userDetails = (AADB2COAuth2AuthenticatedPrincipal) authentication.getPrincipal();
        System.out.println(String.format("User: %s", userDetails.getName()));
        System.out.println(String.format("Attributes: %s", userDetails.getAttributes()));
        System.out.println(String.format("Authorities: %s", userDetails.getAuthorities()));
        return accountRepository.findById(id).orElse(null);
    }
    @PutMapping("/{id}")
    public Account updateAccountById(@PathVariable Long id, @RequestBody Account updatedAccount, Authentication  authentication) {
        System.out.println(String.format("%s new balance = %s", id, updatedAccount.getBalance()));
        AADB2COAuth2AuthenticatedPrincipal userDetails = (AADB2COAuth2AuthenticatedPrincipal) authentication.getPrincipal();
        System.out.println(String.format("User: %s", userDetails.getName()));
        System.out.println(String.format("Attributes: %s", userDetails.getAttributes()));
        System.out.println(String.format("Authorities: %s", userDetails.getAuthorities()));
        Account a = accountRepository.findById(id).orElse(null);
        Account retVal = null;
        if (a != null && updatedAccount.getBalance() != null){
            a.setBalance(updatedAccount.getBalance());
            retVal = accountRepository.save(a);
        }
        return retVal;

    }

    @GetMapping("/owner/{uid}")
    public Iterable<Account> getAccountsByOwner(@PathVariable String uid, Authentication  authentication) {
        System.out.println("Lets see if we can find some accounts");
        AADB2COAuth2AuthenticatedPrincipal userDetails = (AADB2COAuth2AuthenticatedPrincipal) authentication.getPrincipal();
        System.out.println(String.format("User: %s", userDetails.getName()));
        System.out.println(String.format("Attributes: %s", userDetails.getAttributes()));
        System.out.println(String.format("Authorities: %s", userDetails.getAuthorities()));
        return accountRepository.findByUid(uid);
    }

    @DeleteMapping("/{id}")
    public String deleteAccount(@PathVariable Long id){
        accountRepository.deleteById(id);
        return "Deleted!";
    }

    @GetMapping("/exception")
    public Account throwException() {
        throw new RuntimeException("I am throwing this on purpose");
    }
}
