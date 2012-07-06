request = require 'request'
assert  = require 'assert'
app     = require '../../server.js'
Organization   = require '../../models/organization'
User   = require '../../models/user'
SessionHelper = require '../session-helper'

describe "organization", ->
  org = null
  before (done) ->
    SessionHelper.setupOrg (organization)->
      org = organization
      done()

  describe "GET /dasboard", ->
    body = null

    before (done) ->
      u1 = new User(username: 'bob', organization: org.id)
      u2 = new User(username: 'alice', organization: org.id)
      u1.save (err, u) ->
        u2.save (e, u) ->
          options = uri: "http://localhost:#{app.settings.port}/dashboard"
          request options, (err, response, _body) ->
            body = _body
            done()

    # it 'has the orgs badges count'

    it 'has the users count', ->
        assert.match body, 'You have 2 Users'
