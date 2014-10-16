mongoose = require 'mongoose'
Schema = mongoose.Schema
configuration = require '../lib/configuration'

EarnedBadgeSchema = new Schema
  badge_id:
    type: Schema.ObjectId
  issued_on: Date
  expires_on: Date
  created_at: Date
  updated_at: Date

module.exports = EarnedBadgeSchema
