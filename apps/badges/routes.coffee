Badge = require '../../models/badge'
util = require 'util'
fs = require 'fs'

routes = (app) ->
  app.namespace '/badges', ->
    app.get '/', (req, res) ->
      badges = Badge.find().limit(20).run (err, badges)->
        res.render "#{__dirname}/views/index",
          stylesheet: 'admin'
          title: "Badges!"
          badge: new Badge
          badges: badges

    app.get '/new', (req, res) ->
      res.render "#{__dirname}/views/new",
        stylesheet: 'admin'
        title: "New Badge!"

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

module.exports = routes

