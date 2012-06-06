mongoose = require 'mongoose'
timestamps = require 'mongoose-timestamps'
Schema = mongoose.Schema
db = mongoose.createConnection "mongodb://localhost:27017/badges-#{process.env.NODE_ENV}"
EarnedBadge = require './earned_badge'

UserSchema = new Schema
  login: String
  created_at: Date
  updated_at: Date
  earned_badges: [EarnedBadge]

UserSchema.plugin(timestamps)

User = db.model 'User', UserSchema

module.exports = User

