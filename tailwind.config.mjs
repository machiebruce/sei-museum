/**
 * @format
 * @type {import('tailwindcss').Config}
 */

module.exports = {
  content: ["./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue,json}", "./node_modules/flowbite/**/*.js"],

  presets: [require("./src/style/theme.mjs")], // Template theme
  theme: {
    extend: {},
  },
  plugins: [require("@tailwindcss/typography"), require("@tailwindcss/container-queries")],
};
