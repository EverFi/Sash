// Require this file to load all the models into the 
// interactive note console

if(typeof process.env.NODE_ENV === 'undefined'){
  process.env.NODE_ENV = 'development'
}
require('coffee-script')

global.Organization = require('./models/organization')
global.Badge = require('./models/badge')
global.User = require('./models/user')
