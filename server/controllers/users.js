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
			Room.findOneAndUpdate({_id: req.body._id}, {'$push': {users: req.body.user}}).exec(function(err){
				if(err){
					console.log('cannot add user to room');
				} else{
					User.findByIdAndUpdate(req.body.user, {$push: {rooms: req.body._id}}, {new: true}, function(err, user){
						if (err) {
							console.log(err)
						} else {
							console.log('successfully added user to room')
							res.json(user)
						}
					});
					
				}
			})
		}
	}
})();