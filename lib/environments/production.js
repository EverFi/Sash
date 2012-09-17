var path = require('path');
var url = require('url');
var uri =url.parse(process.env.REDISTOGO_URL);

exports.config = {
  // Important, used to generate the URLS in the badge assertions
  hostname: process.env.HOSTNAME,

  // when constructing absolute urls, this port will be appended to the host
  // this can be different from the internal port if you have a proxy in front
  // of node.
  port: process.env.PORT,

  // password hashing salt
  salt: process.env.PASSWORD_SALT,

  //This is my cookie secret. There are many like it, but this one is mine.
  cookie_secret: process.env.COOKIE_SECRET,

  // where to cache badge images from the issued badges
  badge_path: path.join(__dirname, '../../static/_badges'),

  // database configuration
  mongodb: process.env.MONGOHQ_URL,

  //Redis Config (For Session Store)
  redis : {
    host: uri.hostname,
    port: uri.port,
    db: uri.auth.split(':')[0],
    pass: uri.auth.split(':')[1]
  }

}
