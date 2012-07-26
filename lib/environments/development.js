var path = require('path');
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
  cookie_secret: '493b8654e899357562e60ff1e4a3b0ec643af4efa349289e478e85e0441052407c91597a40793518fce3df61e7fef0b49c77948bc1a2b2ec94e1744ae5df37e3',


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

}
