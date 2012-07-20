fs = require 'fs'
_ = require 'underscore'

routes = (app) ->
  #DISPLAY BADGES JS with HOSTNAME SUBBED IN
  app.get '/display_badges.js', (req, res, next) ->
    host = "http://#{process.env.HOST}"
    fs.readFile './views/display_badges.js', (err, data)->
      next(err) if err?
      js = data.toString().replace /{{HOST}}/g, host
      res.send js, "content-type": "application/javascript"

module.exports = routes
