import { defineConfig } from 'astro/config';
import mdx from "@astrojs/mdx";
import tailwindcss from "@tailwindcss/vite";

// https://astro.build/config
export default defineConfig({
  integrations: [mdx()],
  output: "static",
  base: "./",
  build: {
    format: "file",
    inlineStylesheets: "always",
    assets: "_assets"
  },
  compressHTML: true,
  vite: {
    plugins: [tailwindcss()],
    build: {
      cssMinify: true,
      minify: "esbuild",
      assetsInlineLimit: 4096
    }
  }
});