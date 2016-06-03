import * as types from '../actions/actionTypes';

export default function fundersReducer(state = [], action) {
  switch (action.type) {
    case types.LOAD_FUNDERS_SUCCESS:
      return action.funders;
    default:
      return state;
  }
}
