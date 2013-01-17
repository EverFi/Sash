Organization = require '../../models/organization'
util = require 'util'
fs = require 'fs'
async = require 'async'
jade = require 'jade'
path = require 'path'
authenticate = require '../middleware/authenticate'
userJade = ''
userTemplateFile = path.resolve __dirname + '/views/templates/user.jade'

fs.readFile userTemplateFile, (err, data) ->
  userJade = data.toString()

routes = (app) ->
  #NEW
  app.get '/organizations/new', (req, res) ->
    res.render "#{__dirname}/views/new",
      title: "Sign Up"
      org: new Organization


  #CREATE
  app.post '/organizations', (req, res, next) ->
    org = new Organization req.body.org
    org.save (err, doc) ->
      next(err) if err
      req.session.org = org
      req.flash 'info', 'Organization saved and signed in successfully!'
      res.redirect '/dashboard'

  app.get '/', (req, res, next) ->
    if req.session.org_id
      res.redirect '/dashboard'
    else
      res.redirect '/login'

  app.get '/dashboard', authenticate, (req, res, next) ->
    res.render "#{__dirname}/views/dashboard",
      org: req.org
      badges: req.org.badges(10)
      badgeCount: req.org.badgeCount()

  app.get '/users/render', (req, res, next) ->
    users = req.query.users
    html = ''
    users.forEach (u) ->
      fn = jade.compile( userJade, {} );
      html += fn(u)

    res.send html,
      'content-type': 'text/html'


  app.get '/users', authenticate, (req, res, next) ->
    res.render "#{__dirname}/views/users",
      org: req.org
      users: req.org.users()


  app.namespace '/organizations', authenticate, ->

    #INDEX
    app.get '/', (req, res) ->
      res.render "#{__dirname}/views/index",



    #SHOW
    app.get '/:id', (req, res) ->
      res.render "#{__dirname}/views/show",
        org: req.org

    #edit
    app.get '/:id/edit', (req, res) ->

    #UPDATE
    app.put '/:id', (req, res, next) ->

    #DELETE
    app.del '/:id', (req, res, next) ->

module.exports = routes

filterUsername = (user, callback) ->
  console.log('---------------------------\n')
  console.log(user)
  return callback(null, user.username)
