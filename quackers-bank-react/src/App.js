import React, {Component, useState, useEffect} from 'react';
import logo from './logo.svg';
import './App.css';
import ApiTest from './ApiTest'
import Accounts from './Accounts'
import {
    BrowserRouter as Router,
    Switch,
    Route,
    Link
  } from "react-router-dom";

function App () {
    const [authUser, setAuthUser] = useState({});

    useEffect(() => {
        fetch('/api/user')
            .then(response => {
                if (response.ok) { 
                    return response.json()
                }
                else{
                    return {}
                }
            })
            .then(user => {
                setAuthUser(user)
            });
    },[])

    return (
        <div className="App">
            <div>{ (authUser.attributes) ? <span>{ authUser.attributes.name } (<a href="/logout">Logout</a>)</span> : <a href="/login">Login</a> }</div>
            <Router forceRefresh={true}>
                <Switch>
                    
                    <Route path="/test">
                        <ApiTest></ApiTest>
                    </Route>
                    <Route path="/accounts">
                        <Accounts></Accounts>
                    </Route>
                    <Route path="">
                        <h1>Welcome to Quackers Bank</h1>
                        { (authUser.attributes) ? <Link to={"/accounts"}>My Accounts</Link> : "" }
                        { (authUser.attributes) ? <Link to={"/test"}>Test Stuff</Link> : "" }
                         
                    </Route>
                </Switch>
            </Router>
        </div>
    )
}

export default App;