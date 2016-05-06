import AppDispatcher from '../dispatcher';
import ActionTypes from '../constants';
import EventEmmiter from 'events';

let grants = [];
const CHANGE_EVENT = 'CHANGED';

class GrantEventEmmiter extends EventEmmiter {
    getAll() {
        return grants;
    }
    emitChange() {
        this.emit(CHANGE_EVENT);
    }
    addChangeListener(callback) {
        this.on(CHANGE_EVENT, callback);
    }
    removeChangeListener(callback) {
        this.removeListener(CHANGE_EVENT, callback);
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
