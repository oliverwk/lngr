const webpack = require("webpack")

module.exports = {
  target: "webworker",
  entry: "./index.js",
  plugins: [
    new webpack.ProvidePlugin({
      soup: "jssoup",
    }),
  ],
}
