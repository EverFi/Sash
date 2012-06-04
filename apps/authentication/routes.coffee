
routes = (app) ->

  app.get '/login', (req, res) ->
    res.render "#{__dirname}/views/login",
      title: 'Login',
      stylesheet: 'login'

  app.post '/sessions', (req, res) ->
    if ('colin' is req.body.user) and ('12345' is req.body.password)
      req.session.currentUser = req.body.user
      req.flash 'info', "You are logged in as #{req.session.currentUser}"
      if req.session.previousUrl?
        url = req.session.previousUrl
      url ?= '/admin/pies'
      res.redirect url
      return

    req.flash 'error', "Username or password is invalid. Try again"
    res.redirect '/login'

  app.del '/sessions', (req, res) ->
    req.session.regenerate (err) ->
      req.flash 'info', 'You have been logged out.'
      res.redirect '/login'

module.exports = routes
