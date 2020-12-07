const { environment } = require('@rails/webpacker')

const webpack = require('webpack')

environment.plugins.prepend('Provide', new webpack.ProvidePlugin({
    Popper: ['popper.js', 'default']
}))

const config = environment.toWebpackConfig();

module.exports = environment
