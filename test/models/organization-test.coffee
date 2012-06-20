assert = require 'assert'
Organization = require '../../models/organization'
Badge = require '../../models/badge'
User = require '../../models/user'

describe "organization", ->

  describe "GET /organization", ->
    user = null
    org = null
    badge = null

    before (done)->
      org = new Organization {
        name: 'Chipotle',
        origin: "www.chipotle.com",
        org: "Chipotle, Inc"
      }

      badge = new Badge name: 'awesome badge mcawesome', issuer: org.id
      user = new User username: 'bob', org: org.id
      org.save ->
        badge.save ->
          user.save ->
            done()

    it "should return the badges attached to that org", (done)->
      org.badges (err, badges)->
        assert.equal badges[0].id, badge.id
        done()

    it "should count the number of badges",(done)->
      org.badgesCount (err, badgeCount)->
        assert.equal badgeCount, 1
        done()

    it "should return all the users attached to that org", (done)->
      org.users (err, users) ->
        assert.equal users[0].id, user.id
        done()

    it "should count the number of user", (done)->
      org.usersCount (err, usersCount) ->
        assert.equal usersCount, 1
        u = new User name: "alice", org: org.id
        u.save ->
          org.usersCount (err, count) ->
            assert.equal count, 2
            done()
