
fs = require 'fs'
path = require 'path'
config  = JSON.parse(fs.readFileSync(path.normalize(__dirname + '/config.json', 'utf8')))

discourse = require './lib/discourse'
csv = require 'fast-csv'

api = new discourse(config.url, config.api.key, config.api.username)

api.createUser 'username', 'username@yahoo.com', 'username', 'password', -> console.log 'User Created'
