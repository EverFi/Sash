Badge = require '../../models/badge'
util = require 'util'
fs = require 'fs'

routes = (app) ->
  app.namespace '/badges', ->
    #INDEX
    app.get '/', (req, res) ->
      badges = Badge.find().limit(20).run (err, badges)->
        res.render "#{__dirname}/views/index",
          stylesheet: 'admin'
          title: "Badges!"
          badge: new Badge
          badges: badges

    #NEW
    app.get '/new', (req, res) ->
      res.render "#{__dirname}/views/new",
        stylesheet: 'admin'
        title: "new badge!"
        badge: new badge

    #CREATE
    app.post '/', (req, res, next) ->
      ins = fs.createReadStream req.files.badge.image.path
      ous = fs.createWriteStream app.settings.upload_dir + req.files.badge.image.filename
      util.pump ins, ous, (err)->
        next(err) if err
        badge = new Badge req.body.badge
        badge.image = req.files.badge.image.filename
        badge.save (err, doc) ->
          next(err) if err
          req.flash 'info', 'Badge saved successfully!'
          res.redirect '/badges'

    #SHOW
    app.get '/:id', (req, res) ->
      Badge.findById req.params.id, (err, badge) ->
        res.render "#{__dirname}/views/show",
          stylesheet: 'admin'
          title: "new badge!"
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

module.exports = routes

