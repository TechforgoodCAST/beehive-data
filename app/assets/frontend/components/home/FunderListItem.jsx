import React, { PropTypes } from 'react';

const FunderListItem = ({ grant }) =>
  <div className="ui divided items">
    <div className="item">
      <div className="image">
      </div>
      <div className="content">
        <a className="header">{grant.title}</a>
        <div className="meta">
          <span>Description</span>
        </div>
        <div className="description">
          <p>{grant.amount_awarded}</p>
        </div>
        <div className="extra">
          Additional Details
        </div>
      </div>
    </div>
  </div>;

FunderListItem.propTypes = {
  grant: PropTypes.object.isRequired,
};

export default FunderListItem;
