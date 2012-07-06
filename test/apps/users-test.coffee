request = require 'request'
assert  = require 'assert'
app     = require '../../server.js'
User   = require '../../models/user'

SessionTestHelper =
  login: (done)->
    options =
      uri:"http://localhost:#{app.settings.port}/sessions"
      form:
        name: 'everfi'
        password: 'awesome'
      followAllRedirects: true
    request.post options, (err, _response, _body) ->
      done()

describe "users", ->

  describe "GET /users", ->
    body = null
    before (done) ->
      options =
        uri: "http://localhost:#{app.settings.port}/users"
      request options, (err, response, _body) ->
        body = _body
        done()
