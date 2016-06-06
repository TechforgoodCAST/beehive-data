import * as types from '../actions/actionTypes';

export default function grantsReducer(state = [], action) {
  switch (action.type) {
    case types.LOAD_GRANTS_SUCCESS:
      return action.grants;
    default:
      return state;
  }
}
