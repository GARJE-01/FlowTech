const fs = require('fs');
const path = require('path');

function processDir(dir) {
    fs.readdirSync(dir, { withFileTypes: true }).forEach(f => {
        const p = path.join(dir, f.name);
        if (f.isDirectory()) {
            processDir(p);
        } else if (f.name === 'page.tsx') {
            let content = fs.readFileSync(p, 'utf-8');
            if (!content.includes('force-dynamic')) {
                fs.writeFileSync(p, 'export const dynamic = "force-dynamic";\n' + content);
                console.log('Fixed:', p);
            }
        }
    });
}
processDir('./src/app/admin');
