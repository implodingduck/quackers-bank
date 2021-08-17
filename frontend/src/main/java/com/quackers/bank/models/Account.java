package com.quackers.bank.models;
public class Account {

    private Long id;

    private String type;
    private String email;
    private Long balance;

    public Account(){

    }

    public Account(String type, Long balance){
        this.type = type;
        this.balance = balance;
    }

    public Long getId(){
        return id;
    }
    
    public Long getBalance() {
        return balance;
    }
    public void setBalance(Long balance) {
        this.balance = balance;
    }
    public String getEmail() {
        return email;
    }
    public void setEmail(String email) {
        this.email = email;
    }
    public String getType() {
        return type;
    }
    public void setType(String type) {
        this.type = type;
    }
    

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof Account)) {
            return false;
        }
        return id != null && id.equals(((Account) o).id);
    }


}