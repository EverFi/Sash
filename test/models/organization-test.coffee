assert = require 'assert'
Organization = require '../../models/organization'
Badge = require '../../models/badge'
User = require '../../models/user'

crypto = require 'crypto'

hexDigest = (string)->
  sha = crypto.createHash('sha256');
  sha.update('awesome')
  sha.digest('hex')

describe "Organization", ->

  user = null
  org = null
  badge = null
  badge2 = null

  before (done)->
    org = new Organization {
      name: 'Chipotle',
      origin: "www.chipotle.com",
      org: "Chipotle, Inc"
    }


    badge = new Badge name: 'awesome badge mcawesome', issuer_id: org.id
    badge2 = new Badge name: 'awesome badge mcawesome', issuer_id: org.id
    user = new User username: 'bob', organization: org.id
    org.save -> badge.save -> badge2.save -> user.save -> done()

  it "should return the badges attached to that org", (done)->
    org.badges (err, badges)->
      assert.equal badges[0].id, badge.id
      assert.equal badges[1].id, badge2.id
      done()

  it "should count the number of badges",(done)->
    org.badges (err, badges) ->
      assert.equal badges.length, 2
      done()

  it "should return all the users attached to that org", (done)->
    org.users (err, users) ->
      assert.equal users[0].id, user.id
      done()

  it "should count the number of user", (done)->
    org.users (err, users) ->
      assert.equal users.length, 1
      u = new User name: "alice", organization: org.id
      u.save ->
        org.users (err, users) ->
          assert.equal users.length, 2
          done()

  it "should set the hashed password from the password", (done)->
    org.setValue 'password', 'awesome'
    hash = hexDigest('awesome')
    org.save (err, o) ->
      assert.equal hash, org.hashed_password
      done();

