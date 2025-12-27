#!/usr/bin/env node

/**
 * Script per convertire tutti i file ODT in una cartella in file MDX
 * 
 * Uso: node scripts/convert-all-odt.js [cartella]
 * 
 * Se non specificata, usa src/pages/species/
 */

import { execSync } from 'child_process';
import { readdirSync, existsSync } from 'fs';
import { join, dirname, extname, basename } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const targetDir = process.argv[2] || join(__dirname, '../src/pages/species');

console.log(`Cercando file ODT in: ${targetDir}\n`);

if (!existsSync(targetDir)) {
  console.error(`ERRORE: La cartella non esiste: ${targetDir}`);
  process.exit(1);
}

const files = readdirSync(targetDir)
  .filter(file => extname(file).toLowerCase() === '.odt')
  .map(file => join(targetDir, file));

if (files.length === 0) {
  console.log('Nessun file ODT trovato.');
  process.exit(0);
}

console.log(`Trovati ${files.length} file ODT:\n`);

for (const odtFile of files) {
  const baseName = basename(odtFile, '.odt');
  const mdxFile = join(targetDir, `${baseName}.mdx`);
  
  console.log(`Convertendo: ${basename(odtFile)}...`);
  
  try {
    execSync(`node "${join(__dirname, 'odt-to-mdx.js')}" "${odtFile}" "${mdxFile}"`, {
      stdio: 'inherit'
    });
    console.log(`✓ Completato: ${basename(mdxFile)}\n`);
  } catch (error) {
    console.error(`✗ Errore nella conversione di ${basename(odtFile)}`);
    console.error(error.message);
    console.log('');
  }
}

console.log('Conversione completata!');

