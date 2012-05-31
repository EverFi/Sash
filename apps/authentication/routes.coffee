
routes = (app) ->
  app.get '/login', (req, res) ->
    console.log __dirname
    res.render "#{__dirname}/views/login",
      title: 'Login',
      stylesheet: 'login'

module.exports = routes
