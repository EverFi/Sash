mongoose = require 'mongoose'
timestamps = require 'mongoose-timestamps'
Badge = require './badge'
User = require './user'

crypto = require 'crypto'

hexDigest = (string)->
  sha = crypto.createHash('sha256');
  sha.update('awesome')
  sha.digest('hex')

Schema = mongoose.Schema
db = mongoose.createConnection "mongodb://localhost:27017/badges-#{process.env.NODE_ENV}"

OrganizationSchema = new Schema {
    name: String
    origin: String
    org: String
    api_key: String
    contact: String
    hashed_password: String
    created_at: Date
    updated_at: Date
  },
  strict: true

OrganizationSchema.plugin(timestamps)

OrganizationSchema.virtual('password')

OrganizationSchema.pre 'save', (next)->
  if @password
    @hashed_password = hexDigest(@password)
  next()

OrganizationSchema.methods.badges = (callback)->
  Badge.find {'issuer': @id}, (err, bs) ->
    callback(err, bs)

OrganizationSchema.methods.badgesCount = (callback)->
  @badges (err, badges)->
    callback err, badges.length

OrganizationSchema.methods.users = (callback)->
  User.find {organization: @id}, (err, users) ->
    callback err, users

OrganizationSchema.methods.usersCount = (callback)->
  @users (err, users)->
    callback err, users.length

Organization = db.model 'Organization', OrganizationSchema

module.exports = Organization
