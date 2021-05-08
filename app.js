var express = require('express');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
var inmemory = require('memory-cache');

const db = require('./db')

var app = express();

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({extended: false}));
app.use(cookieParser());

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

/* GET home page. */
app.get('/', function (req, res, next) {
    res.render('index', {title: 'Express'});
});


app.get('/top10', cache(10), (req, res) => {
    author_name = req.query.author_name;
    result = {'success': false, 'statusCode': '', 'msg': '', 'results': []}
    // Check invalid names
    if (author_name !== '') {
        isValid = /([a-zA-Z]{2,}\s[a-zA-Z]{1,}'?-?[a-zA-Z]{2,}\s?([a-zA-Z]{1,})?)/.test(author_name)
        if (!isValid) {
            // Send JSON false w/ HTTP status code 401 / msg
            result.msg = "Invalid author name, please try different name"
            result.statusCode = 400
            res.status(400)
            res.json(result)
            return
        }
    }
    db.query('SELECT * FROM get_top_10_authors_by_name($1)', [author_name], (err, rows) => {
        if (err) {
            result.msg = "There is something wrong on our server, plase try it later"
            result.statusCode = 500
            res.status(500)
            res.json(result)
        }
        // Non-existent author name
        if (rows.rowCount === 0) {
            result.msg = "There is no matched author name, please try different name"
            result.statusCode = 400
            res.status(400)
            res.json(result)
        } else {
            result.success = true
            result.statusCode = 200
            result.results = rows.rows
            res.status(200)
            res.json(result)
        }
    })
});

app.listen(3000, () => {
    console.log("Listening 3000 port")
})