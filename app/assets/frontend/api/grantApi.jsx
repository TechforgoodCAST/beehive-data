class GrantApi {
  static getAllGrants() {
    return new Promise((resolve) => {
      resolve(Object.assign([], $.get('/v1/demo/grants/2015')));
    });
  }
}

export default GrantApi;
