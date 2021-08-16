package com.quackers.bank.models;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

@Entity
@Table(name="accounttransaction")
public class Transaction {
    @Id
    @GeneratedValue
    private Long id;
    private Long accountId;
    private String description;
    private Long amount;

    @Temporal(TemporalType.TIMESTAMP)
    private java.util.Date dateCreated;

    public Transaction(){
        this.dateCreated = new java.util.Date();
    }

    public Transaction(Long accountId, Long amount, String description){
        this.accountId = accountId;
        this.amount = amount;
        this.setDescription(description);
        this.dateCreated = new java.util.Date();
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Long getAccountId() {
        return accountId;
    }

    public Long getAmount() {
        return amount;
    }

    public java.util.Date getDateCreated() {
        return dateCreated;
    }

    public Long getId() {
        return id;
    }

    public void setAmount(Long amount) {
        this.amount = amount;
    }

    public void setAccountId(Long accountId) {
        this.accountId = accountId;
    } 

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof Transaction)) {
            return false;
        }
        return id != null && id.equals(((Transaction) o).id);
    }

}
