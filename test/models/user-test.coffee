assert  = require 'assert'
User   = require '../../models/user'
EarnedBadge = require '../../models/earned_badge'
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
      user = new User username: 'Bob'
      user.save()
      done()


    it 'downcases username on save', ->
      assert.equal user.username, 'bob'

  describe 'when finding or creating by username', ->
    user = null
    # remove all the bobs and alices beforehand
    before (done)->
      User.where('username').in(['bob','alice']).remove ->
        user = new User username: 'bob'
        user.save ->
          done()

    it 'it returns an existing user if exists', (done)->
      User.findOrCreateByUsername 'bob', (err, bob)->
        assert.equal bob.id, user.id
        done()

    it 'it returns an existing user if exists', (done)->
      User.findOrCreateByUsername 'alice', (err, alice)->
        assert alice
        done()

    after (done) ->
      User.where('username').in(['bob','alice']).remove ->
        done()

  describe 'earning badges', ->
    user = null
    badge = null
    beforeEach (done)->
      User.where('username').in(['bob','alice']).remove ->
        badge = new Badge name: 'super badge', issuer: org.id
        badge.save ->
          user = new User username: 'bob'
          user.save ->
              done()

    it "adds the badge to the user's earned badges", (done)->
      user.earn badge, (err, response)->
        assert.equal user.earned_badges.length, 1
        assert.equal response.earned, true
        done()

    it "it returns the badge on the response obj when success", (done)->
      user.earn badge, (err, response)->
        assert.equal response.badge.id, badge.id
        done()

    it "doesn't add the badge if the user already has it", (done) ->
      assert.equal user.earned_badges.length, 0
      user.earn badge, (err, response)->
        assert.equal user.earned_badges.length, 1
        user.earn badge, (err, response)->
          assert.equal user.earned_badges.length, 1
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
