Organization = require "../../models/organization"

# Need to support authentication via Organization API key as well

module.exports = (req, res, next) ->
  unauthorzed = ->
    if req.xhr
      res.send 403
    else
      res.redirect('/login')

  if api_key = req.query.api_key
    Organization.findOne {api_key: api_key}, (err, org)->
      if org?
        req.org = org
        next()
      else
        unauthorzed()

  else if req.session.org_id
    Organization.findById req.session.org_id, (err, org)->
      if org
        req.org = org
        req.session.org_id = org.id
        next()
      else
        unauthorzed()
  else
    unauthorzed()
