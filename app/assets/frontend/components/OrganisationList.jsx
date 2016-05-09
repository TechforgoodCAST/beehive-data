import React from 'react';
import { Link } from 'react-router';

import OrganisationStore from '../stores/OrganisationStore';
import OrganisationActions from '../actions/OrganisationActions';

import Organisation from './Organisation';

const getAppState = () => {
    const organisations = { organisations: OrganisationStore.getAll() };
    return organisations;
};

export default class OrganisationList extends React.Component {
    constructor(props) {
        super(props);
        this.state = getAppState();
        this.onChange = this.onChange.bind(this);
    }

    componentDidMount() {
        OrganisationActions.getAllOrganisations();
        OrganisationStore.addChangeListener(this.onChange);
    }

    componentWillUnmount() {
        OrganisationStore.removeChangeListener(this.onChange);
    }

    onChange() {
        this.setState(getAppState());
    }

    render() {
        return (
          <div>
            <h3>Organisation List</h3>
            <ul className="collection">
              {this.state.organisations.map(org => <Organisation key={org.id} {...org} />)}
            </ul>
            <Link to="/">Back</Link>
          </div>
        );
    }
}
