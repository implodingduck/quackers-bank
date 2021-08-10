import React, {Component, useState, useEffect} from 'react';
import logo from './logo.svg';
import './App.css';

function Accounts() {
    const [myaccounts, setMyAccounts] = useState([]);

    useEffect(() => {
        fetch('/api/accounts/')
            .then((response) => response.json())
            .then(accountsJson => {
                console.log(accountsJson)
                setMyAccounts(accountsJson);
            });
    },[])

    const handleCreateAccount = () => {
        fetch('/api/accounts/', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                "type": "Checking",
                "balance": 1000
            })
        } )
    }

    return (
        <div className="App">
            <button onClick={handleCreateAccount}>Create New Account</button>
            <div>
                { myaccounts.map((account, i) => {
                    return <div key={i}>{JSON.stringify(account)}</div>
                })}
            </div>
        </div>
    )
}

export default Accounts;