import React from 'react';

function Health() {

    const [frontendHealth, setFrontendHealth] = React.useState({})
    const [accountHealth, setAccountHealth] = React.useState({})
    const [transactionHealth, setTransactionHealth] = React.useState({})

    React.useEffect( () => {
        fetch('/health')
            .then((response) => response.json())
            .then(respJson => {
                console.log(respJson)
                setFrontendHealth(respJson);
            });
        fetch('/api/accounts/health')
            .then((response) => response.json())
            .then(respJson => {
                console.log(respJson)
                setAccountHealth(respJson);
            });
        fetch('/api/transactions/health')
            .then((response) => response.json())
            .then(respJson => {
                console.log(respJson)
                setTransactionHealth(respJson);
            });
    }, [])

    return (
        <div>
            Health stuff coming soon!
            <h3>Frontend</h3>
            <pre>{ JSON.stringify(frontendHealth, null, 2) }</pre>
            <h3>Accounts API</h3>
            <pre>{ JSON.stringify(accountHealth, null, 2) }</pre>
            <h3>Transactions API</h3>
            <pre>{ JSON.stringify(transactionHealth, null, 2) }</pre>
        </div>
    )
}
export default Health;