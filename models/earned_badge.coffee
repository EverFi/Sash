mongoose = require 'mongoose'
Schema = mongoose.Schema
db = mongoose.createConnection 'mongodb://localhost:27017/badges'

EarnedBadgeSchema = new Schema
  user_id: Schema.ObjectId
  issued_on: Date
  expires_on: Date
  created_at: Date
  updated_at: Date

EarnedBadge = db.model 'EarnedBadge', EarnedBadgeSchema

module.exports = EarnedBadge
