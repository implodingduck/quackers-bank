import React from 'react';

function Exception() {

    const [accountHealth, setAccountHealth] = React.useState({})

    React.useEffect( () => {
        fetch('/api/accounts/exception')
            .then((response) => response.json())
            .then(respJson => {
                console.log(respJson)
                setAccountHealth(respJson)
            });
    }, [])

    return (
        <div>
            <pre>{ JSON.stringify(accountHealth, null, 2) }</pre>

        </div>
    )
}
export default Exception;