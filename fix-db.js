
const Database = require('better-sqlite3');
const db = new Database('local.db', { verbose: console.log });

try {
    db.exec("ALTER TABLE users RENAME TO user;");
    console.log("Renamed users to user successfully.");
} catch (e) {
    console.log("Rename failed (maybe user already exists or users missing):", e.message);
}
