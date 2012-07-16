config = {}
exports.get = (val, env)->
  env = env || process.env['NODE_ENV']
  if (val == 'env') return env
  if (!config[env])
    var path = './environments/' + env
    if !exists(path)
      if (env != 'development')
        return exports.get(val, "development")
      else
        throw new Error("unknown environment: " + env)
    config[env] = require(path).config;
  return config[env][val]

exists = (file)->
  try
    require(file)
    return true
  catch (e)
    return false

if (undefined === process.env['NODE_ENV'])
  process.env['NODE_ENV'] = 'development'

