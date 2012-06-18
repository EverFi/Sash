request = require 'request'
assert  = require 'assert'
app     = require '../../server.js'
Badge   = require '../../models/badge'

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

  describe "GET /badge/:id", ->
    body = null

    before (done) ->
      badge = new Badge
        name: "Awesome Badge"
        image: 'mario_badge.png'
        description: 'Interesting Description'

      badge.save ->

      options =
        uri: "http://localhost:#{app.settings.port}/badges/#{badge.id}"
      request options, (err, response, _body) ->
        body = _body
        done()

    it "displays the name of the badge", ->
      assert.hasTag body, '//body/div[@class="badge"]/h1',
        'Awesome Badge'

    it 'displays the description', ->
      assert.hasTag body, '//body/div[@class="badge"]/p',
        'Interesting Description'

    it 'displays the uploaded image', ->
      assert.hasTag body, '//body/div[@class="badge"]/img/@src',
        '/uploads/mario_badge.png'

  describe "POST /badges", ->
    body = null

    before (done) ->
      options =
        uri: "http://localhost:#{app.settings.port}/badges"
        method: 'post'
      request options, (err, response, _body) ->
        body = _body
        done()
    it "creates new badges with name and description", ->

  describe "GET /badges/issue/", ->
    it "initializes a user if they don't exist"
    it "stores and earned badge on the user"
    it "returns the badge info"


