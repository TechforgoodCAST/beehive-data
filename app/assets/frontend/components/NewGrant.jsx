import React from 'react';

import GrantActions from '../actions/GrantActions';

export default class NewGrant extends React.Component {
    submitGrant(event) {
        event.preventDefault();
        GrantActions.submitGrant({
            grant_identifier: this.refs.grant_grant_identifier.value,
            funder_id: this.refs.grant_funder_id.value,
            recipient_id: this.refs.grant_recipient_id.value,
        });
        this.refs.grant_grant_identifier.value = '';
        this.refs.grant_funder_id.value = '';
        this.refs.grant_recipient_id.value = '';
    }

    render() {
        return (
          <div className="row">
            <form className="col s12" onSubmit={this.submitGrant.bind(this)}>
              <div className="row">
                <div className="input-field col s4">
                  <input
                    ref="grant_grant_identifier"
                    type="text" className="validate"
                  />
                  <label>Grant Identifier</label>
                </div>
                <div className="input-field col s4">
                  <input
                    ref="grant_funder_id"
                    type="text"
                    className="validate"
                  />
                  <label>Funder Identifier</label>
                </div>
                <div className="input-field col s4">
                  <input
                    ref="grant_recipient_id"
                    type="text"
                    className="validate"
                  />
                  <label>Recipient Identifier</label>
                </div>
                <button className="btn right">Add grant</button>
              </div>
            </form>
          </div>
        );
    }
}