
const Database = require('better-sqlite3');
const db = new Database('local.db', { verbose: console.log });

const tables = db.prepare("SELECT name FROM sqlite_master WHERE type='table'").all();
console.log('Tables:', tables);

if (tables.some(t => t.name === 'user')) {
    const users = db.prepare("SELECT * FROM user").all();
    console.log('Users:', users);
} else {
    console.log('User table NOT found!');
}
