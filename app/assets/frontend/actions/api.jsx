class Api {
  static getAllGrants() {
    return new Promise((resolve) => {
      resolve(Object.assign([], $.get('/v1/demo/grants/2015')));
    });
  }
  static getAllFunders() {
    return new Promise((resolve) => {
      resolve(Object.assign([], $.get('/v1/demo/funders/2015')));
    });
  }
}

export default Api;
