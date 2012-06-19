mongoose = require 'mongoose'
timestamps = require 'mongoose-timestamps'
Badge = require './badge'

Schema = mongoose.Schema
db = mongoose.createConnection "mongodb://localhost:27017/badges-#{process.env.NODE_ENV}"

OrganizationSchema = new Schema
  name: String
  origin: String
  org: String
  api_key: String
  contact: String
  created_at: Date
  updated_at: Date

OrganizationSchema.plugin(timestamps)

OrganizationSchema.methods.badges = (callback)->
  Badge.find {issuer: @id}, (err, badges) ->
    callback err, badges


Organization = db.model 'Organization', OrganizationSchema

module.exports = Organization
