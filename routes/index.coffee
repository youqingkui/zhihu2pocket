express = require('express')
router = express.Router()
request = require('request')
async = require('async')

### GET home page. ###

router.get '/', (req, res, next) ->
  res.render 'index', title: 'Express'
  return

router.get '/auth', (req, res) ->
  key = process.env.pocket
  console.log key

  codeUrl = 'https://getpocket.com/v3/oauth/request'
  redirect_uri = 'http://localhost:3000/oauth_callback'
  form = {
    'consumer_key':key
    'redirect_uri':redirect_uri
  }
  op = {
    url:codeUrl
    form:form
  }
  async.auto
    getCode:(cb) ->
      request.post op, (err, response, body) ->
        return console.log err if err

        if response.statusCode is 200
          code = body.split('=')[1]
          cb(null, code)

        else
          return console.log "get code error, body", body


    directUrl:['getCode', (cb, result) ->
      code = result.getCode
      req.session.code = code
      url = "https://getpocket.com/auth/authorize?request_token=#{code}&redirect_uri=#{redirect_uri}"
      return res.redirect url

    ]



router.get '/oauth_callback', (req, res) ->
  url = 'https://getpocket.com/v3/oauth/authorize'
  key = process.env.pocket
  form = {
    consumer_key:key
    code:req.session.code
    headers:{
      'Content-Type': 'application/json; charset=UTF-8'
    }
  }

  op = {
    url:url
    form:form
  }

  request.post op, (err, response, body) ->
    return console.log err if err

    console.log body


router.get '/add', (req, res) ->
  form = {
    url:'http://youqingkui.me'
    title : 'youqing-pocket'
    tags : 'youqing'
    consumer_key:process.env.pocket
    access_token:process.env.access_token_pocket
  }
  op = {
    url : 'https://getpocket.com/v3/add'
    form:form
  }
  request.post op, (err, response, body) ->
    return console.log err if err

    res.send body








module.exports = router