import React from 'react';

const Organisation = (props) =>
  <li className="collection-item avatar">
    <i className="material-icons circle green">insert_chart</i>
    <span className="title">{props.name}</span>
    <p>No. of grants: </p>
  </li>;

Organisation.propTypes = {
    name: React.PropTypes.string.isRequired,
};

export default Organisation;
