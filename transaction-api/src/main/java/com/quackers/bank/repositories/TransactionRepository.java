package com.quackers.bank.repositories;

import java.util.List;

import com.quackers.bank.models.Transaction;

import org.springframework.data.jpa.repository.JpaRepository;

public interface TransactionRepository extends JpaRepository<Transaction, Long>{
    List<Transaction> findByAccountId(Long accountId);
}
