import React from 'react';
import ReactDOM from 'react-dom';
import { Router, Route, hashHistory } from 'react-router';

import Index from './components/Index';
import OrganisationList from './components/OrganisationList';

const App = (props) =>
  <div>{props.children} </div>;

App.propTypes = {
    children: React.PropTypes.object.isRequired,
};

const documentReady = () => {
    const reactNode = document.getElementById('app');
    if (reactNode) {
        ReactDOM.render(
          <Router history={hashHistory}>
            <Route component={App}>
              <Route path="/" component={Index} />
              <Route path="/organisation" component={OrganisationList} />
            </Route>
          </Router>, reactNode);
    }
};

$(documentReady);
