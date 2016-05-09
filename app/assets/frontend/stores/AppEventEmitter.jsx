import EventEmmiter from 'events';

const CHANGE_EVENT = 'CHANGED';

export default class AppEventEmmiter extends EventEmmiter {
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
