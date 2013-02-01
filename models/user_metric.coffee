mongoose = require 'mongoose'
Schema = mongoose.Schema
configuration = require '../lib/configuration'
db = mongoose.createConnection configuration.get('mongodb')

UserMetricSchema = new Schema
  moment: String
  organization: String
  users: String
  count:
    type: String,
    default: 0

UserMetricSchema.methods.toJSON = ->
  organization: @organization,
  users: @users,
  moment: @moment,
  count: @count

UserMetricSchema.methods.mark = (userId) ->
  if !@users
    @users = "{}"
  users = JSON.parse @users
  if userId
    if !users[ userId ]
      users[ userId ] = []
    users[ userId ].push Date.now()
    @users = JSON.stringify users
    c = parseInt @count
    c += 1
    @count = c.toString()

UserMetric = db.model('UserMetric', UserMetricSchema);

module.exports = UserMetric