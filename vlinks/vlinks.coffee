fileStore = new FS.Store.GridFS "files"
Files = new FS.Collection "files", {stores: [fileStore]}

Videos = new Mongo.Collection "videos"

if Meteor.isClient

  Meteor.subscribe "videos"

  Template.body.helpers
    videos: ->
      Videos.find {}

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
    insert: -> true
    update: -> true


  processFiles = ->
    console.log "process files"
    file = Files.findOne()
    if file
    #for file in Files.find().fetch()
      console.log "here"
      buffer = new Buffer 0
      readStream = file.createReadStream()
      readStream.on "data", (chunk) ->
        buffer = Buffer.concat [buffer, chunk]
        console.log "add chunk"
      readStream.on "end", Meteor.bindEnvironment ->
        console.log "end"
        HTTP.post "https://api.streamable.com/upload",
        {
          data: buffer
          auth: "sonnbc:123123"
          headers:
            "Content-Type": "multipart/form-data"
        },
        (error, result) ->
          console.log error, result



  #Meteor.setInterval processFiles, 30000
  processFiles()

