import fs from 'fs';
import path from 'path';

const distDir = './dist';

// Alcune pagine elenco (objects.html, species.html) condividono il nome con la
// cartella delle rispettive schede di dettaglio (objects/, species/). Su hosting
// statici come GitHub Pages questo crea un'ambiguita: il server preferisce la
// cartella e serve la pagina come se vivesse un livello piu in profondita di
// quanto i suoi percorsi relativi si aspettino, rompendo immagini e icone.
// Fondiamo qui il file nella cartella omonima come index.html: la collisione
// sparisce e il calcolo automatico della profondita in fixPaths() qui sotto
// gestisce da solo tutti i percorsi assoluti "/...".
function mergeCollidingListingPages(dir) {
  const entries = fs.readdirSync(dir);
  const dirNames = new Set(entries.filter((e) => fs.statSync(path.join(dir, e)).isDirectory()));

  for (const entry of entries) {
    if (!entry.endsWith('.html')) continue;
    const baseName = entry.slice(0, -'.html'.length);
    if (!dirNames.has(baseName)) continue;

    const srcFile = path.join(dir, entry);
    const destFile = path.join(dir, baseName, 'index.html');

    let content = fs.readFileSync(srcFile, 'utf-8');

    // Il file si sposta un livello piu in profondita: qualsiasi riferimento
    // relativo "in chiaro" (non "/...", quindi non gestito dal passaggio
    // automatico di fixPaths qui sotto) deve guadagnare un ulteriore "../"
    // per continuare a puntare allo stesso posto.
    content = content.replace(/(src|href)="(\.[^"]*)"/g, (_match, attr, value) => {
      const stripped = value.startsWith('./') ? value.slice(2) : value;
      return `${attr}="../${stripped}"`;
    });

    fs.writeFileSync(destFile, content);
    fs.unlinkSync(srcFile);
    console.log(`Merged: ${srcFile} -> ${destFile}`);
  }

  for (const name of dirNames) {
    mergeCollidingListingPages(path.join(dir, name));
  }
}

function fixPaths(dir, depth = 0) {
  const files = fs.readdirSync(dir);

  for (const file of files) {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);

    if (stat.isDirectory()) {
      fixPaths(filePath, depth + 1);
    } else if (file.endsWith('.html')) {
      let content = fs.readFileSync(filePath, 'utf-8');
      const original = content;

      // Calcola il prefisso relativo basato sulla profondità
      const prefix = depth === 0 ? './' : '../'.repeat(depth);

      // Correggi /./ che è il risultato di base: "./"
      content = content.replace(/src="\/\.\//g, `src="${prefix}`);
      content = content.replace(/href="\/\.\//g, `href="${prefix}`);

      // Correggi percorsi assoluti rimanenti
      content = content.replace(/href="\/(?!http|\/|\.)/g, `href="${prefix}`);
      content = content.replace(/src="\/(?!http|\/|\.)/g, `src="${prefix}`);

      // Pulisci percorsi malformati
      content = content.replace(/\.\/\.\//g, './');
      content = content.replace(/\.\.\/\.\//g, '../');
      content = content.replace(/href="\/\."/g, `href="${prefix}index.html"`);

      if (content !== original) {
        fs.writeFileSync(filePath, content);
        console.log(`Fixed: ${filePath}`);
      }
    }
  }
}

mergeCollidingListingPages(distDir);
fixPaths(distDir);
console.log('Done!');
