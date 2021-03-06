assert  = require 'assert'
User   = require '../../models/user'
Badge = require '../../models/badge'
Organization = require '../../models/organization'

describe 'Badge', ->
  org = null
  before (done) ->
    org = new Organization name: 'Awesome Org'
    org.save ->
      done()

  describe 'create', ->
    user = null
    before (done)->
      user = new User username: 'Bob', organization: org.id
      user.save()
      done()


    it 'downcases username on save', ->
      assert.equal user.username, 'bob'

  describe 'when finding or creating by username', ->
    user = null
    # remove all the bobs and alices beforehand
    before (done)->
      User.where('username').in(['bob','alice']).remove ->
        user = new User username: 'bob', organization: org.id
        user.save ->
          done()

    it 'it returns an existing user if exists', (done)->
      User.findOrCreate 'bob', org.id, (err, bob)->
        assert.equal bob.id, user.id
        assert.equal bob.organization, org.id
        done()

    it 'it returns a new user if none exists', (done)->
      User.findOrCreate 'alice', org.id, (err, alice)->
        assert alice
        assert.equal alice.organization, org.id
        done()

    after (done) ->
      User.where('username').in(['bob','alice']).remove ->
        done()

  describe 'earning badges', ->
    user = null
    badge = null
    beforeEach (done)->
      User.where('username').in(['bob','alice']).remove ->
        badge = new Badge name: 'super badge', issuer_id: org.id
        badge.save ->
          user = new User username: 'bob', organization: org.id
          user.save ->
              done()

    it "adds the badge to the user's earned badges", (done)->
      user.earn badge, (err, response)->
        assert.equal user.badges.length, 1
        assert.equal response.earned, true
        done()

    it "it returns the badge on the response obj when success", (done)->
      user.earn badge, (err, response)->
        assert.equal response.badge.id, badge.id
        done()

    it "doesn't add the badge if the user already has it", (done) ->
      assert.equal user.badges.length, 0
      user.earn badge, (err, response)->
        assert.equal user.badges.length, 1
        user.earn badge, (err, response)->
          assert.equal user.badges.length, 1
          done()

    it "it sets the badge's issued_on date", (done) ->
      user.earn badge, (err, response)->
        assert.equal user.badges[0].issued_on.getDay(), (new Date).getDay()
        done()

    it "returns a message when the user already has the badge", (done) ->
      user.earn badge, (err, r)->
        user.earn badge, (err, response)->
          assert.equal response.earned, false
          assert.equal response.message, "User already has this badge"
          done()

    afterEach (done) ->
      badge.remove()
      User.where('username').in(['bob','alice']).remove ->
        done()
