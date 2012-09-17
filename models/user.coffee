_ = require 'underscore'
mongoose = require 'mongoose'
Promise = mongoose.Promise
timestamps = require 'mongoose-timestamps'
Schema = mongoose.Schema
configuration = require '../lib/configuration'
hexDigest = require('../lib/hex_digest')
db = mongoose.createConnection configuration.get('mongodb')

# This is a duplicate of the Bdge schema. Dirty I know.
EarnedBadgeSchema = new Schema
  name:          String
  image:
    type: String,
  description:   String
  criteria:      String
  version:       String
  issuer_id:
    type: Schema.ObjectId,
    ref: 'Organization'
  badge_id:
    type: Schema.ObjectId,
    ref: 'Badge'
  slug:
    type: String,
  tags: [String]
  issued_on: Date
  seen:
    type: Boolean
    default: false

# Must write our own toJSON to get the benefit of the getters
EarnedBadgeSchema.methods.toJSON = ->
  {
    name: @name,
    image: @image,
    description: @description,
    criteria: @criteria,
    version: @version,
    slug: @slug,
    tags: @tags,
    issued_on: @issued_on,
    seen: @seen,
    id: @id
  }


UserSchema = new Schema
  username:
    type: String
    lowercase: true
    unique: true
  email:
    type: String
    lowercase: true
  created_at: Date
  updated_at: Date
  organization:
    type: Schema.ObjectId
    ref: 'Organization'
  badges: [EarnedBadgeSchema]
  tags: [String]

UserSchema.plugin(timestamps)

UserSchema.virtual('recipient').get ->
  salt = @organization.salt
  pepper = @email
  'sha256$'+hexDigest(pepper+salt)


UserSchema.methods.earn = (badge, callback)->
  unless badge.id && badge.issuer_id
    callback new Error("must pass a valid badge object")
  exists = _.any @badges, (earned_badge, i)->
    earned_badge.id.toString() == badge.id
  if exists
    callback null, {
      message: 'User already has this badge'
      earned: false
    }
  else
    b = badge.toJSON()
    b.issued_on = new Date()
    b.badge_id = badge.id
    b.image = badge.image.original.defaultUrl
    b.issued_count = undefined
    @badges.push b
    @save (err, user)->
      badge.issued_count.$inc()
      badge.save()
      callback null, {
        message: 'successfully added badge'
        earned: true
        badge:
          # Using dot accessors here so the custom getters are invoked
          name: badge.name
          description: badge.description
          image: badge.image.original.defaultUrl
          criteria: badge.criteria
          id: badge.id
      }

UserSchema.methods.assertion = (badgeId, callback) ->
  assertion = {}
  assertion.username = @username
  promise = new Promise
  promise.addBack(callback) if callback

  @model('Badge').findById badgeId, (err, badge)->
    badge.assertion (err, badgeAssertion)->
      assertion.badge = badgeAssertion
      promise.resolve(err, assertion)
  promise



User = db.model 'User', UserSchema

User.findOrCreate = (username, email, options, callback)->
  issuer_id = options.issuer_id
  tags = options.tags
  User.where().or([{username: username}, {email: email}])
      .where('organization').equals(issuer_id).limit(1)
      .exec (err, users)->
    user = users[0]
    if user?
      user.email = email if !user.email? && email?
      user.tags.merge tags if tags?
      user.save()
      callback(null, user)
    else
      user = new User username: username, email: email, organization: issuer_id
      user.tags.merge tags if tags?
      user.save (err)->
        if err
          callback(err)
        else
          callback(null, user)

module.exports = User

