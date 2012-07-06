Badge = require '../../models/badge'
User = require '../../models/user'
Organization = require '../../models/organization'
authenticate = require '../middleware/authenticate'

util = require 'util'
fs = require 'fs'


routes = (app) ->
  app.namespace '/badges', authenticate, ->
    #INDEX
    app.get '/', (req, res) ->
      if req.session.org_id
        orgId = req.session.org_id
      badges = Badge.find(issuer_id: orgId).limit(20).run (err, badges)->
        res.render "#{__dirname}/views/index",
          title: "Badges!"
          badge: new Badge
          badges: badges
          orgId: orgId

    #NEW
    app.get '/new', (req, res) ->
      if req.session.org_id
        orgId = req.session.org_id
      res.render "#{__dirname}/views/new",
        title: "new badge!"
        badge: new Badge
        orgId: orgId

    #CREATE
    app.post '/', (req, res, next) ->
      ins = fs.createReadStream req.files.badge.image.path
      ous = fs.createWriteStream app.settings.upload_dir +
        req.files.badge.image.filename
      util.pump ins, ous, (err)->
        next(err) if err
        badge = new Badge req.body.badge
        badge.image = req.files.badge.image.filename
        badge.save (err, doc) ->
          next(err) if err
          req.flash 'info', 'Badge saved successfully!'
          res.redirect '/badges'

    #SHOW
    app.get '/:id.:format?', (req, res) ->
      Badge.findById req.params.id, (err, badge) ->
        if req.params.format == 'json'
          formatBadgeResponse(req, res, badge)
        else
          res.render "#{__dirname}/views/show",
            title: "EverFi Badges Unlimited, LTD."
            badge: badge

    #UPDATE
    app.put '/:id', (req, res, next) ->
      Badge.update id: req.params.id, (err, doc) ->
        next(err) if err


    #DELETE
    app.del '/:id', (req, res, next) ->
      Badge.findById req.params.id, (err, doc) ->
        doc.remove (err) ->
          if req.xhr
            res.send JSON.stringify(success: true), "Content-Type": "application/json"
          else
            req.flash 'info', 'Badge Destroyed!'
            res.redirect '/badges'

  app.get '/badges/issue/:id', (req, res, next) ->
    username = req.query.username
    Badge.findById req.params.id, (err, badge) ->
      next(err) if err

      User.findOrCreate username, badge.issuer_id, (err, user) ->
        user.earn badge, (err, response) ->
          next(err) if err
          if response.earned
            formatIssueResponse req, res, response
          else
            formatIssueResponse req, res, response

formatIssueResponse = (req, res, response) ->
  cb = req.query.callback
  if cb
    res.send "#{cb}(#{JSON.stringify(response)})",
      'content-type': 'application/javascript'
  else
    res.send JSON.stringify(response),
      'content-type': 'application/json'

formatBadgeResponse = (req, res, badge) ->
  cb = req.query.callback
  badge =  {
    image: badge.image,
    description: badge.description,
    criteria: badge.criteria,
    name: badge.name
    issuer: badge.issuer
    id: badge.id
  }
  if cb
    res.send "#{cb}(#{JSON.stringify(badge)})",
      'content-type': 'application/javascript'
  else
    res.send JSON.stringify(badge),
      'content-type': 'application/json'




module.exports = routes

