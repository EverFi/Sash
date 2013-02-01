mongoose = require 'mongoose'
Schema = mongoose.Schema
configuration = require '../lib/configuration'
db = mongoose.createConnection configuration.get('mongodb')

BadgeMetricSchema = new Schema
  moment: String
  organization: String
  badges: String
  count:
    type: String,
    default: 0

BadgeMetricSchema.methods.toJSON = ->
  organization: @organization,
  badges: @badges,
  moment: @moment,
  count: @count

BadgeMetricSchema.methods.mark = (badgeId) ->
  if !@badges
    @badges = "{}"
  badges = JSON.parse @badges
  if badgeId
    if !badges[ badgeId ]
      badges[ badgeId ] = []
    badges[ badgeId ].push Date.now()
    @badges = JSON.stringify badges
    c = parseInt @count
    c += 1
    @count = c.toString()

BadgeMetric = db.model('BadgeMetric', BadgeMetricSchema);

module.exports = BadgeMetric