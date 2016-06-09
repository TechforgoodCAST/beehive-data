import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import * as actions from '../../actions/actionCreators';

// import Stats from './Stats';
// import FunderList from './FunderList';
// import Endpoints from './Endpoints';
// import Chart from './Chart';
// <Stats />
// <h4>Data quality 2015</h4>
// <FunderList funders={funders} />
// <Endpoints />
// <Chart data={grants} type="bar" />

/* eslint react/prefer-stateless-function: 0 */
class HomePage extends React.Component {
  render() {
    // const { grants, funders } = this.props;
    return (
      <div>
        <h1>Beehive Data</h1>
        <h3>High quality data about charitable funding.</h3>
        <p>See <a href="http://www.beehivegiving.org" target="_blank">www.beehivegiving.org</a> for more details.</p>
      </div>
    );
  }
}

HomePage.propTypes = {
  grants: PropTypes.array.isRequired,
  funders: PropTypes.array.isRequired,
  actions: PropTypes.object.isRequired,
};

function mapStateToProps(state) {
  return {
    grants: state.grants,
    funders: state.funders,
  };
}

function mapDispatchToProps(dispatch) {
  return {
    actions: bindActionCreators(actions, dispatch),
  };
}

export default connect(mapStateToProps, mapDispatchToProps)(HomePage);
