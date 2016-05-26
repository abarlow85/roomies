var tasks = require('../controllers/tasks.js')
var users = require('../controllers/users.js')
var rooms = require('../controllers/rooms.js')
var messages = require('../controllers/messages.js')
var userList = [];
var typingUsers = {};


module.exports = function(app, passport, server, http) {

	// var io = require('socket.io')(http);
	var io = require('socket.io').listen(server);

	io.on('connection', function(socket){
		console.log('sockets connection!');

		// socket methods for chat messages
		socket.on('connected', function(last_room){
			console.log('user connected');
			// subscribe(socket, {room: last_room});
			
			users.login(function(output){
				socket.emit('new_user', output);
			})
		})
		socket.on('userPickedRoom', function (userObject){
			socket.broadcast.emit('userJoinedRoom', userObject.name);
		})
		// socket.on('subscribe', function(){
		// 	users.subscribe(socket, data);
		// })

		// socket.on('unsubscribe', function(){
		// 	users.unsubscribe(socket, data);
		// })

		// socket.on('disconnect', function(){
		// 	users.disconnect(socket, data);
		// })

		// socket methods for tasks
		socket.on('task', function(objective, users, expiration) {
			io.emit('newTask', objective, users, expiration);
		})

		socket.on('newTaskAlert', function(date, objective) {
			io.emit('getNewTaskAlert', date, objective)
		})

		socket.on('taskDeletedOrCompleted', function(message){
			io.emit('getTaskDeletedOrCompleted', message)
		})

	});

	// io.on('newTaskAlert', function(date, objective) {
	// 	io.emit('getNewTaskAlert', date, objective)
	// })

// User routes
	app.post('/register', passport.authenticate('local-register', {
        successRedirect: '/success',
        failureRedirect: '/failure',
        failureFlash: true
    }));

    app.post('/login', passport.authenticate('local-login', {
        successRedirect: '/success',
        failureRedirect: '/failure',
        failureFlash: true
    }));

    app.get('/success', function(req, res){
    	// res.json(req.session.passport);
    	// rooms.create(req, res);
    	users.showCurrentUser(req, res);
    });

    app.get('/failure', function(req, res){
    	
    	var error = req.flash('error')[0];
    	console.log(error);
    	res.json({'error': error});
    });

	app.get('/users', function(req, res){
		users.show(req, res);
	})

	app.get('/users/:id', function(req, res){
		users.show_by_id(req, res);
	})

	app.post('/users/addtoroom', function(req, res){
		users.add_to_room(req, res);
	})

// Task routes
	app.get('/tasks', function(req, res){
		tasks.show(req, res);
	});

	app.get('/tasks/:id', function(req, res){
        tasks.show_by_id(req, res);
    })

    app.get('/tasks/:room_id/:user_id', function(req, res){
		console.log("get tasks for user in room");
		tasks.show_user_tasks_for_room(req, res);
	});
    
	app.post('/tasks/create', function(req, res){
		tasks.create(req, res);
	})

	app.post('/tasks/update/:id', function(req, res){
		tasks.update(req, res);
	})

	app.post('/tasks/remove', function(req, res){
		tasks.remove(req, res);
	})

	app.post('/tasks/complete', function(req, res){
		tasks.complete(req, res);
	})
// Message routes
	app.post('/messages/create', function (req, res){
		messages.create(req, res);
	})

// Room routes
	app.get('/rooms', function(req, res){
		console.log("getting rooms")
		rooms.show(req, res);
	})

	app.get('/rooms/:id', function(req, res){
		console.log("getting tasks for room")
		console.log(req.params.id)
		rooms.show_by_id(req, res);
	})

	app.post('/rooms/create', function(req, res){
		rooms.create(req, res);
	})
}