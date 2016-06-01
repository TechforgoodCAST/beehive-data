import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import * as grantActions from '../../actions/grantActions';
import FunderList from './FunderList';

class HomePage extends React.Component {
    grantRow(grant, index) {
        return <div key={index}>{grant.name}</div>;
    }

    render() {
        const { grants } = this.props;

        return (
          <FunderList grants={grants} />
        );
    }
}

HomePage.propTypes = {
    grants: PropTypes.array.isRequired,
    actions: PropTypes.object.isRequired,
};

function mapStateToProps(state, ownProps) {
    return {
        grants: state.grants,
    };
}

function mapDispatchToProps(dispatch) {
    return {
        actions: bindActionCreators(grantActions, dispatch),
    };
}

export default connect(mapStateToProps, mapDispatchToProps)(HomePage);
