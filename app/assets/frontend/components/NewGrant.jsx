export default class NewGrant extends React.Component {
    submitGrant(event) {
        event.preventDefault();
        this.props.submitGrant({
            grantIdentifier: this.refs.grantGrantIdentifier.value,
            funderIdentifier: this.refs.grantFunderIdentifier.value,
            recipientIdentifier: this.refs.grantRecipientIdentifier.value,
        });
        this.refs.grantGrantIdentifier.value = '';
        this.refs.grantFunderIdentifier.value = '';
        this.refs.grantRecipientIdentifier.value = '';
    }

    render() {
        return (
          <div className="row">
            <form className="col s12" onSubmit={this.submitGrant.bind(this)}>
              <div className="row">
                <div className="input-field col s4">
                  <input
                    ref="grantGrantIdentifier"
                    type="text" className="validate"
                  />
                  <label>Grant Identifier</label>
                </div>
                <div className="input-field col s4">
                  <input
                    ref="grantFunderIdentifier"
                    type="text"
                    className="validate"
                  />
                  <label>Funder Identifier</label>
                </div>
                <div className="input-field col s4">
                  <input
                    ref="grantRecipientIdentifier"
                    type="text"
                    className="validate"
                  />
                  <label>recipient Identifier</label>
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
