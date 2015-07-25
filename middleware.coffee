Auth = require "./auth"

BY_PASS_PATHS = /(^\/login|\.(js|css)$)/i
TTL = 86400*1000*2

module.exports = (app, express, options={}) ->
  {dirname, ttl, secret, byPassPaths} = options
  dirname = __dirname unless dirname
  ttl = TTL unless ttl
  byPassPaths = BY_PASS_PATHS unless byPassPaths

  auth = new Auth(secret)

  app.use "/auth", express.static(dirname+"/public")

  app.use (req, res, next) ->
    {user, expire, authToken} = req.cookies
    if user and expire and authToken and auth.verifyToken(user, expire, authToken)
      app.locals.user = req.user = req.cookies.user
      next()
    else if !byPassPaths.test(req.path)
      res.cookie("beforeLoginUrl", req.url)
      return res.redirect('/login')
    else
      next()

  app.get '/login', (req, res) ->
    res.render dirname + "/views/login"

  app.get '/logout', (req, res) ->
    res.clearCookie 'authToken'
    res.redirect '/login'

  app.post '/login', (req, res) ->
    {username, password} = req.body

    auth.auth username, password, (err) ->
      if err
        console.warn err
        return res.redirect '/login'

      expire = (Date.now() + ttl).toString()
      res.cookie("user", username)
      res.cookie("expire", expire)
      res.cookie("authToken", auth.getUserToken(username, expire))
      
      url = req.cookies.beforeLoginUrl ? '/'
      res.clearCookie "beforeLoginUrl"
      res.redirect url

