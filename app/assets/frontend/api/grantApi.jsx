class GrantApi {
    static getAllGrants() {
        return new Promise((resolve, reject) => {
            resolve(Object.assign([], $.get('/v1/demo/funders')));
        });
    }
}

export default GrantApi;
