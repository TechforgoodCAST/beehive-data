const Grant = (props) =>
  <li className="collection-item avatar">
    <i className="material-icons circle green">insert_chart</i>
    <span className="title">{props.grant_identifier}</span>
    <p>Funder: {props.funder_identifier}</p>
    <p>Recipient: {props.recipient_identifier}</p>
    <p>Beneficiaries: {props.beneficiary}</p>
  </li>;

Grant.propTypes = {
    grant_identifier: React.PropTypes.string.isRequired,
    funder_identifier: React.PropTypes.string.isRequired,
    recipient_identifier: React.PropTypes.string.isRequired,
    beneficiary: React.PropTypes.array.isRequired,
};

export default Grant;
