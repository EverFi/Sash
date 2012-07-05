Organization = require '../../models/organization'
util = require 'util'
fs = require 'fs'

authenticateOrg = (req, res, next) ->
  if req.session.org_id
    Organization.findById req.session.org_id, (err, org)->
      req.org = org
      req.session.org_id = org.id
      next()
  else
    res.redirect('/login')


routes = (app) ->
  app.get '/', (req, res, next) ->
    if req.session.org_id
      res.redirect '/dashboard'
    else
      res.redirect '/login'

  app.get '/dashboard', authenticateOrg, (req, res, next) ->
    res.render "#{__dirname}/views/dashboard",
      title: "Badges!"
      org: req.org
      badges: req.org.badges()
      users: req.org.users()

  app.namespace '/organizations', authenticateOrg, ->

    #INDEX
    app.get '/', (req, res) ->
      res.render "#{__dirname}/views/index",
        title: "Badges!"

    #NEW
    app.get '/new', (req, res) ->
      res.render "#{__dirname}/views/new",
        title: "Sign Up"
        org: new Organization

    #CREATE
    app.post '/', (req, res, next) ->
      org = new Organization req.body.org
      org.save (err, doc) ->
        next(err) if err
        req.session.org = org
        req.flash 'info', 'Organization saved and signed in successfully!'
        res.redirect '/dashboard'

    #SHOW
    app.get '/:id', (req, res) ->

    #EDIT
    app.get '/:id/edit', (req, res) ->

    #UPDATE
    app.put '/:id', (req, res, next) ->

    #DELETE
    app.del '/:id', (req, res, next) ->

module.exports = routes
