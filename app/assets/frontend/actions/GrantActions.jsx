import * as types from './actionTypes';
import api from '../api/grantApi';

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
