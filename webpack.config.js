module.exports = {
    entry: './app/assets/frontend/index.jsx',
    output: {
        path: __dirname + '/app/assets/javascripts',
        filename: 'bundle.js',
    },
    resolve: {
        extensions: ['', '.js', '.jsx'],
    },
    module: {
        loaders: [
            { test: /\.jsx$/, loader: 'babel-loader' },
        ],
    },
};
