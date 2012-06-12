assert  = require 'assert'
User   = require '../../models/user'

describe 'Badge', ->
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
