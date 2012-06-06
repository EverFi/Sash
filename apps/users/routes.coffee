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

module.exports = routes
