mongoose = require 'mongoose'
timestamps = require 'mongoose-timestamps'
Schema = mongoose.Schema
db = mongoose.createConnection "mongodb://localhost:27017/badges-#{process.env.NODE_ENV}"
EarnedBadge = require './earned_badge'

UserSchema = new Schema
  username: {type: String, lowercase: true}
  created_at: Date
  updated_at: Date
  earned_badges: [EarnedBadge]

UserSchema.plugin(timestamps)

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

