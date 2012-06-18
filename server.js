
/**
 * Module dependencies.
 */

require('coffee-script');

if(typeof process.env.NODE_ENV === 'undefined')
  process.env.NODE_ENV = 'development'


if (process.env.NODE_ENV === 'development')
  process.env.HOST = 'localhost:3000'

if (process.env.NODE_ENV === 'test')
  process.env.HOST = 'localhost:3001'

var express = require('express'),
    mongodb = require('mongoose'),
    RedisStore = require('connect-redis')(express);

require('express-namespace');

var app = module.exports = express.createServer();

// Configuration

app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.set('port', 3000);
  app.set('upload_dir', __dirname + '/public/uploads/');
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.cookieParser());
  app.use(express.session({
    secret: "345678safghjksdaftyusadfgjkhasdf7y3huuhw4uyiohafsdkjlfsdalkh",
    store: new RedisStore()
  }));
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));
});

app.configure('development', function(){
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
});

app.configure('production', function(){
  app.use(express.errorHandler());
});

app.configure('test', function(){
  app.set('port', 3001);
});

// Helpers
require('./apps/helpers')(app);

// Routes
require('./apps/badges/routes')(app);
require('./apps/authentication/routes')(app);
// require('./apps/admin/routes')(app);


app.listen(app.settings.port, function(){
  console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
});
