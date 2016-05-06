import AppDispatcher from '../dispatcher';
import ActionTypes from '../constants';

export default {
    receivedGrants(rawGrants) {
        AppDispatcher.dispatch({
            actionType: ActionTypes.RECIEVED_GRANTS,
            rawGrants,
        });
    },
};
