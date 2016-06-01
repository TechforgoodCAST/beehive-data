const grants = [
    {
        id: 'react-flux-building-applications',
        name: 'Building Applications in React and Flux',
        watchHref: 'http://www.pluralsight.com/courses/react-flux-building-applications',
        authorId: 'cory-house',
        length: '5:08',
        category: 'JavaScript',
    },
    {
        id: 'clean-code',
        name: 'Clean Code: Writing Code for Humans',
        watchHref: 'http://www.pluralsight.com/courses/writing-clean-code-humans',
        authorId: 'cory-house',
        length: '3:10',
        category: 'Software Practices',
    },
];

class GrantApi {
    static getAllGrants() {
        return new Promise((resolve, reject) => {
            resolve(Object.assign([], grants));
        });
    }
}

export default GrantApi;
