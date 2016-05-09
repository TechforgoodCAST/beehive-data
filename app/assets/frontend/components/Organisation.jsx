import React from 'react';

const Organisation = (props) =>
  <li className="collection-item avatar">
    <i className="material-icons circle green">insert_chart</i>
    <span className="title">{props.name}</span>
    <p>Grants funded: {props.grant_count_as_funder}</p>
    <p>Grants received: {props.grant_count_as_recipient}</p>
  </li>;

Organisation.propTypes = {
    name: React.PropTypes.string.isRequired,
    grant_count_as_funder: React.PropTypes.number.isRequired,
    grant_count_as_recipient: React.PropTypes.number.isRequired,
};

export default Organisation;
