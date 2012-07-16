mongoose = require 'mongoose'
moment = require 'moment'
markdown = require('discount')
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
  version:     String
  issuer_id:       Schema.ObjectId
  issued_count: { type: Number, default: 0}

BadgeSchema.pre 'save', (next)->
  if @criteria?
    @criteria = markdown.parse(@criteria, markdown.flags.autolink) 
  if @description?
    @description = markdown.parse(@description, markdown.flags.autolink) 
  next()

BadgeSchema.plugin(timestamps);

BadgeSchema.methods.issuer = (callback)->
  promise = new Promise
  promise.addBack(callback) if callback
  @model('Organization').findById @issuer_id, promise.resolve.bind(promise)
  promise

BadgeSchema.methods.display_created_at = ->
  moment(@created_at).format("MM/DD/YY")


BadgeSchema.methods.assertion = (callback)->
  promise = new Promise
  promise.addBack(callback) if callback

  assertion = {}
  assertion.name = @name
  assertion.image = @image
  assertion.description = @description if @description?
  assertion.criteria = @criteria if @criteria?
  assertion.version = @version if @version?

  @issuer (err, issuer) ->
    assertion.issuer = issuer.assertion()
    promise.resolve(err, assertion)

  return promise


Badge = db.model("Badge", BadgeSchema)

module.exports = Badge

