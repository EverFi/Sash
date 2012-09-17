mongoose = require 'mongoose'
timestamps = require 'mongoose-timestamps'
configuration = require '../lib/configuration'
hexDigest = require('../lib/hex_digest')
Promise = require('mongoose').Promise
Schema = mongoose.Schema
db = mongoose.createConnection configuration.get('mongodb')



OrganizationSchema = new Schema({
    name: { type: String, required: true}
    origin: String
    org: String
    api_key: String
    contact: String
    hashed_password: String
    salt: String
  },
  strict: true)

OrganizationSchema.plugin(timestamps)

OrganizationSchema.virtual('password').get ->
  @password

OrganizationSchema.virtual('password').set (p)->
  @temp_pw = p
  @hashed_password = hexDigest(p)

OrganizationSchema.pre 'save', (next)->
  @api_key = genApiKey() unless @api_key?
  next()

genApiKey = ->
 "xxxxxxxxxxxxxxxx".replace /x/g, -> (Math.random()*16|0).toString(16)

OrganizationSchema.methods.assertion = ->
  assertion = {}
  assertion.name = @name
  assertion.origin = @origin if @origin?
  assertion.contact = @contact if @contact?
  assertion.org = @org if @org?
  return assertion
  

OrganizationSchema.methods.users = (callback)->
  promise = new Promise
  promise.addBack(callback) if callback
  @model('User').find organization: @id,
    promise.resolve.bind(promise)
  promise

OrganizationSchema.methods.badges = (limit, callback)->
  promise = new Promise

  if callback
    promise.addBack callback
  query = @model('Badge').where('issuer_id', @id)
  if limit
    query = query.limit(limit)
  query.exec (err, result)->
    promise.resolve(err, result)

  promise

OrganizationSchema.methods.badgeCount = (callback)->
  promise = new Promise

  if callback
    promise.addBack callback
  query = @model('Badge').count('issuer_id', @id)
  query.exec (err, result)->
    promise.resolve(err, result)

  promise



Organization = db.model 'Organization', OrganizationSchema

module.exports = Organization
