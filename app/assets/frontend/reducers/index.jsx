import { combineReducers } from 'redux';
import grants from './grantsReducer';
import funders from './fundersReducer';

const rootReducer = combineReducers({
  grants,
  funders,
});

export default rootReducer;
