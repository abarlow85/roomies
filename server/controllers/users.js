var mongoose = require('mongoose');
var User = mongoose.model('User');
var Room = mongoose.model('Room');

module.exports = (function(){
	return{
		show: function(req, res){
			User.find({}).exec(function(err, users){
				if(err){
					console.log(err.errors);
					console.log('cannot show all users');
				} else{
					res.json(users);
				}
			})
		},

		showCurrentUser: function(req, res) {
			// console.log(req.params.id);
			User.findOne({_id: req.session.passport.user}).exec(function(err, user) {
				if(err){
					console.log('cannot show by id in users');
				} else {
					console.log('showing current user...');
					res.json(user);
				}
			})
		},

		show_by_id: function(req, res) {
			console.log(req.params.id);
			User.findOne({_id: req.params.id}).exec(function(err, user) {
				if(err){
					console.log('cannot show by id in users');
				} else {
					console.log('showing one user...');
					res.json(user);
				}
			})
		},

		add_to_room: function(req, res){
			User.findOne({"_id":req.body.user, "rooms": req.body._id}, function(err, user){
				if (err) {
					console.log(err)
				} else if (user){
					console.log("the user is in the room already")
					console.log(user.rooms)
					User.findByIdAndUpdate(req.body.user, {_lastRoom: req.body._id}, function(err){
						if (err) {
							console.log(err)
						} else {
							console.log('changed user _lastRoom')
							res.json({_id: req.body._id})
						}
					});
				} else {
					Room.findOneAndUpdate({_id: req.body._id}, {'$push': {users: req.body.user}}, {new: true}).exec(function(err, newRoom){
					if(err){
						console.log('cannot add user to room');
					} else{
						User.findByIdAndUpdate(req.body.user, {$push: {rooms: req.body._id}}, function(err){
							if (err) {
							console.log(err)
							} else {
								console.log('successfully added user to room')
								res.json(newRoom)
							}
						});
					
					}
					});
				}
			})
			
		}, 
		// socket methods 
		login: function(callback) {
		User.find({}, function(err, users){
			if(err){
				console.log('error');
			} else {
				
				callback(users);
			}
		});	
	}
	}
})();