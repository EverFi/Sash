request = require 'request'
assert  = require 'assert'
app     = require '../../server.js'
User   = require '../../models/user'

describe "users", ->

  describe "GET /users", ->
    body = null
    before (done) ->
      options =
        uri: "http://localhost:#{app.settings.port}/users"
      request options, (err, response, _body) ->
        body = _body
        done()
