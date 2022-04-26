const express = require('express');
const app = express();
const path = require('path');
const cors = require('cors');
const isAuth = require('./util/is-auth');

app.use( express.urlencoded({ extended: true }));

const shopRoutes = require('./routes/shop');
const userRoutes = require('./routes/user');
const pictureRoutes = require('./routes/picture');
const authRoutes = require('./routes/auth');

app.get('/', (req, res) => {
  res.send('API Works!');
});

app.use(express.static(path.join(__dirname, 'uploads')));
app.use(cors());
app.use(express.json());

app.use('/user', authRoutes);

app.use('/api', shopRoutes);
app.use('/api', isAuth, userRoutes);
app.use('/api/picture/', isAuth, pictureRoutes);

app.listen(3080);