mongoose = require 'mongoose'
timestamps = require 'mongoose-timestamps'
Schema = mongoose.Schema
db = mongoose.createConnection "mongodb://localhost:27017/badges-#{process.env.NODE_ENV}"

BadgeSchema = new Schema
  name:         String
  image:        String
  description:  String
  criteria:     String
  issuer:       Schema.ObjectId

BadgeSchema.plugin(timestamps);

Badge = db.model("Badge", BadgeSchema)

module.exports = Badge

