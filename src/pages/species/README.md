# Schede delle Specie

Questa cartella contiene le schede delle specie in formato MDX.

## Conversione da ODT a MDX

Per convertire un file ODT in MDX:

```bash
node scripts/odt-to-mdx.js <percorso/file.odt> [output.mdx]
```

**Prerequisiti:**
- Installare pandoc: `brew install pandoc` (su macOS)

**Esempio:**
```bash
# Converti un file ODT
node scripts/odt-to-mdx.js documenti/specie1.odt

# Oppure specifica il file di output
node scripts/odt-to-mdx.js documenti/specie1.odt src/pages/species/specie1.mdx
```

## Struttura del file MDX

Ogni file MDX contiene:
- Frontmatter YAML con i metadati della scheda
- Contenuto in Markdown

Il layout verrà fornito successivamente.

