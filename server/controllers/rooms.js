var mongoose = require('mongoose');
var User = mongoose.model('User');
var Room = mongoose.model('Room');

module.exports = (function(){
	return{
		show: function(req, res){
			Room.find({}).exec(function(err, rooms){
				if(err){
					console.log(err.errors);
					console.log('cannot show all rooms');
				} else{
					console.log('showing all rooms');
					res.json(rooms);
				}
			})
		},

		show_by_id: function(req, res) {
			Room.findOne({_id: req.params.id})
			.populate("users")
			.populate({path: 'tasks', model: 'Task', populate: {path: 'users', model: 'User'}})
			.exec(function(err, room) {
				if(err){
					console.log('cannot search for room');
				} else {
					console.log('showing room search');
					res.json(room);

				}
			})
		},

		create: function(req, res){
			Room.findOne({"name": req.body.name, "category": req.body.category}, function(err, roomExists) {
				if (err) {
					console.log(err);
				} else if (roomExists) {
					console.log("duplicate")
					console.log(roomExists);
					res.json({"error": "Room name and category already exist"})
				} else {
					var room = new Room({name: req.body.name, category: req.body.category});
					room.save(function(err){
					if(err){
						console.log(err.errors);
						console.log('cannot add room');
					} else{
						console.log(room)
						console.log("successfully added room")
						Room.findByIdAndUpdate(room._id, {$push: {users: req.body.user}}, {new: true}, function(err, newRoom){
							if (err) {
								console.log(err);
							} else {
								console.log("room updated with user");
								User.findByIdAndUpdate(req.body.user, {
									$push: {rooms: room._id}},
									{new: true}, function(err, user){
									if (err) {
										console.log(err);
									} else {
										console.log("user updated with room");
										User.findByIdAndUpdate(user._id, {_lastRoom: room._id}, function(err) {
											if (err) {
												console.log(err)
											} else {
												console.log("_lastRoom updated in user")
												res.json(newRoom);
											}
										});
										
									}
								})
							
							}
						})
					}
					})
			}
			});
			
		}

		// create: function(req, res){
		// 	console.log("adding rooms");
		// 	var room = new Room({name: "123", category: "UC Berkeley", created_at: new Date});
		// 	room.save(function(err, room){
		// 		if(err){
		// 			console.log(err.errors);
		// 			console.log('cannot add room');
		// 		} else{
		// 			console.log("successfully added room")
					
		// 		}
		// 	})
		// 	var room = new Room({name: "321", category: "UC Berkeley", created_at: new Date});
		// 	room.save(function(err, room){
		// 		if(err){
		// 			console.log(err.errors);
		// 			console.log('cannot add room');
		// 		} else{
		// 			console.log("successfully added room")
					
		// 		}
		// 	})
		// 	var room = new Room({name: "541", category: "UC Berkeley", created_at: new Date});
		// 	room.save(function(err, room){
		// 		if(err){
		// 			console.log(err.errors);
		// 			console.log('cannot add room');
		// 		} else{
		// 			console.log("successfully added room")
					
		// 		}
		// 	})
		// 	var room = new Room({name: "7363", category: "UC Berkeley", created_at: new Date});
		// 	room.save(function(err, room){
		// 		if(err){
		// 			console.log(err.errors);
		// 			console.log('cannot add room');
		// 		} else{
		// 			console.log("successfully added room")
					
		// 		}
		// 	})
		// 	var room = new Room({name: "1", category: "UC Davis", created_at: new Date});
		// 	room.save(function(err, room){
		// 		if(err){
		// 			console.log(err.errors);
		// 			console.log('cannot add room');
		// 		} else{
		// 			console.log("successfully added room")
					
		// 		}
		// 	})
		// 	var room = new Room({name: "13", category: "UC Davis", created_at: new Date});
		// 	room.save(function(err, room){
		// 		if(err){
		// 			console.log(err.errors);
		// 			console.log('cannot add room');
		// 		} else{
		// 			console.log("successfully added room")	
		// 		}
		// 	})
		// 	var room = new Room({name: "12", category: "UC Davis", created_at: new Date});
		// 	room.save(function(err, room){
		// 		if(err){
		// 			console.log(err.errors);
		// 			console.log('cannot add room');
		// 		} else{
		// 			console.log("successfully added room")	
		// 		}
		// 	})
		// 	var room = new Room({name: "1", category: "Coding Dojo", created_at: new Date});
		// 	room.save(function(err, room){
		// 		if(err){
		// 			console.log(err.errors);
		// 			console.log('cannot add room');
		// 		} else{
		// 			console.log("successfully added room")	
		// 		}
		// 	})
		// }
	}
})();