mongoose = require 'mongoose'
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

Badge = db.model("Badge", BadgeSchema)

module.exports = Badge

