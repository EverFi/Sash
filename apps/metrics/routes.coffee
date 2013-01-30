authenticate = require '../middleware/authenticate'

routes = (app, report) ->
  app.namespace '/metrics', authenticate,->

    app.get '/', (req, res, next) ->
        res.send JSON.stringify( report.summary() ),
           'content-type': 'application/json'

    app.get '/report', (req, res) ->
      res.render "#{__dirname}/views/report",
      org: req.session.org_id

module.exports = routes