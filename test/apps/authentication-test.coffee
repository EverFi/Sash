
request = require 'request'
assert  = require 'assert'
app     = require '../../server.js'

describe "authentication", ->

  describe "GET /login", ->
    body = null
    before (done) ->
      options =
        uri: "http://localhost:#{app.settings.port}/login"
      request options, (err, response, _body) ->
        body = _body
        done()

    it "has title", ->
      assert.hasTag body, '//head/title', 'Login'

