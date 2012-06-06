assert  = require 'assert'
Badge   = require '../../models/badge'

describe 'Badge', ->
  describe 'create', ->
    badge = null
    before ->
      badge = new Badge {name: 'Financial Literacy'}
      badge.save()

    it 'sets name', ->
      assert.equal badge.name, 'Financial Literacy'

    it 'sets the created_at date', (done)->
      Badge.findById badge.id, (err,doc)->
        d = new Date
        assert.equal doc.created_at.getMonth(), d.getMonth()
        assert.equal doc.created_at.getFullYear(), d.getFullYear()
        assert.equal doc.created_at.getHours(), d.getHours()
        done()

    it 'sets the updated_at date', (done)->
      Badge.findById badge.id, (err,doc)->
        d = new Date
        assert.equal doc.updated_at.getMonth(), d.getMonth()
        assert.equal doc.updated_at.getFullYear(), d.getFullYear()
        assert.equal doc.updated_at.getHours(), d.getHours()
        done()
