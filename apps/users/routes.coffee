User = require '../../models/user'
util = require 'util'
fs = require 'fs'
Promise = require('mongoose').Promise
Organization = require '../../models/organization'
authenticate = require '../middleware/authenticate'
configuration = require '../../lib/configuration'
_ = require 'underscore'

routes = (app) ->
  app.namespace '/users', ->

    app.get '/username/:username', (req, res, next) ->
      username = req.params.username
      unless username?
        res.status(404).send('Not Found')
        return

      User.find {username: username}, (err, user) ->
        if err?
          next(err)
          return
        if user?
          formatResponse req, res, user

    # NEW
    app.get '/new', (req, res, next) ->
      res.render "#{__dirname}/views/new",
        orgs: allOrgs(),
        user: new User,
        url: 'http://' + configuration.get('hostname') + '/users/create-user'

    #CREATE
    app.post '/create-user', (req, res, next) ->
      Organization.findOne {name:req.body.user.organization}, (err, org) ->
        next(err) if err
        obj = {
          email: req.body.user.email,
          username: req.body.user.username,
          organization: org._id
        }
        user = new User obj
        user.save (err, doc) ->
          next(err) if err
          req.flash 'info', 'User created successfully!'
          res.redirect '/users/' + doc._id

    # User Badges
    app.get '/badges.:format?', (req, res, next) ->
      username = req.query.username
      email = req.query.email
      unless username? || email?
        res.status(404).send("Not Found")
        return

      User.findByUsernameOrEmail username, email, (err, user) ->
        if err?
          next(err)
          return
        if user?
          badges = user.badges.map (badge)->
            badge = badge.toJSON()
            badge.assertion = "http://#{configuration.get('hostname')}/users/#{user.email_hash}/badges/#{badge.slug}"
            badge
          formatResponse req, res, badges
        else
          formatResponse req, res, []

    # Show newly awarded badges
    app.get '/badges/has_new_badges.:format?', (req, res, next) ->
      username = req.query.username
      email = req.query.email
      unless username? || email?
        res.status(404).send("Not Found")
        return

      User.findByUsernameOrEmail username, email, (err, user) ->
        badges = _.select user.badges, (badge) -> !badge.seen

        formatResponse req, res, {has_new_badges: badges.length > 0}

    # Show newly awarded badges
    app.get '/badges/new.:format?', (req, res, next) ->
      username = req.query.username
      email = req.query.email
      unless username? || email?
        res.status(404).send("Not Found")
        return

      User.findByUsernameOrEmail username, email, (err, user) ->
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
      email = req.query.email
      unless username? || email?
        res.status(404).send("Not Found")
        return

      User.findByUsernameOrEmail username, email, (err, user) ->
        badge = _.detect user.badges, (b) -> b._id.toString() == badgeId
        badge.seen = true
        user.save ->
          formatResponse(req, res, {success: true})

    # Delete an Earned Badge
    app.get '/badges/:badge_slug/destroy', (req, res, next) ->
      badgeSlug = req.params.badge_slug
      username = req.query.username
      email = req.query.email
      unless username? || email?
        res.status(404).send("Not Found")
        return

      User.findByUsernameOrEmail username, email, (err, user) ->
        badge = _.detect user.badges, (b) -> b.slug == badgeSlug
        if badge? && user?
          badge.remove()
          user.save ->
            formatResponse(req, res, {success: true})
        else
          formatResponse(req, res, {success: false})

  #BADGE ASSERTION
  app.get '/users/:email_hash/badges/:badge_slug.:format?', (req, res, next) ->
    email_hash = req.params.email_hash
    User.findByEmailHash email_hash, (err, user)->
      next(err) if err?
      if user?
        user.assertion req.params.badge_slug, (err, assertion) ->
          formatResponse(req,res,assertion)
      else
          formatResponse(req,res,{})



  # authenticated User Routes
  app.namespace '/users', authenticate, ->

    app.get '/', (req, res, next) ->
      res.render "#{__dirname}/views/users"

    app.post '/delete/:id', (req, res, next) ->
      User.findById req.params.id, (err, user) ->
        next(err) if err
        username = user.username
        User.remove {_id:user._id}, (err) ->
          next(err) if err
          req.flash 'info', 'User ' + username + ' deleted successfully.'
          res.redirect '/users/'

    #SHOW
    app.get '/:id', (req, res, next) ->
      User.findById req.params.id, (err, user)->
        next(err) if err
        res.render "#{__dirname}/views/show",
          user: user,
          host: 'http://' + configuration.get('hostname'),
          org: userOrg(user.organization)
          badges: user.badges

formatResponse = (req, res, data) ->
  cb = req.query.callback
  if cb
      res.send "#{cb}(#{JSON.stringify(data)})",
        'content-type': 'application/javascript'
  else
    res.send JSON.stringify(data),
      'content-type': 'application/json'

userOrg = (id, callback) ->
  promise = new Promise
  promise.addBack(callback) if callback
  Organization.findOne {_id:id},
    promise.resolve.bind(promise)
  promise

allOrgs = (callback) ->
  promise = new Promise
  promise.addBack(callback) if callback
  Organization.find {},
    promise.resolve.bind(promise)
  promise



module.exports = routes
