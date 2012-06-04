request = require 'request'
assert  = require 'assert'
app     = require '../../server.js'

describe "badges", ->

  describe "GET /badges", ->
    body = null
    before (done) ->
      options =
        uri: "http://localhost:#{app.settings.port}/badges"
      request options, (err, response, _body) ->
        body = _body
        done()
    it "has a h1 with a nice title", ->
      assert.hasTag body, "//body/h1", "Badges!"

    it "has a form to create new badges", ->
      assert.hasTag body, '//body/form/@action', "/badges/"
      assert.hasTag body, '//body/form/@method', "post"

    it "the form is multi-part (for doing uploads, silly)", ->
      assert.hasTag body, '//body/form/@enctype', "multipart/form-data"
