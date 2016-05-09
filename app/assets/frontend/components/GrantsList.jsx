import React from 'react';

import Grant from './Grant';

const GrantsList = (props) =>
  <div>
    <ul className="collection">
      {props.grants.map(grant => <Grant key={grant.grant_identifier} {...grant} />)}
    </ul>
  </div>;

GrantsList.propTypes = {
    grants: React.PropTypes.array.isRequired,
};

export default GrantsList;
