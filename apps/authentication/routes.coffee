Organization = require '../../models/organization'
configuration = require '../../lib/configuration'
hexDigest = require('../../lib/hex_digest')

checkOrgs = (req,res,next)->
  Organization.find {}, (err, orgs) ->
    if orgs.length > 0
      next()
    else
      req.flash 'info', 'Looks like you need to setup an organization. Lets do that now!'
      res.redirect('/organizations/new')

routes = (app, metricsReport) ->

  app.get '/login', checkOrgs, (req, res) ->
    res.render "#{__dirname}/views/login",
      title: 'Login',
      stylesheet: 'login'

  app.post '/sessions', (req, res, next) ->
    errMsg = "Org Name or Password is invalid. Try again"
    if req.body.name and req.body.password
      Organization.findOne name: req.body.name, (err, org) ->
        if org?.hashed_password == hexDigest(req.body.password)
          req.session.org_id = org.id
          req.flash 'info', "You are logged in as #{org.name}"
          res.redirect '/dashboard'
        else
          req.flash 'error', errMsg
          res.redirect '/login'
    else
      req.flash 'error', errMsg
      res.redirect '/login'

  app.get '/logout', (req, res) ->
    req.session.regenerate (err) ->
      req.flash 'info', 'You have been logged out.'
      res.redirect '/login'
  app.del '/sessions', (req, res) ->
    req.session.regenerate (err) ->
      req.flash 'info', 'You have been logged out.'
      res.redirect '/login'

module.exports = routes

