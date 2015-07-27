crypto = require "crypto"
Promise = require 'bluebird'
fs = Promise.promisifyAll(require 'fs')


SECRET = "this!sMy4ppSecRet"

class Auth
  constructor: (@secret) ->
    @secret = SECRET unless @secret
    @dataLoaded = false
    @users = {}

  auth: (username, password, cb) ->
    Promise.resolve(@loadData())
    .then =>
      if @users[username] == password
        return cb(null)
      else
        return cb("auth failed")
    .catch (e) =>
      cb(e)

  loadData: (cb) ->
    return if @dataLoaded
    fs.readFileAsync("./.passwd", {encoding: "utf8"})
    .then (content) =>
      for line in content.split("\n")
        [name, pass] = line.split(/\s+/)
        @users[name] = pass if name and pass
      @dataLoaded = true

  verifyToken: (username, expire, token) ->
    return false unless expire.match(/^\d+$/)
    return false if Date.now() > (+expire)
    t = @getUserToken(username, expire)
    return false if t != token
    return true

  getUserToken: (username, key) ->
    md5sum = crypto.createHash('sha1')
    md5sum.update("#{username}-#{key}-#{SECRET}")
    return md5sum.digest('hex')


module.exports = Auth
