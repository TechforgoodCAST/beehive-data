import React, { PropTypes } from 'react';
import FunderListItem from './FunderListItem';

const FunderList = ({ grants }) =>
  <div>
    {grants.map(grant =>
      <FunderListItem key={grant.organisation_identifier} grant={grant} />
    )}
  </div>;

FunderList.propTypes = {
    grants: PropTypes.array.isRequired,
};

export default FunderList;
