mongoose = require 'mongoose'
Schema = mongoose.Schema
db = mongoose.createConnection "mongodb://localhost:27017/badges-#{process.env.NODE_ENV}"

EarnedBadgeSchema = new Schema
  badge_id:
    type: Schema.ObjectId
  issued_on: Date
  expires_on: Date
  created_at: Date
  updated_at: Date

module.exports = EarnedBadgeSchema
