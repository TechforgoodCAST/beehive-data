import * as types from './actionTypes';
import api from './api';

export function loadGrantsSuccess(grants) {
  return { type: types.LOAD_GRANTS_SUCCESS, grants };
}
export function loadGrants() {
  return dispatch =>
      api.getAllGrants().then(grants => {
        dispatch(loadGrantsSuccess(grants));
      }).catch(error => {
        throw (error);
      });
}

export function loadFundersSuccess(funders) {
  return { type: types.LOAD_FUNDERS_SUCCESS, funders };
}
export function loadFunders() {
  return dispatch =>
      api.getAllFunders().then(funders => {
        dispatch(loadFundersSuccess(funders));
      }).catch(error => {
        throw (error);
      });
}
