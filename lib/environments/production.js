var path = require('path');
var url = require('url');
var uri =url.parse(process.env.REDISTOGO_URL);

exports.config = {
  // either http or https
  protocol: 'http',

  // hostname is important for authentication,
  // if it doesn't match the url you're serving from,
  // backpack won't work.
  hostname: 'localhost',

  // when constructing absolute urls, this port will be appended to the host
  // this can be different from the internal port if you have a proxy in front
  // of node.
  port: '3000',

  // password hashing salt
  salt: 'Mrs. Butterworth',

  //This is my cookie secret. There are many like it, but this one is mine.
  cookie_secret: process.env.COOKIE_SECRET,


  // where to cache badge images from the issued badges
  badge_path: path.join(__dirname, '../../static/_badges'),

  // database configuration
  // make sure to create a user that has full privileges to the database
  database: {
    driver: 'mongodb',
    host: '127.0.0.1',
    password: 'hello',
    database: 'honeybadger'
  },
  redis : {
    host: uri.hostname,
    port: uri.port,
    db: uri.auth.split(':')[0],
    password: uri.auth.split(':')[1]
  }

}
