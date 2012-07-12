helpers = (app) ->

  # dynamic helpers are given request and response as parameters
  app.dynamicHelpers
    flash: (req, res) -> req.flash()
    logged_in: -> true

  # static helpers take any parametes and usually format data
  app.helpers
    # Object is a mongoose model object
    urlFor: (object) ->
      if object.collection
        prefix = object.collection.name + '/'
      else
        prefix = ''

      unless object.isNew
        "/#{prefix}#{object.id}"
      else
        "/#{prefix}"

module.exports = helpers
