mongoose = require 'mongoose'
timestamps = require 'mongoose-timestamps'
Promise = require('mongoose').Promise
Schema = mongoose.Schema
db = mongoose.createConnection "mongodb://localhost:27017/badges-#{process.env.NODE_ENV}"

crypto = require 'crypto'

hexDigest = (string)->
  sha = crypto.createHash('sha256');
  sha.update('awesome')
  sha.digest('hex')


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
    @setValue('password', null)
  next()


OrganizationSchema.methods.users = (callback)->
  promise = new Promise
  promise.addBack(callback) if callback
  @model('User').find organization: @id,
    promise.resolve.bind(promise)
  promise

OrganizationSchema.methods.badges = (callback)->
  promise = new Promise

  if callback
    promise.addBack callback
  @model('Badge').find issuer_id: @id,
    promise.resolve.bind(promise)
  promise


Organization = db.model 'Organization', OrganizationSchema

module.exports = Organization
