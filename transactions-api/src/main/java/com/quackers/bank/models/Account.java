package com.quackers.bank.models;

public class Account {

    private Long id;

    private String type;
    private String uid;
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
    public String getUid() {
        return uid;
    }
    public void setUid(String uid) {
        this.uid = uid;
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

    // @Override
    // public String toString(){
    //     return String.format("{ \"\""
    // }

}
