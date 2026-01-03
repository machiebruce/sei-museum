import fs from 'fs';
import path from 'path';

const distDir = './dist';

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

fixPaths(distDir);
console.log('Done!');
