# Krikey-Code Challenge:D
<pre>
Language: Node.js   
Database: PostgreSQL   
IDE: WebStorm   
Deply: Git + Docker + GCP Kubernetes
</pre>
## Part 1: SQL Challenge
### 1. Who are the first 10 authors ordered by date_of_birth?
<pre>
<code>
SELECT id, name, to_char(date_of_birth, 'yyyy-mm-dd') date_of_birth
FROM authors
ORDER BY date_of_birth
LIMIT 10;
</code>
</pre>

### 2. What is the sales total for the author named “Lorelai Gilmore”?
<pre>
<code>
SELECT a.name, SUM(c.item_price * c.quantity) total
FROM sale_items c
         JOIN books b
         JOIN authors a ON a.name = 'Lorelai Gilmore' AND a.id = b.author_id ON b.id = c.book_id
GROUP BY a.name;
</code>
</pre>

### 3. What are the top 10 performing authors, ranked by sales revenue?
<pre>
<code>
SELECT a.name
FROM sale_items c
         JOIN books b
         JOIN authors a on a.id = b.author_id ON b.id = c.book_id
GROUP BY a.id
ORDER BY SUM(c.item_price * c.quantity) DESC
LIMIT 10
</code>
</pre>

<hr/>

## Part 2A: Write an API Endpoint
<pre>
Endpoint: /top10?author_name=
</pre>

### [Conditions]
<pre>
<code>
If a client doesn't give a valid name or a matched author name   
&nbsp;&nbsp;&nbsp;&nbsp;==> 400 status code + message: "Invalid author name, please try different name"   
&nbsp;&nbsp;&nbsp;&nbsp;==> 400 status code + message: "There is no matched author name, please try a different name"   
If the system is not working well   
&nbsp;&nbsp;&nbsp;&nbsp;==> 500 status code + message: "There is something wrong on our server, please try it later"
</code>
</pre>

### [Results]
<pre>
<code>
# URL: /top10?author_name=Lorelai Gilmore
{
    "success": true,
    "statusCode": 200,
    "msg": "",
    "results": [
        {
            "name": "Lorelai Gilmore",
            "total": "$69,938,903.83"
        }
    ]
}

# URL: /top10?author_name=
{
    "success": true,
    "statusCode": 200,
    "msg": "",
    "results": [
        {
            "name": "Michael Smith",
            "total": "$132,811,314.20"
        },
        {
            "name": "Maria Garcia",
            "total": "$131,788,584.22"
        },
        ...
        {
            "name": "Lorelai Gilmore",
            "total": "$69,938,903.83"
        }
    ]
}

</code>
</pre>

## Part 2B: API Performance
<pre>
<code>
# Based on using in-memory, we could improve the retrieving speed.
var inmemory = require('memory-cache');
var cache = (duration) => {
    return (req, res, next) => {
        let key = '__krikey__' + req.originalUrl || req.url
        let cachedBody = inmemory.get(key)
        if (cachedBody) {
            result = JSON.parse(cachedBody)
            res.statusCode = result.statusCode
            res.json(result)
        } else {
            res.sendResponse = res.send
            res.send = (body) => {
                inmemory.put(key, body, duration * 1000)
                result = JSON.parse(body)
                res.statusCode = result.statusCode
                res.sendResponse(body)
            }
            next()
        }
    }
}
</code>
</pre>

### [Results]   
![plot](./img/non-cache.JPG)
![plot](./img/cache.JPG)

## Part 3: Build Docker Container and steps to deploy

<pre>
Before deploying Node web application, we need to create "Dockerfile" and "docker-compose.yml".
The reason why we have two types of Docker files is to deploy Node app and Database(PostgreSQL).
When you check in package.json, I have added the script for "migrate" which can generate test datasets into PostgreSQL.
Therefore, we only need to run "docker-compose.yml" after creating a new Docker image for Node application.

#1 "Dockerfile" command: 
<strong>docker build -t foggyoon/krikey-node-app .</strong>

#2 "docker-compose.yml" command:
<strong>docker-compose up -d</strong>

For more details about deploying, please check <strong>GCP-Kubernetes-Deploy.pdf</strong>
</pre>