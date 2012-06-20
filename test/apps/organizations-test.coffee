request = require 'request'
assert  = require 'assert'
app     = require '../../server.js'
Organization   = require '../../models/organization'

describe "organization", ->
  describe "GET /dasboard", ->
    body = null
    before (done) ->
      options =
        uri: "http://localhost:#{app.settings.port}/dashboard"
      request options, (err, response, _body) ->
        body = _body
        done()
    it 'has the users count'
    it 'has the orgs badges count'
