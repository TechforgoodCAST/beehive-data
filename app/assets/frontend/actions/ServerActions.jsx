import AppDispatcher from '../dispatcher';
import ActionTypes from '../constants';

export default {
    receivedGrants(rawGrants) {
        AppDispatcher.dispatch({
            actionType: ActionTypes.RECIEVED_GRANTS,
            rawGrants,
        });
    },
    receivedOneGrant(rawGrant) {
        AppDispatcher.dispatch({
            actionType: ActionTypes.RECIEVED_ONE_GRANT,
            rawGrant,
        });
    },
    receivedOrganisations(rawOrganisations) {
        AppDispatcher.dispatch({
            actionType: ActionTypes.RECIEVED_ORGANISATIONS,
            rawOrganisations,
        });
    },
};
