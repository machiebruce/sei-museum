import { defineConfig } from 'astro/config';
import tailwind from "@astrojs/tailwind";

import mdx from "@astrojs/mdx";


// https://astro.build/config
export default defineConfig({
  integrations: [tailwind(), mdx()],
  site: "https://machiebruce.github.io",
  build: {
    // Example: Generate `page.html` instead of `page/index.html` during build.
    format: "preserve",
  },
});


