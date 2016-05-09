import ServerActions from './actions/ServerActions';

export default {
    getAllGrants() {
        $.get('/grants')
          .success(rawGrants => ServerActions.receivedGrants(rawGrants))
          .error(error => console.log(error));
    },
    createGrant(formData) {
        $.post('/grants', formData)
          .success(rawGrant => ServerActions.receivedOneGrant(rawGrant))
          .error(error => console.log(error));
    },
    getAllOrganisations() {
        $.get('/organisations')
          .success(rawOrganisations => ServerActions.receivedOrganisations(rawOrganisations))
          .error(error => console.log(error));
    },
};
