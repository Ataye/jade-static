express = require 'express'
supertest = require 'supertest'
assert = require 'assert'
jadeStatic = require '../src/jade-static'

describe 'jade-static', ->
  request = null

  before ->
    app = express()
    src = "#{__dirname}/public"
    app.use '/mount', jadeStatic src
    app.use '/pretty', jadeStatic {src, jade: pretty: true}
    request = supertest app

  it 'serves index.jade from folder', (done) ->
    request
      .get '/mount'
      .expect 200
      .expect '<div class="hello"><div class="pretty">World!</div></div>', done

  it 'serves index.jade', (done) ->
    request
      .get '/mount/index.jade'
      .expect 200
      .expect '<div class="hello"><div class="pretty">World!</div></div>', done

  it 'serves index.html', (done) ->
    request
      .get '/mount/index.html'
      .expect 200
      .expect '<div class="hello"><div class="pretty">World!</div></div>', done

  it 'handles 404s', (done) ->
    request
      .get '/mount/missing-file.jade'
      .expect 404, done

  it 'passes options to jade compiler', (done) ->
    request
      .get '/pretty/index.html'
      .expect 200
      .end (err, res) ->
        assert.ok /\s<\/div>$/.test(res.text), 'Output does not contain whitespace'
        done()