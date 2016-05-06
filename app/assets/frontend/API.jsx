import ServerActions from './actions/ServerActions';

export default {
    getAllGrants() {
        $.get('/grants')
          .success(rawGrants => ServerActions.receivedGrants(rawGrants))
          .error(error => console.log(error));
    },
};
