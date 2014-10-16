mongoose = require 'mongoose'
configuration = require '../lib/configuration'
Schema  = mongoose.Schema

BadgesToUsersSchema = new Schema
  badgeId: String
  users:   [String]

BadgesToUsers = mongoose.model('BadgesToUsers', BadgesToUsersSchema);

module.exports = BadgesToUsers;