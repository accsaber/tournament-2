/** @type {import('postcss-load-config').Config} */
module.exports = {
  // plugins: [
  //   [require("postcss-url"), { url: "inline" }],
  //   require("tailwindcss"),
  //   require("autoprefixer"),
  //   require("postcss-nesting"),
  // ].filter(Boolean),
  plugins: {
    "postcss-url": { url: "inline" },
    tailwindcss: {},
    autoprefixer: {},
    "postcss-nesting": {},
  },
};
