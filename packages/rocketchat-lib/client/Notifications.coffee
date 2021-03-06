RocketChat.Notifications = new class
	constructor: ->
		@logged = Meteor.userId() isnt null
		@loginCb = []
		Tracker.autorun =>
			if Meteor.userId() isnt null and this.logged is false
				cb() for cb in this.loginCb

			@logged = Meteor.userId() isnt null

		@debug = false
		@streamAll = new Meteor.Streamer 'notify-all'
		@streamLogged = new Meteor.Streamer 'notify-logged'
		@streamRoom = new Meteor.Streamer 'notify-room'
		@streamRoomUsers = new Meteor.Streamer 'notify-room-users'
		@streamUser = new Meteor.Streamer 'notify-user'

		if @debug is true
			@onAll -> console.log "RocketChat.Notifications: onAll", arguments
			@onUser -> console.log "RocketChat.Notifications: onAll", arguments

	onLogin: (cb) ->
		@loginCb.push(cb)
		if @logged
			cb()

	notifyRoom: (room, eventName, args...) ->
		console.log "RocketChat.Notifications: notifyRoom", arguments if @debug is true

		args.unshift "#{room}/#{eventName}"
		@streamRoom.emit.apply @streamRoom, args

	notifyUser: (userId, eventName, args...) ->
		console.log "RocketChat.Notifications: notifyUser", arguments if @debug is true

		args.unshift "#{userId}/#{eventName}"
		@streamUser.emit.apply @streamUser, args

	notifyUsersOfRoom: (room, eventName, args...) ->
		console.log "RocketChat.Notifications: notifyUsersOfRoom", arguments if @debug is true

		args.unshift "#{room}/#{eventName}"
		@streamRoomUsers.emit.apply @streamRoomUsers, args

	onAll: (eventName, callback) ->
		@streamAll.on eventName, callback

	onLogged: (eventName, callback) ->
		@onLogin =>
			@streamLogged.on eventName, callback

	onRoom: (room, eventName, callback) ->
		if @debug is true
			@streamRoom.on room, -> console.log "RocketChat.Notifications: onRoom #{room}", arguments

		@streamRoom.on "#{room}/#{eventName}", callback

	onUser: (eventName, callback) ->
		@streamUser.on "#{Meteor.userId()}/#{eventName}", callback


	unAll: (callback) ->
		@streamAll.removeListener 'notify', callback

	unLogged: (callback) ->
		@streamLogged.removeListener 'notify', callback

	unRoom: (room, eventName, callback) ->
		@streamRoom.removeListener "#{room}/#{eventName}", callback

	unUser: (callback) ->
		@streamUser.removeListener Meteor.userId(), callback
