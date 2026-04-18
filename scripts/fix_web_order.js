const fs = require('fs');
let c = fs.readFileSync('src/app/admin/orders/[id]/page.tsx', 'utf-8');
c = c.replace(
    '<span className="font-medium">{order.id}</span>',
    '<span className="font-medium">{order.id}</span>\n                        </div>\n                        <div className="flex justify-between">\n                            <span className="text-muted-foreground">Shop:</span>\n                            <span className="font-medium">{order.shopName || "Unknown"}</span>\n                        </div>\n                        <div className="flex justify-between">\n                            <span className="text-muted-foreground">Owner:</span>\n                            <span className="font-medium">{order.shopOwner || "Unknown"}</span>'
);
fs.writeFileSync('src/app/admin/orders/[id]/page.tsx', c);
