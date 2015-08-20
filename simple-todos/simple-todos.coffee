Tasks = new Mongo.Collection "tasks"

if Meteor.isClient

  Meteor.subscribe "tasks"

  Template.body.helpers
    hideCompleted: ->
      Session.get "hideCompleted"
    incompletedCount: ->
      Tasks.find({checked: {$ne:true}}).count()
    tasks: ->
      if Session.get "hideCompleted"
        return Tasks.find {checked: {$ne: true}}, {sort: {createdAt: -1}}
      else
        return Tasks.find {}, {sort: {createdAt: -1}}

  Template.body.events
    "submit .new-task": (event) ->
      event.preventDefault()

      text = event.target.text.value

      Meteor.call "addTask", text

      event.target.text.value = ""

    "change .hide-completed input": (event) ->
      Session.set "hideCompleted", event.target.checked

  Template.task.events
    "click .toggle-checked": ->
      Meteor.call "setChecked", this._id, !this.checked

    "click .delete": ->
      Meteor call "deleteTask", this._id

    "click .toggle-private": ->
      console.log Tasks.findOne this._id
      Meteor.call "setPrivate", this._id, !this.private

  Template.task.helpers
    isOwner: -> this.owner is Meteor.userId()

  Accounts.ui.config passwordSignupFields: "USERNAME_ONLY"

if Meteor.isServer
  Meteor.publish "tasks", ->
    Tasks.find
      $or: [
        {private: {$ne: true}},
        {owner: this.userId}
      ]

Meteor.methods
  addTask: (text) ->
    if not Meteor.userId()
      throw new Meteor.Error "Need to login first"

    Tasks.insert
      text: text,
      createdAt: new Date()
      owner: Meteor.userId(),
      username: Meteor.user().username

  deleteTask: (taskId) ->
    checkOwner taskId
    Tasks.remove taskId

  setChecked: (taskId, setChecked) ->
    checkOwner taskId
    Tasks.update tasksId, {$set: {checked: setChecked}}

  setPrivate: (taskId, setToPrivate) ->
    checkOwner taskId
    Tasks.update taskId, {$set: {private: setToPrivate}}

checkOwner= (taskId) ->
    task = Tasks.findOne taskId
    if task.owner isnt Meteor.userId()
      throw new Meteor.Error "not authorized"
