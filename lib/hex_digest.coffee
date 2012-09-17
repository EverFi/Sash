configuration = require '../lib/configuration'
crypto = require 'crypto'

module.exports = (string, salt)->
  sha = crypto.createHash('sha256');
  salt = configuration.get('salt') unless salt?
  sha.update(string + salt)
  sha.digest('hex')
