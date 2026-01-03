import { defineConfig } from 'astro/config';
import tailwind from "@astrojs/tailwind";
import mdx from "@astrojs/mdx";

// https://astro.build/config
export default defineConfig({
  integrations: [tailwind(), mdx()],
  site: "https://machiebruce.github.io",
  base: "/sei-museum",
  output: "static",
  build: {
    format: "preserve",
    inlineStylesheets: "auto"
  },
  prefetch: {
    prefetchAll: true,
    defaultStrategy: "viewport"
  },
  compressHTML: true,
  vite: {
    build: {
      cssMinify: true,
      minify: "esbuild",
      rollupOptions: {
        output: {
          manualChunks: undefined
        }
      }
    }
  }
});