assert = require 'assert'
Badge    = require '../../models/badge'

describe 'Badge', ->
  describe 'create', ->
    badge = null
    before ->
      badge = new Badge {name: 'Key Lime'}
    it 'sets name', ->
      assert.equal badge.name, 'Key Lime'


