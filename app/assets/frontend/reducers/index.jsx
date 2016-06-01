import { combineReducers } from 'redux';
import grants from './grantsReducer';

const rootReducer = combineReducers({
    grants,
});

export default rootReducer;
