
/**
 * Module dependencies.
 */

// require('nodetime').profile()


require('coffee-script');

// var memwatch = require('memwatch');
// memwatch.on('leak', function(info) {
//   console.log("Memory Leak Info: ", info);
// });
// memwatch.on('stats', function(stats) {
//   console.log("Memory Leak Stats: ", stats);
// });

if(typeof process.env.NODE_ENV === 'undefined')
  process.env.NODE_ENV = 'development'



if (process.env.NODE_ENV === 'development')
  process.env.PORT = 3000
  process.env.HOST = 'localhost:'+process.env.PORT

if (process.env.NODE_ENV === 'test')
  process.env.PORT = 3001
  process.env.HOST = 'localhost:'+process.env.PORT

var express = require('express'),
    mongodb = require('mongoose'),
    expressMongoose = require('express-mongoose'),
    RedisStore = require('connect-redis')(express),
    configuration = require('./lib/configuration');

require('express-namespace');

var app = module.exports = express.createServer();

// Configuration

redisConfig = configuration.get('redis');
console.log(redisConfig);
app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.set('port', process.env.PORT);
  app.set('upload_dir', __dirname + '/public/uploads/');
  if (process.env.NODE_ENV === 'development'){
    app.use(express.logger());
  }
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.cookieParser());
  app.use(express.session({
    secret: configuration.get('cookie_secret'),
    store: new RedisStore(redisConfig)
  }));

  // app.use(startHeapSnapshot);
  app.use(app.router);
  // app.use(endHeapSnapshot);
  app.use(express.static(__dirname + '/public'));
});

// var hd;
// function startHeapSnapshot(req, res, next){
//   if(req.url.match(/stylesheets|javascripts|fonts|images|favicon/)) return next();
//   hd = new memwatch.HeapDiff();
//   next();
// }

// function endHeapSnapshot(req, res, next){
//   if(req.url.match(/stylesheets|javascripts|fonts|images|favicon/)) return next();
//   var diff = hd.end();
//   console.log("Heap Diff: URL: ("+req.url+") ", diff);
//   next();
// }

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
require('./apps/organizations/routes')(app);
require('./apps/users/routes')(app);
require('./apps/authentication/routes')(app);
require('./apps/static/routes')(app);


app.listen(app.settings.port, function(){
  console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
});
