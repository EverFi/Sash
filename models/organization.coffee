mongoose = require 'mongoose'
timestamps = require 'mongoose-timestamps'
Schema = mongoose.Schema
db = mongoose.createConnection "mongodb://localhost:27017/badges-#{process.env.NODE_ENV}"

OrganizationSchema = new Schema
  name: String
  origin: String
  org: String
  contact: String
  created_at: Date
  updated_at: Date

OrganizationSchema.plugin(timestamps)

Organization = db.model 'Organization', OrganizationSchema

module.exports = Organization
