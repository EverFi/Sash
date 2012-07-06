app          = require '../server.js'
request      = require 'request'
Organization = require "../models/organization"

SessionHelper =
  setupOrg: (done)->
    Organization.where(name: 'everfi').remove (e, os) ->
      # Create new everfi org
      org = new Organization(name: 'everfi')
      org.setValue('password', 'awesome')
      org.save (err, o) ->
        SessionHelper.login ->
          done(org)

  login: (done)->
    options =
      uri:"http://localhost:#{app.settings.port}/sessions"
      form:
        name: 'everfi'
        password: 'awesome'
      followAllRedirects: true
    request.post options, (err, _response, _body) ->
      done()

module.exports = SessionHelper
