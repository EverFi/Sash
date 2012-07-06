User = require '../../models/user'
util = require 'util'
fs = require 'fs'

routes = (app) ->
  app.namespace '/users', ->

    #INDEX
    app.get '/', (req, res) ->

    #NEW
    app.get '/new', (req, res) ->

    #CREATE
    app.post '/', (req, res, next) ->

    #SHOW
    app.get '/:id', (req, res) ->

    #UPDATE
    app.put '/:id', (req, res, next) ->

    #DELETE
    app.del '/:id', (req, res, next) ->


    #BADGE ASSERTION
    app.get '/:id/badges/:badge_id', (req, res, next) ->
      User.findById req.params.id, (err, user) ->
        user.assertion req.params.badge_id, (assertion) ->

          res.send assertion,
            'content-type': 'appplication/json'

module.exports = routes
