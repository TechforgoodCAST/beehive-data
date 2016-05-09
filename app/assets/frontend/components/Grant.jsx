const Grant = (props) =>
  <li className="collection-item avatar">
    <i className="material-icons circle green">insert_chart</i>
    <span className="title">{props.grant_identifier}</span>
    <p>Funder: {props.funder_name}</p>
    <p>Recipient: {props.recipient_name}</p>
    <p>Beneficiaries: {props.beneficiary}</p>
  </li>;

Grant.propTypes = {
    grant_identifier: React.PropTypes.string.isRequired,
    funder_name: React.PropTypes.string.isRequired,
    recipient_name: React.PropTypes.string.isRequired,
    beneficiary: React.PropTypes.array.isRequired,
};

export default Grant;
