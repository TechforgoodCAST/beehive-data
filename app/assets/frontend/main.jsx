import NewGrant from './components/NewGrant';
import GrantsList from './components/GrantsList';

class Main extends React.Component {
    constructor(props) {
        super(props);
        this.state = { grantsList: [] };
    }

    addGrant(grantToAdd) {
        const newGrantsList = this.state.grantsList;
        newGrantsList.unshift({ grantIdentifier: grantToAdd.grantIdentifier,
                                funderIdentifier: grantToAdd.funderIdentifier,
                                recipientIdentifier: grantToAdd.recipientIdentifier });
        this.setState({ grantsList: newGrantsList });
    }

    render() {
        return (
          <div className="container">
            <NewGrant submitGrant={this.addGrant.bind(this)} />
            <GrantsList grants={this.state.grantsList} />
          </div>
        );
    }
}

const documentReady = () => {
    ReactDOM.render(
      <Main />,
    document.getElementById('app')
  );
};

$(documentReady);
