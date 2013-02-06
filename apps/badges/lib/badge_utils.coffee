Badge = require '../../../models/badge'
User = require '../../../models/user'
Organization = require '../../../models/organization'
BadgesToUsers = require '../../../models/badges_to_users'
BadgeMetric = require '../../../models/badge_metric'
authenticate = require '../../../apps/middleware/authenticate'
async = require 'async'
arrayUtils = require '../../../lib/array'
Promise = require('mongoose').Promise
util = require 'util'
_ = require 'underscore'
fs = require 'fs'

create = (badge, image, callback) ->
  badge.attach 'image', image, (err)->
    callback err if err
    badge.save (err, doc) ->
      callback err if err
      btu = new BadgesToUsers
      btu.badgeId = doc._id
      btu.users = []
      btu.save (err, btu_doc) ->
        callback err if err
        criteria = {moment:'created', organization:badge.issuer_id};
        BadgeMetric.findOne criteria, (err, doc) ->
          callback err if err
          if doc
            doc.mark badge._id
          else
            doc = new BadgeMetric()
            doc.moment = 'created'
            doc.organization = badge.issuer_id
            doc.mark badge._id
          doc.save (err) ->
            callback err if err
            callback()

revoke = (username, badgeId, onComplete) ->
  removeBadgeFromUser = (callback) ->
    User.findOne {username:username}, (err, userDoc) ->
      callback err if err
      user = userDoc
      badgeIndex = null
      userBadges = user.badges
      for i in [0...userBadges.length]
        if userBadges[ i ]._id.toString() == badgeId
          badgeIndex = i
          break
      if badgeIndex?
        bid = userBadges[ badgeIndex ]._id.toString()
        user.badges.splice badgeIndex, 1
        Badge.findOne {_id:bid}, (err, badge) ->
          callback err if err
          if !badge
            callback new Error "Badge does not exist!"
          callback null, user, badge
      else
        callback new Error "User has not earned this badge"

  decrementBadgeCount = (user, badge, callback) ->
    count = parseInt badge.issued_count
    count -= 1
    badge.issued_count = count.toString()
    badge.save (err) ->
      callback err if err
      user.save (err) ->
        callback err, user, badge._id

  saveBadgeToUserMapping = (user, bid, callback) ->
    BadgesToUsers.findOne {badgeId: bid}, (err, btu) ->
      callback err if err
      uindex = null
      for i in [0...btu.users]
        if btu.users[ i ].toString() == user._id.toString()
          uindex = i
          break
      btu.users.splice uindex, 1
      btu.save (err) ->
        callback err

  async.waterfall [ 
    removeBadgeFromUser, 
    decrementBadgeCount, 
    saveBadgeToUserMapping
  ], onComplete

issue = (slug, tags, username, email, onComplete) ->

  findBadge = (callback) ->
    Badge.findOne slug: slug, (err, badge) ->
      callback err if err
      if !badge
        callback new Error "Badge does not exist!"
      else
        callback null, badge

  findOrCreateUser = (badge, callback) ->
    User.findOrCreate username, email,
      {issuer_id: badge.issuer_id, tags: tags},
      (err, user) ->
        callback err if err
        console.log("user: #{user.username}/#{user.email}, id: #{user.id}")
        user.earn badge, (err, response) ->
          callback err if err
          if response.earned == false
            callback response.message
          else
            count = parseInt badge.issued_count
            count += 1
            badge.issued_count = count.toString()
            badge.save (err) ->
              callback err if err
              else
                callback null, badge, user

  markBadgesToUsers = (badge, user, callback) ->
    BadgesToUsers.findOne { badgeId: badge._id }, (err, btu) ->
      if err?
        callback err
      if btu?
        location = arrayUtils.containsString btu.users, user._id
        if location == -1
          btu.users.push( user._id )
          btu.save (err) ->
            callback err, badge
        else
          callback(null, badge)
      else
        callback(null)

  recordMetric = (badge, callback) ->
    criteria = {moment:'issued', organization:badge.issuer_id};
    BadgeMetric.findOne criteria, (err, doc) ->
      callback err if err
      if doc
        doc.mark badge._id
      else
        doc = new BadgeMetric()
        doc.moment = 'issued'
        doc.organization = badge.issuer_id
        doc.mark badge._id
      doc.save (err) ->
        callback err

  async.waterfall [ 
    findBadge,
    findOrCreateUser,
    markBadgesToUsers,
    recordMetric
  ], onComplete


exports.create = create
exports.revoke = revoke
exports.issue = issue





