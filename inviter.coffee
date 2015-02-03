
TESTER_GROUP_NAME = "TestDriver"
BACKER_GROUP_NAME = "Backer"

BACKER_ID = 41
TESTER_ID = 42

fs = require 'fs'
path = require 'path'
config  = JSON.parse(fs.readFileSync(path.normalize(__dirname + '/config.json', 'utf8')))

discourse = require './lib/discourse'
csv = require 'fast-csv'

api = new discourse(config.url, config.api.key, config.api.username)

backerGroupMembers = []
testerGroupMembers = []
nonGroupMembers = []

backerGroupMemberNames = []
testerGroupMemberNames = []
nonGroupMemberNames = []

allBackers = []
allTesters = []

backersToInvite = []
testersToInvite = []

backersToUpgrade = []
testersToUpgrade = []

# api.get 'admin/groups.json', '', (error, body, httpCode) ->
#     json = JSON.parse(body);
#     console.log json

parseCurrentForumMembers = ->
    stream = fs.createReadStream('./data/user-list.csv');
    csvStream = csv({headers: true})
        .on 'data', (data) ->
            if data.group_names.indexOf(BACKER_GROUP_NAME) >= 0
                backerGroupMembers.push data.email
                backerGroupMemberNames.push data.username
            else if data.group_names.indexOf(TESTER_GROUP_NAME) >= 0
                testerGroupMembers.push data.email
                testerGroupMemberNames.push data.username
            else
                nonGroupMembers.push data.email
                nonGroupMemberNames.push data.username
        .on 'end', ->
            parseHumbleBackers()
            parseHumbleTesters(2)
            console.log 'Parsed current member list.'

    stream.pipe csvStream

parseHumbleBackers = ->
    stream = fs.createReadStream('./data/hb-1.csv');
    csvStream = csv({headers: true})
        .on 'data', (data) ->
            allBackers.push data.email
        .on 'end', ->
            console.log 'Parsed Humble backers.'
            processBackers()

    stream.pipe csvStream

parseHumbleTesters = (value) ->
    stream = fs.createReadStream('./data/hb-' + value + '.csv');
    csvStream = csv({headers: true})
        .on 'data', (data) ->
            allTesters.push data.email
        .on 'end', ->
            if value is 3
                console.log 'Parsed Humble testers.'
                processTesters()
            else
                value += 1
                parseHumbleTesters(value)

    stream.pipe csvStream

processBackers = ->
    for backer in allBackers
        if backerGroupMembers.indexOf backer is -1 and nonGroupMembers.indexOf backer is -1
            # api.put 'invites', {email: backer, group_ids: BACKER_ID},
            console.log "invite: " + backer + "," + BACKER_ID
        else if nonGroupMembers.indexOf backer isnt -1
            backersToUpgrade.push nonGroupMemberNames[nonGroupMembers.indexOf backer]
    # if backersToUpgrade.length
    #     api.patch 'admin/groups/' + BACKER_ID, { changes: {add: backersToUpgrade} }

processTesters = ->
    for backer in allTesters
        if testerGroupMembers.indexOf backer is -1 and nonGroupMembers.indexOf backer is -1
            # api.put 'invites', {email: backer, group_ids: TESTER_ID}, 
            console.log "invite: " + backer + "," + TESTER_ID
        else if nonGroupMembers.indexOf backer isnt -1
            testersToUpgrade.push nonGroupMemberNames[nonGroupMembers.indexOf backer]
    # if testersToUpgrade.length
    #     api.patch 'admin/groups/' + TESTER_ID, { changes: {add: testersToUpgrade} }

parseCurrentForumMembers()
