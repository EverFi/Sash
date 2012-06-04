assert  = require 'assert'
Badge   = require '../../models/badge'

describe 'Badge', ->
  describe 'create', ->
    badge = null
    before ->
      badge = new Badge {name: 'Financial Literacy'}

    it 'sets name', ->
      assert.equal badge.name, 'Financial Literacy'
