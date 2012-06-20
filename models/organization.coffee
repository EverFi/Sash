mongoose = require 'mongoose'
timestamps = require 'mongoose-timestamps'
Badge = require './badge'
User = require './user'

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
  Badge.find {'issuer': @id}, (err, bs) ->
    callback(err, bs)

OrganizationSchema.methods.badgesCount = (callback)->
  @badges (err, badges)->
    callback err, badges.length

OrganizationSchema.methods.users = (callback)->
  User.find {'org': @id}, (err, users) ->
    callback err, users

OrganizationSchema.methods.usersCount = (callback)->
  @users (err, users)->
    callback err, users.length

Organization = db.model 'Organization', OrganizationSchema

module.exports = Organization
