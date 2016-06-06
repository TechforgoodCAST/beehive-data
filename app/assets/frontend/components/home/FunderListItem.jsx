import React, { PropTypes } from 'react';

const FunderListItem = ({ funder }) =>
  <div className="ui divided items">
    <div className="item">
      <div className="image">
      </div>
      <div className="content">
        <a className="header">{funder.name}</a>
        <div className="meta">
          <span>{funder.summary.grant_count} grants in {funder.year}</span>
        </div>
        <div className="description">
          <div className="ui mini statistics">
            <div className="orange statistic">
              <div className="value">
                {funder.data_quality.normal * 100}%
              </div>
              <div className="label">
                Normal
              </div>
            </div>
            <div className="olive statistic">
              <div className="value">
                {funder.data_quality.high * 100}%
              </div>
              <div className="label">
                High
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>;

FunderListItem.propTypes = {
  funder: PropTypes.object.isRequired,
};

export default FunderListItem;
