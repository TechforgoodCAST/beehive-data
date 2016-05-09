import React from 'react';
import { Link } from 'react-router';

import NewGrant from './NewGrant';
import GrantsList from './GrantsList';

import GrantStore from '../stores/GrantStore';
import GrantActions from '../actions/GrantActions';

const getAppState = () => {
    const grants = { grantsList: GrantStore.getAll() };
    return grants;
};

export default class Index extends React.Component {
    constructor(props) {
        super(props);
        this.state = getAppState();
        this.onChange = this.onChange.bind(this);
    }

    componentDidMount() {
        GrantActions.getAllGrants();
        GrantStore.addChangeListener(this.onChange);
    }

    componentWillUnmount() {
        GrantStore.removeChangeListener(this.onChange);
    }

    onChange() {
        this.setState(getAppState());
    }

    render() {
        return (
          <div className="container">
            <Link to="/organisation">Organisation List</Link>
            <NewGrant />
            <GrantsList grants={this.state.grantsList} />
          </div>
        );
    }
}
