_ = require 'underscore'
mongoose = require 'mongoose'
Promise = mongoose.Promise
timestamps = require 'mongoose-timestamps'
Schema = mongoose.Schema
Organization = require './organization'
configuration = require '../lib/configuration'
hexDigest = require('../lib/hex_digest')
moment = require 'moment'
db = mongoose.createConnection configuration.get('mongodb')

# This is a duplicate of the Bdge schema. Dirty I know.
EarnedBadgeSchema = new Schema
  name:          String
  image:
    type: String,
  imageObj:
    type: Schema.Types.Mixed,
  description:   String
  criteria:      String
  facebook_text:      String
  twitter_text:      String
  link:      String
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
    imageObj: @imageObj,
    description: @description,
    criteria: @criteria,
    link: @link,
    twitter_text: @twitter_text,
    facebook_text: @facebook_text,
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
  email_hash: String

UserSchema.index({ email: 1, username: 1 })
UserSchema.index({ email_hash: 1})
UserSchema.index({ "badges.slug": 1 }) # Index the badge slug for issued counts
UserSchema.plugin(timestamps)

UserSchema.pre 'save', (next)->
  if @email? && !@email_hash?
    if @organization instanceof Organization
      @email_hash = hexDigest(@email, @organization.salt)
      next()
    else
      @model("Organization").findById @organization, (err, org) =>
        @email_hash = hexDigest(@email, org.salt)
        next()
  else
    next()


UserSchema.virtual('recipient').get ->
  salt = @organization.salt
  pepper = @email
  'sha256$'+hexDigest(pepper, salt)


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
    b.image = badge.imageUrl
    b.imageObj = badge.image
    delete b.issued_count
    @badges.push b
    @save (err, user)=>
      if err
        callback(err, null)
      else
        callback null, {
          message: 'successfully added badge'
          earned: true
          badge:
            # Using dot accessors here so the custom getters are invoked
            name: badge.name
            description: badge.description
            image: badge.imageUrl
            criteria: badge.criteria
            id: badge.id
        }

formatDate = (dateObj)->
  moment(dateObj).format("YYYY-MM-DD")

# Method for returning the OBI compliant assertion JSON
UserSchema.methods.assertion = (slug, callback) ->
  promise = new Promise
  promise.addBack(callback) if callback

  earned_badge = _.detect @badges, (earned_badge, i)->
    earned_badge.slug == slug

  assertion = {}
  assertion.recipient = @recipient
  assertion.issued_on = formatDate(earned_badge.issued_on)
  assertion.salt = @organization.salt

  @model('Badge').where('slug').equals(slug)
                 .populate('issuer_id').exec (err, badges) =>
    badge = badges[0]
    if badge?
      assertion.badge = {
        name: badge.name
        image: badge.image.original.defaultUrl
        version: badge.version
        description: badge.description
        criteria: badge.criteriaUrl
        issuer:
          origin: badge.issuer_id.origin
          name: badge.issuer_id.name
          org: badge.issuer_id.org
          contact: badge.issuer_id.contact
      }

      promise.resolve(err, assertion)
    else
      promise.resolve((err? ? err : new Error()), null)

  promise



User = db.model 'User', UserSchema

User.findByUsernameOrEmail = (username, email, callback)->
  promise = new Promise
  promise.addBack(callback) if callback
  if username? && email?
    User.where().or([{username: username}, {email: email}])
      .populate('organization')
      .exec (err, users)->
        promise.resolve(err, users[0])
  else if !username? && email?
    User.where('email').equals(email)
      .populate('organization')
      .exec (err, users)->
        promise.resolve(err, users[0])
  else if username? && !email?
    User.where('username').equals(username)
      .populate('organization')
      .exec (err, users)->
        promise.resolve(err, users[0])
  else
    e = new Error("Need either username or email!")
    promise.resolve(e, null)

  promise

User.findByEmailHash = (email_hash, callback) ->
  promise = new Promise
  promise.addBack(callback) if callback
  User.where('email_hash').equals(email_hash)
    .populate('organization')
    .exec (err, users)->
      promise.resolve(err, users[0])
  promise


User.findOrCreate = (username, email, options, callback)->
  issuer_id = options.issuer_id
  tags = options.tags
  User.findByUsernameOrEmail username, email, (e, user)->
    if e?
      callback(e, null)
      return
    if user?
      user.email = email if !user.email? && email?
      user.tags.merge tags if tags?
      user.save()
      callback(null, user)
    else
      user = new User username: username, email: email, organization: issuer_id
      user.tags.merge tags if tags?
      user.save (err)->
        callback(err, user)

module.exports = User



