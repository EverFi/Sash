authenticate = require '../middleware/authenticate'
reportUtils = require '../../lib/report_utils'
BadgeMetric = require '../../models/badge_metric'
UserMetric = require '../../models/user_metric'
object_utils = require '../../lib/object_utils'
async = require 'async'

routes = (app) ->
  app.namespace '/metrics', authenticate,->

    app.get '/raw.json', (req, res, next) ->
        res.send JSON.stringify( {} ),
           'content-type': 'application/json'

    app.get '/report.json', (req, res) ->
      formattedReport = {}
      org = req.session.org_id

      async.series [
        (callback) ->
          createdCriteria = {moment:'created', organization:org}
          UserMetric.find createdCriteria, (err, doc) ->
            if err
              callback err
            if doc.length == 1
              obj = doc[ 0 ]
              userData = getUsersCreatedReport(JSON.parse obj.users, "created")
              userData.count = parseInt obj.count
              formattedReport.createdUsers = userData
              callback null
            else
              callback null
        (callback) ->
          createdCriteria = {moment:'created', organization:org}
          BadgeMetric.find createdCriteria, (err, doc) ->
            if err
              callback err
            if doc.length == 1
              obj = doc[ 0 ]
              badgeData = getBadgesCreatedReport(JSON.parse obj.badges, "created")
              badgeData.count = parseInt obj.count
              formattedReport.createdBadges = badgeData
              callback null
            else
              callback null
        (callback) ->
          earnedCriteria = {moment:'issued', organization:org}
          BadgeMetric.find earnedCriteria, (err, doc) ->
            if err
              callback err
            if doc.length == 1
              obj = doc[ 0 ]
              badgeData = getBadgesEarnedReport(JSON.parse obj.badges, "earned")
              badgeData.count = parseInt obj.count
              formattedReport.earnedBadges = badgeData
              callback null
            else
              callback null
        ],
        (err, results) ->
          next(err) if err
          res.send formattedReport,
            'content-type': 'application/json'

    app.get '/report', (req, res) ->
      res.render "#{__dirname}/views/report",
        org: req.session.org_id

module.exports = routes

getUsersCreatedReport = (doc, type) ->
  users = {}
  users.chartData = reportUtils.generateTimePeriodData doc
  users.domId = "users-created"
  users.opts = {}
  return users

getBadgesEarnedReport = (doc, type) ->
  badges = {}
  badges.chartData = reportUtils.generateTimePeriodData doc
  badges.domId = "badges-earned"
  badges.opts = {}
  return badges

getBadgesCreatedReport = (doc) ->
  badges = {}
  badges.chartData = reportUtils.generateTimePeriodData doc
  badges.domId = "badges-created"
  badges.opts = {}
  return badges
