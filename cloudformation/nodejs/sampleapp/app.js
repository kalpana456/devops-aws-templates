const express = require('express')
const app = express()

const name = 'sample-app'

app.get('/status', (req, res) => {
    res.status(200).json({ status: "ok" })
})

app.get('/', (req, res) => {
    res.status(200).send('hello')
})

if (module === require.main) {
    const server = app.listen(process.env.POST || 3000, function() {
        const port = server.address().port;
        console.log(name + ' app listening on ' + port);
    })
}

module.exports = app;