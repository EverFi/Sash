User = require '../../models/user'
util = require 'util'
fs = require 'fs'
authenticate = require '../middleware/authenticate'
_ = require 'underscore'

routes = (app) ->
  #authenticated User Routes
  app.namespace '/users', authenticate, ->

    #INDEX
    app.get '/', (req, res) ->

    #NEW
    app.get '/new', (req, res) ->

    #CREATE
    app.post '/', (req, res, next) ->

    #SHOW
    app.get '/:id', (req, res, next) ->
      User.findById req.params.id, (err, user)->
        next(err) if err
      res.render "#{__dirname}/views/show",
        badges: user.badges()

    #UPDATE
    app.put '/:id', (req, res, next) ->

    #DELETE
    app.del '/:id', (req, res, next) ->

    app.get '/:id/badges', (req, res, next) ->
      User.findById req.params.id, (err, user) ->
        user.assertion req.params.badge_id, (assertion) ->
          res.send assertion,
            'content-type': 'appplication/json'

  # Not authenticated User routes
  app.namespace '/users', ->

    # Show newly awarded badges
    app.get '/:id/badges/has_new_badges.:format?', (req, res, next) ->
      User.findById req.params.id, (err, user) ->
        badges = _.select user.badges, (badge) ->
          badge.seen == false

        formatResponse req, res, {has_new_badges: badges.length > 0}

    # Show newly awarded badges
    app.get '/:id/badges/new.:format?', (req, res, next) ->
      User.findById req.params.id, (err, user) ->
        badges = _.select user.badges, (badge) ->
          badge.seen == false

        if req.xhr || req.params.format == 'json'
          formatResponse(req, res, badges)
        else
          res.render "#{__dirname}/views/new_badges",
            badges: badges,
            layout: false

    # Mark newly awarded badge as seen
    app.get '/:id/badges/:badge_id/seen', (req, res, next) ->
      badgeId = req.params.badge_id
      User.findById req.params.id, (err, user) ->
        badge = _.detect user.badges, (b) -> b._id.toString() == badgeId
        badge.seen = true
        user.save ->
          formatResponse(req, res, {success: true})

    #BADGE ASSERTION
    app.get '/:id/badges/:badge_id', (req, res, next) ->
      User.findById req.params.id, (err, user) ->
        user.assertion req.params.badge_id, (assertion) ->
          res.send assertion,
            'content-type': 'appplication/json'


formatResponse = (req, res, data) ->
  cb = req.query.callback
  if cb
      res.send "#{cb}(#{JSON.stringify(data)})",
        'content-type': 'application/javascript'
  else
    res.send JSON.stringify(data),
      'content-type': 'application/json'

module.exports = routes
