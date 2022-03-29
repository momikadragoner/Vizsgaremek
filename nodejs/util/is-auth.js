const db = require('./connect-db');
const connectDb = db.connectDb;

module.exports = (req, res, next) => {
    if (!req.header('authorization')) {
        res.status(401);
        return res.json({ 'message': 'No authentication token provided' });
    }
    let authHeader = req.header('authorization')
    if (!authHeader.startsWith("Bearer ")) {
        res.status(401);
        return res.json({ 'message': 'Token prefix incorrect or missing' });
    }
    let token = authHeader.substring(7, authHeader.length);
    conn = connectDb();
    conn.query('SELECT `member_id`, `logged_in_at` FROM `session` WHERE jwt = ?',
        [token], function (err, result, fields) {
            //console.log(token);
            if (err) {
                if (err.code = 'ECONNREFUSED')
                {
                    res.status(503);
                    return res.json({ 'message': 'Connection refused by database server.' })
                }
                res.json({ 'message': err })
            } else {
                if (!result.length) {
                    res.status(401);
                    return res.json({ 'message': 'Authentication failed' });
                }
                else {
                    next();
                }
            }
        })
}