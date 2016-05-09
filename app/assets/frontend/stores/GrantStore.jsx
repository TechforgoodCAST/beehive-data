import AppDispatcher from '../dispatcher';
import ActionTypes from '../constants';
import AppEventEmitter from './AppEventEmitter';

let grants = [];

class GrantEventEmmiter extends AppEventEmitter {
    getAll() {
        return grants;
    }
}

const GrantStore = new GrantEventEmmiter();

AppDispatcher.register(action => {
    switch (action.actionType) {
    case ActionTypes.RECIEVED_GRANTS:
        grants = action.rawGrants;
        GrantStore.emitChange();
        break;
    case ActionTypes.RECIEVED_ONE_GRANT:
        grants.unshift(action.rawGrant);
        GrantStore.emitChange();
        break;
    default:
    }
});

export default GrantStore;
