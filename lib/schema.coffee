mongoose = require 'mongoose'
Schema = mongoose.Schema

Badge = new Schema
  name: String
  created_at: Date
  updated_at: Date
  image: String
  description: String
  criteria: String
  issuer: Schema.ObjectId

User = new Schema
  login: String
  created_at: Date
  updated_at: Date

Organization = new Schema
  name: String
  origin: String
  org: String
  contact: String
  created_at: Date
  updated_at: Date

EarnedBadges = new Schema
  user_id: Schema.ObjectId
  issued_on: Date
  expires_on: Date
  created_at: Date
  updated_at: Date

module.exports =
  Badge: Badge
  User: User
  Organization: Organization
  EarnedBadges: EarnedBadges

