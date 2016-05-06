import API from '../API';

export default {
    getAllGrants() {
        API.getAllGrants();
    },
    submitGrant(formData) {
        API.createGrant(formData);
    },
};
