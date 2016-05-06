export default class NewGrant extends React.Component {
    submitGrant(event) {
        event.preventDefault();
        this.props.submitGrant({
            grant_identifier: this.refs.grant_grant_identifier.value,
            funder_identifier: this.refs.grant_funder_identifier.value,
            recipient_identifier: this.refs.grant_recipient_identifier.value,
        });
        this.refs.grantgrant_identifier.value = '';
        this.refs.grantfunder_identifier.value = '';
        this.refs.grantrecipient_identifier.value = '';
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
                    ref="grant_funder_identifier"
                    type="text"
                    className="validate"
                  />
                  <label>Funder Identifier</label>
                </div>
                <div className="input-field col s4">
                  <input
                    ref="grant_recipient_identifier"
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

NewGrant.propTypes = {
    submitGrant: React.PropTypes.func.isRequired,
};
