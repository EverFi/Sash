Badge = require '../models/badge'
User = require '../models/user'
Organization = require '../models/organization'
BadgesToUsers = require '../models/badges_to_users'
BadgeMetric = require '../models/badge_metric'
authenticate = require '../apps/middleware/authenticate'
async = require 'async'
arrayUtils = require './array'
Promise = require('mongoose').Promise
util = require 'util'
_ = require 'underscore'
fs = require 'fs'


issue = (slug, tags, username, email, onComplete) ->

  findBadge = (callback) ->
    Badge.findOne slug: slug, (err, badge) ->
      if err?
        callback err
      if !badge
        callback new Error "Badge does not exist!"
      else
        callback null, badge

  findOrCreateUser = (badge, callback) ->
    User.findOrCreate username, email,
      {issuer_id: badge.issuer_id, tags: tags},
      (err, user) ->
        if err?
          callback err
        console.log("user: #{user.username}/#{user.email}, id: #{user.id}")
        user.earn badge, (err, response) ->
          if err?
            callback err
          if response.earned == false
            callback response.message
          count = parseInt badge.issued_count
          count += 1
          badge.issued_count = count.toString()
          badge.save (err) ->
            if err?
              callback err
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
      callback err
      if doc
        doc.mark badge._id
      else
        doc = new BadgeMetric()
        doc.moment = 'issued'
        doc.organization = badge.issuer_id
        doc.mark badge._id
      doc.save (err) ->
        callback err
        callback()

  async.waterfall [ 
    findBadge,
    findOrCreateUser,
    markBadgesToUsers,
    recordMetric
  ], onComplete


exports.issue = issue





