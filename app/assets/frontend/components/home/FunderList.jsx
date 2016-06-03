import React, { PropTypes } from 'react';
import FunderListItem from './FunderListItem';

const FunderList = ({ funders }) =>
  <div>
    {funders.map(funder =>
      <FunderListItem key={funder.organisation_identifier} funder={funder} />
    )}
  </div>;

FunderList.propTypes = {
  funders: PropTypes.array.isRequired,
};

export default FunderList;
