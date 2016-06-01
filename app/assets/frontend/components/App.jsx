import React from 'react';

const App = (props) =>
  <div>{props.children}</div>;

App.propTypes = {
    children: React.PropTypes.object.isRequired,
};

export default App;
