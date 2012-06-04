helpers = (app) ->

  # dynamic helpers are given request and response as parameters
  app.dynamicHelpers
    flash: (req, res) -> req.flash()

  # static helpers take any parametes and usually format data
  app.helpers
    urlFor: (object) ->
      if object.id
        "/admin/pies/#{object.id}"
      else
        "/admin/pies"

module.exports = helpers
