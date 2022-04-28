const express = require('express');
const app = express();
const path = require('path');
const fs = require('fs');
const cors = require('cors');
const isAuth = require('./util/is-auth');

app.use( express.urlencoded({ extended: true }));

const shopRoutes = require('./routes/shop');
const userRoutes = require('./routes/user');
const pictureRoutes = require('./routes/picture');
const authRoutes = require('./routes/auth');

app.use(express.static(path.join(__dirname, 'uploads')));
app.use(cors());
app.use(express.json());

app.use('/user', authRoutes);
app.use('/api', shopRoutes);
app.use('/api', isAuth, userRoutes);
app.use('/api/picture/', isAuth, pictureRoutes);

app.use(function(req, res, next) {
  var accept = req.accepts('html', 'json', 'xml');
  if (accept !== 'html') {
      return next();
  }
  var ext = path.extname(req.path);
  if (ext !== '') {
      return next();
  }
  fs.createReadStream(__dirname + '/' + 'agora-angular/index.html').pipe(res);
});

app.use(express.static(__dirname + '/agora-angular'));
// app.get('*', (req, res) => res.sendFile(path.join(__dirname)));

app.listen(3080);