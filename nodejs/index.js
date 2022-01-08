const express = require('express');

const app = express(),
      bodyParser = require("body-parser");

const users = [];

app.use(bodyParser.json());

app.get('/api/users', (req, res) => {
  res.json(users);
});

app.post('/api/user', (req, res) => {
  const user = req.body.user;
  users.push(user);
  res.json("user addedd");
});

app.get('/', (req,res) => {
    res.send('App Works !!!!');
});

// app.get('/', (req,res) => {
//     res.sendFile(process.cwd()+"/my-app/dist/angular-nodejs-example/index.html")
// });

app.listen(3080);