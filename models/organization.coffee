mongoose = require 'mongoose'
Schema = mongoose.Schema
db = mongoose.createConnection 'mongodb://localhost:27017/badges'

OrganizationSchema = new Schema
  name: String
  origin: String
  org: String
  contact: String
  created_at: Date
  updated_at: Date

Organization = db.model 'Organization', OrganizationSchema

module.exports = Organization
