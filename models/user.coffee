_ = require 'underscore'
mongoose = require 'mongoose'
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


User = db.model 'User', UserSchema

User.findOrCreateByUsername =  (username, callback)->
  User.find(username: username).limit(1).exec (err, user)->
    if user.length > 0
      callback(null, user[0])
    else
      user = new User username: username
      user.save (err)->
        if err
          callback(err)
        else
          callback(null, user)

module.exports = User

