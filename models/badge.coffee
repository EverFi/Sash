mongoose = require 'mongoose'
attachments = require 'mongoose-attachments'
moment = require 'moment'
markdown = require('discount')
configuration = require '../lib/configuration'
db = mongoose.createConnection configuration.get('mongodb')

Promise = require('mongoose').Promise
timestamps = require 'mongoose-timestamps'
Schema = mongoose.Schema

_ =  require 'underscore'
_.str = require('underscore.string');
_.mixin(_.str.exports());

BadgeSchema = new Schema
  name:          String
  description:   String
  criteria:      String
  version:       String
  issuer_id:
    type: Schema.ObjectId,
    ref: 'Organization'
  issued_count:
    type: Number,
    default: 0
  slug :
    type: String,
    unique: true
  tags: [String]

BadgeSchema.plugin attachments,
  directory: 'badge-images'
  storage:
    providerName: 's3'
    options:
      key: process.env.S3_KEY
      secret: process.env.S3_SECRET
      bucket: process.env.S3_BUCKET
  properties:
    image:
      styles:
        original:
          '$format': 'png'

BadgeSchema.virtual('slugUrl').get ->
  "http://#{process.env.HOST}/badges/issue/#{@slug}"

BadgeSchema.virtual('imageUrl').get ->
  @image.original.defaultUrl

BadgeSchema.virtual('criteriaUrl').get ->
  "http://#{configuration.get('hostname')}/badges/#{@slug}/criteria"

BadgeSchema.pre 'save', (next)->
  if @criteria?
    @criteria = markdown.parse(@criteria, markdown.flags.autolink)
  if @description?
    @description = markdown.parse(@description, markdown.flags.autolink)
  if @tags.length == 1 && @tags[0].match(/,/)
    @tags = @tags[0].toLowerCase().split(',')
  next()

findAvailableSlug = (slug, object, callback) ->
  Badge.findOne slug: slug, (err, badge)->
    if badge?
      slug = slug + "_"
      object.slug = slug
      findAvailableSlug(slug, object, callback)
    else
      callback()

BadgeSchema.pre 'save', (next) ->
  # generate slug if new and has name, or is has no slug and has name
  if (@isNew && @name?) || (!@slug? && @name?)
    @slug = _.slugify(@name)
    findAvailableSlug @slug, @, next
  else
    next()

BadgeSchema.plugin(timestamps);

BadgeSchema.methods.issuer = (callback)->
  promise = new Promise
  promise.addBack(callback) if callback
  @model('Organization').findById @issuer_id, promise.resolve.bind(promise)
  promise


BadgeSchema.methods.assertion = (callback)->
  promise = new Promise
  promise.addBack(callback) if callback

  assertion = {}
  assertion.name = @name
  assertion.image = @imageUrl
  assertion.description = @description if @description?
  assertion.criteria = @criteria if @criteria?
  assertion.version = @version if @version?

  @issuer (err, issuer) ->
    assertion.issuer = issuer.assertion()
    promise.resolve(err, assertion)

  return promise


Badge = db.model("Badge", BadgeSchema)

module.exports = Badge

