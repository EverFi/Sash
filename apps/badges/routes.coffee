Badge = require '../../models/badge'
User = require '../../models/user'
Organization = require '../../models/organization'
BadgesToUsers = require '../../models/badges_to_users'
authenticate = require '../middleware/authenticate'
arrayUtils = require '../../lib/array'
Promise = require('mongoose').Promise
util = require 'util'
_ = require 'underscore'
fs = require 'fs'

routes = (app) ->
  #
  #SHOW JSON - Public - Returns JSON formatted badge
  app.get '/badges/:slug.:format', (req, res) ->
    Badge.findOne slug: req.params.slug, (err, badge) ->
      formatBadgeResponse(req, res, badge)

  #INDEX
  app.get '/badges.:format?', authenticate, (req, res, next) ->
    next() if !req.org
    orgId = req.org.id
    query = Badge.where('issuer_id', orgId)
    if req.query.tags?
      tags = _.flatten(Array(req.query.tags))
      if req.query.match_any_tags?
        # Matching ANY of the tags
        query.in('tags', tags)
      else
        # Matching ALL of the tags
        query.where('tags', {'$all': tags})
    query.exec (err, badges)->
      if req.xhr || req.params.format == 'json'
        formatBadgeResponse(req, res, badges)
      else
        res.render "#{__dirname}/views/index",
          badges: badges
          orgId: orgId
          org: req.org

  app.namespace '/badges', authenticate, ->

    #NEW
    app.get '/new', (req, res) ->
      if req.org
        orgId = req.org.id
      res.render "#{__dirname}/views/new",
        badge: new Badge
        orgId: orgId

    #CREATE
    app.post '/', (req, res, next) ->
      badge = new Badge req.body.badge
      badge.attach 'image', req.files.badge.image, (err)->
        next(err) if err
        badge.save (err, doc) ->
          next(err) if err
          btu = new BadgesToUsers
          btu.badgeId = doc._id
          btu.users = []
          btu.save (err, btu_doc) ->
            next(err) if err
            req.flash 'info', 'Badge saved successfully!'
            res.redirect '/badges'

    #SHOW
    app.get '/:slug/assertion.:format?', (req, res) ->
      Badge.findOne slug: req.params.slug, (err, badge) ->
        if req.params.format == 'json'
          formatBadgeAssertionResponse(req, res, badge)
        else
          res.render "#{__dirname}/views/show",
            badge: badge
            issuer: badge.issuer()

    #SHOW
    app.get '/:slug', (req, res) ->
      Badge.findOne slug: req.params.slug, (err, badge) ->
        res.render "#{__dirname}/views/show",
          badge: badge
          issuer: badge.issuer()

    #SHOW
    app.get '/:slug/edit', (req, res) ->
      Badge.findOne slug: req.params.slug, (err, badge) ->
        res.render "#{__dirname}/views/edit",
          badge: badge
          issuer: badge.issuer()
          orgId: req.org.id

    #UPDATE
    app.put '/:slug', (req, res, next) ->
      if req.files.badge.image.length > 0
        Badge.findOne slug: req.params.slug, (err, badge) ->
          badge.attach 'image', req.files.badge.image, (err)->
            next(err) if err
            badge.set(req.body.badge)
            badge.save (err, doc) ->
              next(err) if err
              req.flash 'info', 'Badge saved successfully!'
              res.redirect '/badges'
      else
        Badge.findOne slug: req.params.slug, (err, badge) ->
          badge.set(req.body.badge)
          badge.save (err, doc) ->
            next(err) if err
            req.flash 'info', 'Badge saved successfully!'
            res.redirect '/badges'


    #DELETE
    app.del '/:slug', (req, res, next) ->
      Badge.findOne slug: req.params.slug, (err, badge) ->
        badge.remove (err) ->
          if req.xhr
            res.send JSON.stringify(success: true),
              "Content-Type": "application/json"
          else
            req.flash 'info', 'Badge Destroyed!'
            res.redirect '/badges'

    #REVOKE
    app.post '/revoke/:badgeId', (req, res, next) ->
      username = req.body.username
      console.log("revoking badge #{req.params.badgeId} from #{username}")

      User.findOne {username:username}, (err, user) ->
        badgeIndex = null
        userBadges = user.badges
        for i in [0...userBadges.length]
          if userBadges[ i ]._id.toString() == req.params.badgeId.toString()
            badgeIndex = i
            break
        if badgeIndex?
          bid = userBadges[ badgeIndex ]._id.toString()
          console.log("bid=#{bid}")
          user.badges.splice badgeIndex, 1
          user.save (err) ->
            if err?
              res.send JSON.stringify({revoked:false, message:err}),
                'content-type': 'application/json'
            else
              BadgesToUsers.findOne {badgeId: bid}, (err, btu) ->
                if err?
                  res.send JSON.stringify({error: err})
                else
                  uindex = null
                  for i in [0...btu.users]
                    if btu.users[ i ].toString() == user._id.toString()
                      uindex = i
                      break
                  btu.users.splice uindex, 1
                  btu.save (err) ->
                    next(err) if err
                    res.send JSON.stringify({revoked:true}),
                      'content-type': 'application/json'

        else
          res.send JSON.stringify({revoked:false, message:'User has not earned this badge'}),
            'content-type': 'application/json'

    app.post '/issue/:slug', (req, res, next) ->
      username = req.body.username
      email = req.body.email
      email = undefined if(email == '')
      console.log("Trying to issue badge: #{req.params.slug}")
      console.log("params: {username: #{username}, email: #{email}, slug: #{req.params.slug}")
      Badge.findOne slug: req.params.slug, (err, badge) ->
        if err?
          console.log("Error Finding Badge: #{JSON.stringify(err)}")
          res.send JSON.stringify({issued: false}),
            'content-type': 'application/json'
          return

        unless badge? & username?
          console.error("Can't issue badge #{req.params.slug}, doesn't exist")
          res.send JSON.stringify({issued: false}),
            'content-type': 'application/json'
          return

        User.findOrCreate username, email,
          {issuer_id: badge.issuer_id, tags: req.query.tags},
          (err, user) ->
            if err?
              console.error("Can't issue badge #{req.params.slug}, #{JSON.stringify(err)}")
              res.send JSON.stringify({message: "error issuing badge", error: err}),
                'content-type': 'application/json'
              return
            console.log("user: #{user.username}/#{user.email}, id: #{user.id}")
            user.earn badge, (err, response) ->
              if err?
                response = {message: "Failed to issue Badge", error: err}
                console.error "Badge Issue Response: #{JSON.stringify(response)}"
              else
                count = parseInt badge.issued_count
                count += 1
                badge.issued_count = count.toString()
                badge.save (err) ->
                  next(err) if err
                  BadgesToUsers.findOne { badgeId: badge._id }, (err, btu) ->
                    if err?
                      console.error(err)

                    onComplete = () ->
                      console.log "Badge Issue Response: #{JSON.stringify(response)}"
                      res.send JSON.stringify(response),
                        'content-type': 'application/json'
                      return

                    if btu?
                      location = arrayUtils.containsString btu.users, user._id
                      if location == -1
                        btu.users.push( user._id )
                        btu.save (err) ->
                          if err?
                            console.error(err)
                          return onComplete()
                      else 
                        return onComplete()
                    else
                      onComplete()


formatBadgeAssertionResponse = (req, res, badge) ->
  cb = req.query.callback
  assertionPromise = badge.toJSON()
  if cb
    assertionPromise.on 'complete', (assertion)->
      res.send "#{cb}(#{JSON.stringify(assertion)})"
  else
    res.send assertionPromise,
      'content-type': 'application/json'

formatBadgeResponse = (req, res, badge) ->
  cb = req.query.callback
  if cb
    res.send "#{cb}(#{JSON.stringify(badge)})"
  else
    res.send JSON.stringify(badge),
      'content-type': 'application/json'


module.exports = routes

