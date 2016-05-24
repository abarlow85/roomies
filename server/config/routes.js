var tasks = require('../controllers/tasks.js')
var users = require('../controllers/users.js')
var rooms = require('../controllers/rooms.js')
var messages = require('../controllers/messages.js')
// var userList = [];
// var typingUsers = {};


module.exports = function(app, passport, server) {

	var io = require('socket.io').listen(server);
	console.log('got here!!!');
	io.sockets.on('connection', function(socket){
		console.log('connection!');
		
		socket.on('connected', function(){
			console.log('connected');
			users.login(function(output){
				console.log('broadcast');
				socket.broadcast.emit('new_user', output);
			})
		})

		socket.on('task', function(objective, users, expiration) {
			console.log(objective);
			console.log(users);
			console.log(expiration);
			// var new_task_data = {
			// 	objective: objective, 
			// 	users: users,
			// 	expiration: expiration
			// }
			io.emit('newTask', objective, users, expiration);
		})
	});

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
    
	app.post('/tasks/create', function(req, res){
		tasks.create(req, res);
	})

	app.post('/tasks/update', function(req, res){
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