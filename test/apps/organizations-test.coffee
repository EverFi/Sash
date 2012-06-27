request = require 'request'
assert  = require 'assert'
app     = require '../../server.js'
Organization   = require '../../models/organization'
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

describe "organization", ->
  org = null
  before (done) ->
    # Remove existing everfi org, if any
    Organization.where(name: 'everfi').remove (e, os) ->
      # Create new everfi org
      org = new Organization(name: 'everfi')
      org.setValue('password', 'awesome')
      org.save (err, o) ->
        SessionTestHelper.login done

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
