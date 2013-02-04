mongoose = require 'mongoose'
Schema = mongoose.Schema
configuration = require '../lib/configuration'
db = mongoose.createConnection configuration.get('mongodb')

MetricsSchema = new Schema
  usersCreated: Number
  badgesCreated: Number
  badgesEarned: Number

module.exports = MetricsSchema