import AppDispatcher from '../dispatcher';
import ActionTypes from '../constants';
import AppEventEmitter from './AppEventEmitter';

let organisations = [];

class OrganisationEventEmmiter extends AppEventEmitter {
    getAll() {
        return organisations;
    }
}

const OrganisationStore = new OrganisationEventEmmiter();

AppDispatcher.register(action => {
    switch (action.actionType) {
    case ActionTypes.RECIEVED_ORGANISATIONS:
        organisations = action.rawOrganisations;
        OrganisationStore.emitChange();
        break;
    // case ActionTypes.RECIEVED_ONE_GRANT:
    //     organisations.unshift(action.rawGrant);
    //     OrganisationStore.emitChange();
    //     break;
    default:
    }
});

export default OrganisationStore;
