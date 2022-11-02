import React, {Component, useState, useEffect} from 'react';
import logo from './logo.svg';
import './App.css';
import ApiTest from './ApiTest'
import Accounts from './Accounts'
import Health from './Health'
import Exception from './Exception'
import {
    BrowserRouter as Router,
    Switch,
    Route,
    Link,
    Redirect
  } from "react-router-dom";

import {Container, Row, Col, Navbar, Nav, NavDropdown, Image, Carousel, Card } from 'react-bootstrap'
import 'bootstrap/dist/css/bootstrap.min.css';
import ClassyImage from './ClassyImage'

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
            <Navbar bg="light" expand="lg" className="banner">
                <Container>
                    <Navbar.Brand href="/">Quackers Bank</Navbar.Brand>
                    <Navbar.Toggle aria-controls="basic-navbar-nav" />
                    <Navbar.Collapse id="basic-navbar-nav">
                    <Nav className="me-auto">
                        <Nav.Link href="/">Home</Nav.Link>
                        <Nav.Link href="/healthreport">Health</Nav.Link>
                        { (authUser.attributes) ? (<Nav.Link href="/accounts">Accounts</Nav.Link>) : "" }
                        { (authUser.attributes) ? (<Nav.Link href="/test">Testing</Nav.Link>) : "" }
                        { (authUser.attributes) ? (<Nav.Link href="/exception">Exception</Nav.Link>) : "" }
                        { (authUser.attributes) ? (<div className="nav-link">{ authUser.attributes.name } (<a href="/logout">Logout</a>)</div>) : (<Nav.Link href="/happylogin">Login</Nav.Link>) }
                    </Nav>
                    </Navbar.Collapse>
                </Container>
            </Navbar>
            <Container>
                <Row>
                    <Col>
                        <Router forceRefresh={true}>
                            <Switch>
                                
                                <Route path="/test">
                                    <ApiTest></ApiTest>
                                </Route>
                                <Route path="/accounts">
                                    <Accounts></Accounts>
                                </Route>
                                <Route path="/happylogin">
                                    <Redirect to="/"/>
                                </Route>
                                <Route path="/healthreport">
                                    <Health></Health>
                                </Route>
                                <Route path="/exception">
                                    <Exception></Exception>
                                </Route>
                                <Route exact path="/">
                                    <Carousel>
                                        <Carousel.Item>
                                            <ClassyImage src="/horizon_72.jpg" alt="beach scene with sand, ocean and sky" />
                                            <Carousel.Caption>
                                            <h3>Welcome!</h3>
                                            <p>Your future is on the horizon!</p>
                                            </Carousel.Caption>
                                        </Carousel.Item>
                                        <Carousel.Item>
                                            <ClassyImage src="/IMG_1206_leveled_72.jpg" alt="mountain top sun rise" />

                                            <Carousel.Caption>
                                            <h3>Rise up to the Challenge!</h3>
                                            <p></p>
                                            </Carousel.Caption>
                                        </Carousel.Item>
                                        <Carousel.Item>
                                            <ClassyImage src="/20170522_154025_72.jpg" alt="flowers on a hill overlooking a body of water" />

                                            <Carousel.Caption>
                                            <h3>Third slide label</h3>
                                            <p>Praesent commodo cursus magna, vel scelerisque nisl consectetur.</p>
                                            </Carousel.Caption>
                                        </Carousel.Item>
                                    </Carousel> 
                                    <Container className="topspacer">
                                        <Row>
                                            <Col md={{ span: 6 }}>
                                                <div className="box">
                                                    Quackers Bank is a sample application used to test and demonstrate different technologies. There is no real monetary transactions occuring within this application. Have fun playing around and hopefully you are able to learn something while you are at it. Good Luck, Have Fun and Thanks!
                                                </div>
                                            </Col>
                                            <Col md={{ span: 6 }}>
                                                <div className="box">
                                                    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce lacinia tristique metus a rhoncus. Aliquam facilisis gravida turpis, at accumsan ex egestas non. Mauris accumsan risus id iaculis cursus. Cras lectus purus, lobortis id nibh quis, ultrices ultrices ipsum. In quis blandit lacus. Vestibulum gravida, ipsum in faucibus maximus, dui tellus venenatis dolor, eu efficitur magna nibh ornare nisi. Nullam maximus consectetur nunc. Morbi sollicitudin, sapien et consectetur cursus, ipsum eros congue diam, consectetur congue ante velit sit amet erat. In consequat vulputate enim vel porttitor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam aliquet turpis quis malesuada mattis. Morbi sed lobortis nulla, a sollicitudin odio. Integer fermentum tempor nisl. Nunc lectus tortor, tempus ut risus eget, scelerisque pellentesque enim. 
                                                </div>
                                            </Col>
                                        </Row>
                                    </Container>
                                    
                                </Route>
                                <Route path="*">
                                    <Container className="topspacer">
                                        <Row>
                                            <Col>
                                                <Image src="/404_giraffe.jpg" alt="Giraffe eating a wire with the words: Derp, Sorry! Nout Found!" rounded></Image>
                                            </Col>
                                        </Row>
                                    </Container>
                                </Route>
                            </Switch>
                            
                        </Router>
                    </Col>
                </Row>
                <Row>
                    <Col className="footer">
                        <p>Built using the MIT License.</p>
                    </Col>
                </Row>
            </Container>
        </div>
    )
}

export default App;