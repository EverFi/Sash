// This require this file to load all the models into the 
// interactive note console

process.env.NODE_ENV = 'development'
require('coffee-script')
o = require('./models/organization')
b = require('./models/badge')
u = require('./models/user')

module.exports = {
  Badge: b,
  Organization: o, 
  User: u
}
