
routes = (app) ->
  app.namespace '/badges', ->
    app.get '/', (req, res) ->
      res.send 'zomg'

module.exports = routes

