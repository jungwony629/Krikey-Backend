const {Pool} = require('pg')
const pool = new Pool({
    host: 'db',
    user: 'postgres',
    database: 'postgres',
    password: 'postgres',
    port: 5432,
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
});

module.exports = {
    query: (text, params, callback) => {
        return pool.query(text, params, callback)
    },
}