mongoose = require 'mongoose'
configuration = require '../lib/configuration'
Schema  = mongoose.Schema
db      = mongoose.createConnection configuration.get('mongodb')

BadgesToUsersSchema = new Schema
  badgeId: String
  users:   [String]

BadgesToUsers = db.model('BadgesToUsers', BadgesToUsersSchema);

module.exports = BadgesToUsers;