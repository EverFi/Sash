_ = require 'underscore'
mongoose = require 'mongoose'
Promise = mongoose.Promise
timestamps = require 'mongoose-timestamps'
Schema = mongoose.Schema
db = mongoose.createConnection "mongodb://localhost:27017/badges-#{process.env.NODE_ENV}"
EarnedBadge = require './earned_badge'

UserSchema = new Schema
  username:
    type: String
    lowercase: true
  created_at: Date
  updated_at: Date
  organization: Schema.ObjectId
  earned_badges: [EarnedBadge]

UserSchema.plugin(timestamps)

UserSchema.methods.earn = (badge, callback)->
  unless badge.id && badge.issuer_id
    callback new Error("must pass a valid badge object")
  exists = _.any @earned_badges, (eb, i)->
    eb.badge_id.toString() == badge.id
  if exists
    callback null, {
      message: 'User already has this badge'
      earned: false
    }
  else
    @earned_badges.push {badge_id: badge.id}
    @save (err, user)->
      callback null, {
        message: 'successfully added badge'
        earned: true
        badge:
          # Using dot accessors here so the custom getters are invoked
          name: badge.name
          description: badge.description
          image: badge.image
          criteria: badge.criteria
          id: badge.id
      }

UserSchema.methods.assertion = (badgeId, callback) ->
  assertion = {}
  assertion.username = @username
  promise = new Promise
  promise.addBack(callback) if callback

  @model('Badge').findById badgeId, (err, badge)->
    console.log 'badge: %s', badge
    badge.assertion (err, badgeAssertion)->
      assertion.badge = badgeAssertion
      promise.complete(null, assertion)

  promise

User = db.model 'User', UserSchema

User.findOrCreate = (username, issuer_id, callback)->
  User.find(username: username, organization: issuer_id).limit(1).exec (err, user)->
    if user.length > 0
      callback(null, user[0])
    else
      user = new User username: username, organization: issuer_id
      user.save (err)->
        if err
          callback(err)
        else
          callback(null, user)

module.exports = User

