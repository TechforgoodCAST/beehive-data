import React from 'react';

const Endpoints = () =>
  <div>
    <h4>Example endpoints</h4>
    <p>Limited to <strong>3</strong> funders and <strong>75</strong> grants.</p>
    <ul>
      <li>/v1/demo/funders/summary</li>
      <li>/v1/demo/grants/:year</li>
      <li>/v1/demo/grants/:year/:funder</li>
      <li>/v1/demo/grants/:year/:funder/:funding_programme</li>
    </ul>
  </div>;

export default Endpoints;
