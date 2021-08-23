import React, {Component, useState, useEffect} from 'react';
import logo from './logo.svg';
import './App.css';
import { Container, Row, Col, Table, Button, Modal } from 'react-bootstrap'

function Account( {account, refreshAccounts} ) {

    const BASETRANSACTION = {
        "accountId": account.id,
        "action": "Deposit",
        "amount": 0,
        "description": ""
    }

    const [transactionlist, setTransactionlist] = useState([]);
    const [showTransaction, setShowTransaction] = useState(false);
    const [transaction, setTransaction] = useState(JSON.parse(JSON.stringify(BASETRANSACTION)))

    const fetchTransactions = () => {
        fetch('/api/transactions/' + account.id +'/')
        .then((response) => response.json())
        .then(transactionsJson => {
            console.log(transactionsJson)
            setTransactionlist(transactionsJson)
        });
    }

    useEffect(() => {
        fetchTransactions()
    },[])

    const toggleTransaction = () => { 
        setShowTransaction(!showTransaction)
    }

    const handleAmountChange = (e) => {
        const updatedTransaction = JSON.parse(JSON.stringify(transaction));
        const parsed = parseInt(e.target.value);
        updatedTransaction.amount = (isNaN(parsed) || parsed < 0) ? 0 : parsed
        setTransaction(updatedTransaction)
    }

    const handleActionChange = (e) => {
        const updatedTransaction = JSON.parse(JSON.stringify(transaction));
        updatedTransaction.action = e.target.value
        setTransaction(updatedTransaction)
    }

    const handleDescriptionChange = (e) => {
        const updatedTransaction = JSON.parse(JSON.stringify(transaction));
        updatedTransaction.description = e.target.value
        setTransaction(updatedTransaction)
    }

    const handleTransaction = () => {
        setShowTransaction(false)
        fetch('/api/transactions/', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                "accountId": transaction.accountId,
                "amount": (transaction.action === 'Withdraw') ? -1 * transaction.amount : transaction.amount,
                "description": transaction.description
            })
        } ).then( () => { 
            fetchTransactions()
            refreshAccounts()
            setTransaction(JSON.parse(JSON.stringify(BASETRANSACTION)))
        } );
    }

    const handleCloseAccount = () => {
        if (window.confirm("Do you really want to close this account?")){
            fetch('/api/accounts/'+account.id+'/', {
                method: 'DELETE'
            }).then( () => window.location.reload() )
        }
        
    }

    return (
        <Container className="account">
            <Row>
                <Col>
            
            <h3>{account.type}</h3>
            <Button style={ { float: "right", marginLeft: "-50%" } } variant="danger" onClick={handleCloseAccount}>Close Account</Button>
            <h4>Balance: {account.balance}</h4>
            <pre style={ { "display": "none" }}>{JSON.stringify(account)}</pre> 
                </Col>
            </Row>
            <Row>
                <Col>
                <Button variant="primary" onClick={toggleTransaction}>New Transaction</Button>
                <Modal show={showTransaction} onHide={toggleTransaction}>
                    <Modal.Header closeButton>
                        Transaction:
                    </Modal.Header>
                    <Modal.Body>
                        <fieldset>
                            <legend style={ { display: "none"}}>Transaction:</legend>
                            <label>Description: <input type="text" name="description" value={transaction.description} onChange={handleDescriptionChange}/></label>
                            <label>Action: <select name="type" onChange={handleActionChange}>
                                <option selected={(transaction.action === 'Deposit')}>Deposit</option>
                                <option selected={(transaction.action === 'Withdraw')}>Withdraw</option>
                            </select></label>
                            <label>Amount:<input type="text" name="amount" value={transaction.amount} onChange={handleAmountChange} /></label>
                        </fieldset>
                    </Modal.Body>
                    <Modal.Footer>
                        <Button variant="secondary" onClick={toggleTransaction}>Close</Button>
                        <Button variant="primary" onClick={handleTransaction}>Create Transaction</Button>
                    </Modal.Footer>
                </Modal>
                
                <Table striped bordered>
                    <thead>
                        <tr><th>Description</th><th>Amount</th><th>Date</th></tr>
                    </thead>
                    <tbody>
                    { transactionlist.map((t, i) => {
                        return (<tr key={i}><td>{t.description}</td><td>{t.amount}</td><td>{t.dateCreated}</td></tr>)
                    })}
                    </tbody>
                </Table>
                </Col>
            </Row>
        </Container>
    )
}
export default Account;