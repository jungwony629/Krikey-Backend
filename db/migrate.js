const {Client} = require('pg')
const fs = require('fs')

const migrate = async () => {
    let retries = 5
    while (retries) {
        const client = new Client({
            user: 'postgres',
            host: 'db',
            database: 'postgres',
            password: 'postgres',
            port: 5432
        });
        await client.connect().then(async () => {
            retries = 0
            readFile = fs.readFileSync('./db/DLL.sql', 'utf8');
            await client.query(readFile, (err) => {
                if (err) {
                    console.log(err)
                }
                console.log("Database Successfully initialize!")
                client.end()
            })
        }).catch(async err => {
            retries -= 1
            await new Promise(resolve => setTimeout(resolve, 5000))
            console.log(err)
        })
    }
}

migrate().then()




