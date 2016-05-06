const Grant = (props) =>
  <li className="collection-item avatar">
    <i className="material-icons circle green">insert_chart</i>
    <span className="title">{props.grantIdentifier}</span>
    <p>Funder: {props.funderIdentifier}</p>
    <p>Recipient: {props.recipientIdentifier}</p>
  </li>;

Grant.propTypes = {
    grantIdentifier: React.PropTypes.string.isRequired,
    funderIdentifier: React.PropTypes.string.isRequired,
    recipientIdentifier: React.PropTypes.string.isRequired,
};

export default Grant;
