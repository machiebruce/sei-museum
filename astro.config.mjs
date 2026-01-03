import { defineConfig } from 'astro/config';
import tailwind from "@astrojs/tailwind";
import mdx from "@astrojs/mdx";

// https://astro.build/config
export default defineConfig({
  integrations: [tailwind(), mdx()],
  output: "static",
  base: "./",
  build: {
    format: "file",
    inlineStylesheets: "always",
    assets: "_assets"
  },
  compressHTML: true,
  vite: {
    build: {
      cssMinify: true,
      minify: "esbuild",
      assetsInlineLimit: 4096
    }
  }
});