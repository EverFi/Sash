Organization = require '../../models/organization'
crypto = require 'crypto'
hexDigest = (string)->
  sha = crypto.createHash('sha256');
  sha.update('awesome')
  sha.digest('hex')

routes = (app) ->

  app.get '/login', (req, res) ->
    res.render "#{__dirname}/views/login",
      title: 'Login',
      stylesheet: 'login'

  app.post '/sessions', (req, res, next) ->
    errMsg = "Org Name or Password is invalid. Try again"
    if req.body.name and req.body.password
      Organization.findOne name: req.body.name, (err, org) ->
        if org and org.hashed_password == hexDigest(req.body.password)
          req.session.org_id = org.id
          req.flash 'info', "You are logged in as #{org.name}"
          res.redirect '/dashboard'
        else
          req.flash 'error', errMsg
          res.redirect '/login'
    else
      req.flash 'error', errMsg
      res.redirect '/login'

  app.del '/sessions', (req, res) ->
    req.session.regenerate (err) ->
      req.flash 'info', 'You have been logged out.'
      res.redirect '/login'

module.exports = routes
