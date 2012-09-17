User = require '../../models/user'
util = require 'util'
fs = require 'fs'
authenticate = require '../middleware/authenticate'
_ = require 'underscore'

routes = (app) ->
  app.namespace '/users', ->

    # User Badges
    app.get '/badges.:format?', (req, res, next) ->
      username = req.query.username
      next() if !username?
      User.findOne {username: username}, (err, user) ->
        next(err) if err?
        if user?
          formatResponse req, res, user.badges
        else
          formatResponse req, res, []

    # Show newly awarded badges
    app.get '/badges/has_new_badges.:format?', (req, res, next) ->
      username = req.query.username
      User.findOne {username: username, organization: req.org.id}, (err, user) ->
        badges = _.select user.badges, (badge) -> !badge.seen

        formatResponse req, res, {has_new_badges: badges.length > 0}

    # Show newly awarded badges
    app.get '/badges/new.:format?', (req, res, next) ->
      username = req.query.username
      User.findOne {username: username, organization: req.org.id}, (err, user) ->
        badges = _.select user.badges, (badge) -> !badge.seen

        if req.xhr || req.params.format == 'json'
          formatResponse(req, res, badges)
        else
          res.render "#{__dirname}/views/new_badges",
            badges: badges,
            layout: false

    # Mark newly awarded badge as seen
    app.get '/badges/:badge_id/seen', (req, res, next) ->
      badgeId = req.params.badge_id
      username = req.query.username
      User.findOne {username: username}, (err, user) ->
        badge = _.detect user.badges, (b) -> b._id.toString() == badgeId
        badge.seen = true
        user.save ->
          formatResponse(req, res, {success: true})

  #BADGE ASSERTION
  app.get '/users/badges/:badge_slug.:format?', (req, res, next) ->
    username = req.query.username
    email = req.query.email
    User.where().or([{username: username}, {email: email}])
      .populate('organization')
      .exec (err, users)->
        user = users[0]
        if user?
          user.assertion req.params.badge_slug, (err, assertion) ->
            formatResponse(req,res,assertion)
        else
            formatResponse(req,res,{})



  # authenticated User Routes
  app.namespace '/users', authenticate, -> 
    #SHOW
    app.get '/:id', (req, res, next) ->
      User.findById req.params.id, (err, user)->
        next(err) if err
        res.render "#{__dirname}/views/show",
          user: user
          badges: user.badges


formatResponse = (req, res, data) ->
  cb = req.query.callback
  if cb
      res.send "#{cb}(#{JSON.stringify(data)})",
        'content-type': 'application/javascript'
  else
    res.send JSON.stringify(data),
      'content-type': 'application/json'

module.exports = routes
