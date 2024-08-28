/** @type {import('postcss-load-config').Config} */
module.exports = {
  plugins: [
    require("postcss-import"),
    require("tailwindcss"),
    require("autoprefixer"),
    require("postcss-nesting"),
    process.env.NODE_ENV == "production" && require("cssnano"),
  ].filter(Boolean),
};
