mongoose = require 'mongoose'
Promise = require('mongoose').Promise
timestamps = require 'mongoose-timestamps'
Schema = mongoose.Schema
db = mongoose.createConnection "mongodb://localhost:27017/badges-#{process.env.NODE_ENV}"

fullImageUrl = (imageUrl)->
  "http://#{process.env.HOST}/uploads/#{imageUrl}"

BadgeSchema = new Schema
  name:         String
  image:        {type: String, get: fullImageUrl}
  description:  String
  criteria:     String
  issuer_id:       Schema.ObjectId

BadgeSchema.plugin(timestamps);

BadgeSchema.methods.issuer = (callback)->
  promise = new Promise
  promise.addBack(callback) if callback
  @model('Organization').findById @issuer, promise.resolve.bind(promise)
  promise

Badge = db.model("Badge", BadgeSchema)

module.exports = Badge

