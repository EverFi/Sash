mongoose      = require 'mongoose'
timestamps    = require 'mongoose-timestamps'
attachments   = require 'mongoose-attachments'
moment        = require 'moment'
configuration = require '../lib/configuration'
util          = require 'util'
fs            = require 'fs'
path          = require 'path'
_             = require 'underscore'
_.str         = require 'underscore.string'
_.mixin(_.str.exports())
require 'mongoose-attachments/lib/providers/localfs'

Promise = mongoose.Promise
Schema  = mongoose.Schema
db      = mongoose.createConnection configuration.get('mongodb')

# Setup the Schema
BadgeSchema = new Schema
  name:          String
  description:   String
  criteria:      String
  version:       String
  issuer_id:
    type: Schema.ObjectId,
    ref: 'Organization'
  issued_count:
    type: String,
    default: 0
  slug :
    type: String,
    unique: true
  tags: [String]

# Setup any plugins
BadgeSchema.plugin(timestamps);

attachmentsConfig = {
  storage: {}
  properties:
    image:
      styles:
        original:
          '$format': 'png' # OBI wants PNGs
        fullRetina:
          resize: '250x250>'
          '$format': 'png'
        fullRetinaGray:
          resize: '250x250>'
          '$format': 'png'
          'colorspace': 'Gray'
        full:
          resize: '125x125>'
          '$format': 'png'
        fullGray:
          resize: '125x125>'
          '$format': 'png'
          'colorspace': 'Gray'          
        mini:
          resize: '27x27>'
          '$format': 'png'
        miniGray:
          resize: '27x27>'
          '$format': 'png'
          'colorspace': 'Gray'
        miniRetina:
          resize: '52x52>'
          '$format': 'png'
        miniRetinaGray:
          resize: '52x52>'
          '$format': 'png'
          'colorspace': 'Gray'

}

if configuration.usingS3()
  console.log "Using S3 for Badge images"
  attachmentsConfig.storage = {
    providerName: 's3'
    options:
      key: process.env.S3_KEY
      secret: process.env.S3_SECRET
      bucket: process.env.S3_BUCKET
  }
  attachmentsConfig.directory = 'badge-images'
else
  console.log "Using local filesystem for Badge images"
  attachmentsConfig.storage = {
    providerName: 'fs'
    options: '/Users/jobin2/codez/Sash/public/uploads1'
  }
  attachmentsConfig.directory = configuration.get('upload_dir');

BadgeSchema.plugin attachments, attachmentsConfig

BadgeSchema.virtual('slugUrl').get ->
  "http://#{process.env.HOST}/badges/issue/#{@slug}"

BadgeSchema.virtual('unearnedImageUrl').get ->
  if configuration.usingS3()
    @image.fullGray.defaultUrl
  else
    dir = path.resolve('./') + '/public'
    @image.fullGray.defaultUrl.replace dir, ''

BadgeSchema.virtual('imageUrl').get ->
  if configuration.usingS3()
    @image.full.defaultUrl
  else
    dir = path.resolve('./') + '/public'
    @image.full.defaultUrl.replace dir, ''

BadgeSchema.virtual('criteriaUrl').get ->
  "http://#{configuration.get('hostname')}/badges/#{@slug}/criteria"

BadgeSchema.pre 'save', (next)->
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
  assertion.unearnedImage = @unearnedImageUrl
  assertion.description = @description if @description?
  assertion.criteria = @criteria if @criteria?
  assertion.version = @version if @version?

  @issuer (err, issuer) ->
    assertion.issuer = issuer.assertion()
    promise.resolve(err, assertion)

  return promise


Badge = db.model("Badge", BadgeSchema)

module.exports = Badge

