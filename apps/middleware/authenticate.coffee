Organization = require "../../models/organization"

module.exports = (req, res, next) ->
  if req.session.org_id
    Organization.findById req.session.org_id, (err, org)->
      req.org = org
      req.session.org_id = org.id
      next()
  else
    res.redirect('/login')
