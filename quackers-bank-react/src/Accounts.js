import React, {Component, useState, useEffect} from 'react';
import logo from './logo.svg';
import './App.css';
import Account from './Account'

function Accounts() {
    const [myaccounts, setMyAccounts] = useState([]);
    const [showCreateAccount, setShowCreateAccount] = useState(false);
    const [createAccount, setCreateAccount] = useState({
        "type": "Checking",
        "balance": 1000
    });

    useEffect(() => {
        fetch('/api/accounts/')
            .then((response) => response.json())
            .then(accountsJson => {
                console.log(accountsJson)
                setMyAccounts(accountsJson);
            });
    },[])

    const toggleCreateAccount = () => {
        setShowCreateAccount(!showCreateAccount)
    }

    const handleCreateAccount = () => {
        fetch('/api/accounts/', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                "type": createAccount.type,
                "balance": createAccount.balance
            })
        } ).then( () => window.location.reload())
    }

    const handleTypeChange = (e) => {
        const updatedNewAccount = JSON.parse(JSON.stringify(createAccount))
        updatedNewAccount.type = e.target.value
        setCreateAccount(updatedNewAccount)
    }
    
    const handleBalanceChange = (e) => {
        const updatedNewAccount = JSON.parse(JSON.stringify(createAccount));
        const parsed = parseInt(e.target.value);
        updatedNewAccount.balance = (isNaN(parsed) || parsed < 0) ? 0 : parsed
        setCreateAccount(updatedNewAccount)
    }

    return (
        <div className="App">
            <button onClick={toggleCreateAccount}>Create New Account</button>
            <fieldset style={ { "display": (showCreateAccount) ? "block" : "none"  }}>
                <legend>New Account:</legend>
                <label>Type: <select onChange={handleTypeChange}>
                    <option selected={(createAccount.type === 'Checking')}>Checking</option>
                    <option selected={(createAccount.type === 'Savings')}>Savings</option>
                </select></label>
                <label>Initial Balance: <input type="text" name="balance" onChange={handleBalanceChange} value={createAccount.balance} /></label>
                <button onClick={handleCreateAccount}>Create!</button>
            </fieldset>
            <div>
                { myaccounts.map((account, i) => {
                    return <Account key={i} account={account}></Account>
                })}
            </div>
        </div>
    )
}

export default Accounts;