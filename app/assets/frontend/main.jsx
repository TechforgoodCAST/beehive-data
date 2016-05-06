import NewGrant from './components/NewGrant';
import GrantsList from './components/GrantsList';
import GrantStore from './stores/GrantStore';

import GrantActions from './actions/GrantActions';
GrantActions.getAllGrants();

const getAppState = () => {
    const grants = { grantsList: GrantStore.getAll() };
    return grants;
};

class Main extends React.Component {
    constructor(props) {
        super(props);
        this.state = getAppState();
        this.onChange = this.onChange.bind(this);
    }

    componentDidMount() {
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
            <NewGrant />
            <GrantsList grants={this.state.grantsList} />
          </div>
        );
    }
}

const documentReady = () => {
    const reactNode = document.getElementById('app');
    if (reactNode) {
        ReactDOM.render(<Main />, reactNode);
    }
};

$(documentReady);
