var mysql = require('mysql');

exports.connectDb = () => {
    var connection = mysql.createConnection({
        host: 'localhost',
        user: 'root',
        password: '',
        database: 'agora-webshop',
        connectionLimit: 20
    });
    connection.connect();
    return connection;
}