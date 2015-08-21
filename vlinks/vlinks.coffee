fileStore = new FS.Store.GridFS "files"
Files = new FS.Collection "files", {stores: [fileStore]}

Videos = new Mongo.Collection "videos"

if Meteor.isClient

  Meteor.subscribe "videos"

  Template.body.helpers
    videos: ->
      Videos.find {}
    files: ->
      console.log("find")
      Files.find {}

  Template.body.events

  Dropzone.autoDiscover = false

  Template.upload.rendered = ->
    dropzone = new Dropzone "#dropzone",
      accept: (file) ->
        console.log file
        Files.insert file, (err, fileObj) ->
          if err
            alert "error: " + err
          else
            console.log("success", fileObj)

if Meteor.isServer
  Meteor.publish "videos", -> Videos.find {}

  Files.allow
    insert: () -> true
    update: () -> true
    download: () -> true

