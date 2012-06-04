mongoose = require 'mongoose'
Schema = mongoose.Schema
db = mongoose.createConnection 'mongodb://localhost:27017/badges'
EarnedBadge = require './earned_badge'

UserSchema = new Schema
  login: String
  created_at: Date
  updated_at: Date
  earned_badges: [EarnedBadge]

User = db.model 'User', UserSchema

module.exports = User

