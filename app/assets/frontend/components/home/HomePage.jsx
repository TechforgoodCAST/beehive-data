import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import * as grantActions from '../../actions/grantActions';
import FunderList from './FunderList';
import Chart from './Chart';

/* eslint react/prefer-stateless-function: 0 */
class HomePage extends React.Component {
  render() {
    const { grants } = this.props;
    return (
      <div>
        <FunderList grants={grants} />
        <Chart data={grants} />
      </div>
    );
  }
}

HomePage.propTypes = {
  grants: PropTypes.array.isRequired,
  actions: PropTypes.object.isRequired,
};

function mapStateToProps(state) {
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
