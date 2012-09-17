configuration = require '../lib/configuration'
crypto = require 'crypto'

module.exports = (string)->
  sha = crypto.createHash('sha256');
  sha.update(string + configuration.get('salt'))
  sha.digest('hex')
