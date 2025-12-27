#!/usr/bin/env node

/**
 * Script per convertire file ODT in file MDX per le schede delle specie
 * 
 * Uso: node scripts/odt-to-mdx.js <file.odt> [output.mdx]
 * 
 * Richiede pandoc installato: brew install pandoc (su macOS)
 */

import { execSync } from 'child_process';
import { readFileSync, writeFileSync, existsSync } from 'fs';
import { basename, extname, join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

function checkPandoc() {
  try {
    execSync('which pandoc', { stdio: 'ignore' });
    return true;
  } catch (e) {
    return false;
  }
}

function convertOdtToMarkdown(odtPath) {
  try {
    const markdown = execSync(`pandoc "${odtPath}" -t markdown`, { encoding: 'utf-8' });
    return markdown;
  } catch (error) {
    throw new Error(`Errore nella conversione con pandoc: ${error.message}`);
  }
}

function extractMetadata(markdown) {
  // Estrae titolo dal primo heading (qualsiasi livello #, ##, ###, ecc.)
  const titleMatch = markdown.match(/^#{1,6}\s+(.+)$/m);
  let title = titleMatch ? titleMatch[1].trim() : 'Nome specie';
  
  // Estrae nome scientifico se presente tra parentesi nel titolo
  const scientificNameMatch = title.match(/\(([^)]+)\)/);
  const scientificName = scientificNameMatch ? scientificNameMatch[1] : null;
  
  // Rimuove il nome scientifico dal titolo principale per avere solo il nome comune
  const commonName = title.replace(/\s*\([^)]+\)\s*$/, '').trim();
  
  return {
    title: commonName || title,
    scientificName: scientificName,
  };
}

function generateMDX(content, metadata, filename) {
  const baseFilename = basename(filename, extname(filename));
  
  // Genera il frontmatter base
  // Puoi personalizzare i campi in base a cosa serve per le schede delle specie
  const frontmatter = {
    layout: '../../layouts/Species.astro',
    title: metadata.title,
  };
  
  // Aggiungi nome scientifico se presente
  if (metadata.scientificName) {
    frontmatter.scientificName = metadata.scientificName;
  }
  
  // Converti frontmatter in formato YAML
  const frontmatterYaml = Object.entries(frontmatter)
    .map(([key, value]) => {
      if (typeof value === 'string' && (value.includes('\n') || value.includes(':'))) {
        return `${key}: |\n  ${value.split('\n').join('\n  ')}`;
      }
      return `${key}: ${JSON.stringify(value)}`;
    })
    .join('\n');
  
  // Pulisci il contenuto markdown (rimuovi il primo heading se già nel frontmatter)
  let cleanContent = content.replace(/^#{1,6}\s+.+$/m, '').trim();
  
  // Converti auto-link <https://...> in formato markdown [url](url) per MDX
  // MDX interpreta <https://...> come tag JSX, quindi dobbiamo convertirli
  cleanContent = cleanContent.replace(/<https?:\/\/[^>]+>/g, (match) => {
    const url = match.slice(1, -1); // Rimuove < e >
    return `[${url}](${url})`;
  });
  
  return `---
${frontmatterYaml}
---

${cleanContent}
`;
}

function main() {
  const args = process.argv.slice(2);
  
  if (args.length === 0) {
    console.error('Uso: node scripts/odt-to-mdx.js <file.odt> [output.mdx]');
    console.error('\nEsempio:');
    console.error('  node scripts/odt-to-mdx.js documenti/specie1.odt');
    console.error('  node scripts/odt-to-mdx.js documenti/specie1.odt src/pages/species/specie1.mdx');
    process.exit(1);
  }
  
  const inputFile = args[0];
  const outputFile = args[1] || join(__dirname, '../src/pages/species', basename(inputFile, extname(inputFile)) + '.mdx');
  
  // Verifica che pandoc sia installato
  if (!checkPandoc()) {
    console.error('ERRORE: pandoc non è installato.');
    console.error('Installa pandoc con: brew install pandoc (su macOS)');
    process.exit(1);
  }
  
  // Verifica che il file input esista
  if (!existsSync(inputFile)) {
    console.error(`ERRORE: File non trovato: ${inputFile}`);
    process.exit(1);
  }
  
  console.log(`Conversione di ${inputFile}...`);
  
  try {
    // Converti ODT in Markdown
    const markdown = convertOdtToMarkdown(inputFile);
    
    // Estrai metadata
    const metadata = extractMetadata(markdown);
    
    // Genera MDX
    const mdxContent = generateMDX(markdown, metadata, outputFile);
    
    // Scrivi il file
    writeFileSync(outputFile, mdxContent, 'utf-8');
    
    console.log(`✓ File creato: ${outputFile}`);
    console.log(`\nTitolo estratto: ${metadata.title}`);
    console.log('\n⚠️  Ricorda di:');
    console.log('  1. Verificare e completare il frontmatter');
    console.log('  2. Aggiungere immagini se necessarie');
    console.log('  3. Verificare il contenuto markdown');
    
  } catch (error) {
    console.error(`ERRORE: ${error.message}`);
    process.exit(1);
  }
}

main();

