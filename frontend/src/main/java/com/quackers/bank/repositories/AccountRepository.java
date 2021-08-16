package com.quackers.bank.repositories;

import java.util.List;

import com.quackers.bank.models.Account;

import org.springframework.data.jpa.repository.JpaRepository;

public interface AccountRepository extends JpaRepository<Account, Long>{
    List<Account> findByEmail(String email);
}
