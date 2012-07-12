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
          badge: new Badge
          badges: badges
          orgId: orgId

    #NEW
    app.get '/new', (req, res) ->
      if req.session.org_id
        orgId = req.session.org_id
      res.render "#{__dirname}/views/new",
        badge: new Badge
        orgId: orgId

    #CREATE
    # TODO: NEED TO GENERATE SLUGS: 'everfi-super-awesome-badge-1'
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
            badge: badge
            issuer: badge.issuer()

    #UPDATE
    app.put '/:id', (req, res, next) ->
      Badge.update id: req.params.id, (err, doc) ->
        next(err) if err


    #DELETE
    app.del '/:id', (req, res, next) ->
      Badge.findById req.params.id, (err, doc) ->
        doc.remove (err) ->
          if req.xhr
            res.send JSON.stringify(success: true),
              "Content-Type": "application/json"
          else
            req.flash 'info', 'Badge Destroyed!'
            res.redirect '/badges'

  app.post '/badges/issue/:id', (req, res, next) ->
    username = req.query.username
    Badge.findById req.params.id, (err, badge) ->
      next(err) if err

      User.findOrCreate username, badge.issuer_id, (err, user) ->
        user.earn badge, (err, response) ->
          next(err) if err
          res.send JSON.stringify(response),
            'content-type': 'application/json'

formatBadgeResponse = (req, res, badge) ->
  cb = req.query.callback
  assertionPromise = badge.assertion()
  if cb
    assertionPromise.on 'complete', (assertion)->
      res.send "#{cb}(#{JSON.stringify(assertion)})",
        'content-type': 'application/javascript'
  else
    res.send assertionPromise,
      'content-type': 'application/json'


module.exports = routes

