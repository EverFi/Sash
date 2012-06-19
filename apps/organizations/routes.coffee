Organization = require '../../models/organization'
util = require 'util'
fs = require 'fs'

authenticateOrg = (req, res, next) ->
  Organization.find {}, (err, orgs)->
    if orgs[0]
      req.org = orgs[0]
      next()
    else
      # Should do a redirect
      next(new Error("Unauthorized"))
  
routes = (app) ->
  app.get '/', (req, res, next) ->
    res.render "index",
      title: "Badges!"

  app.get '/dashboard', authenticateOrg, (req, res, next) ->
    res.render "#{__dirname}/views/dashboard",
      title: "Badges!"
      org: req.org

  app.namespace '/organizations', ->

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
