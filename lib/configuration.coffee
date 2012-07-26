fs = require 'fs'

config = {}

exports.get = (val, env)->
  env = env || process.env['NODE_ENV']
  return env if val == 'env'
  unless config[env]?
    path = __dirname + "/environments/#{env}.js"
    unless fs.existsSync path
      unless env == 'development'
        return exports.get val, "development"
      else
        throw new Error("unknown environment: #{env}")
    config[env] = require(path).config;
  return config[env][val]

if undefined == process.env['NODE_ENV']
  process.env['NODE_ENV'] = 'development'

