var mongoose = require('mongoose');
var Task = mongoose.model('Task');
var User = mongoose.model('User');
var Room = mongoose.model('Room');
var Message = mongoose.model('Message');

module.exports = (function(){
	return{
		show: function(req, res) {
			Task.find({}, function(err, tasks) {
				if(err){
					console.log('cannot show all tasks');
				} else{
					res.json(tasks);
				}
			})
		},
		
		show_by_id: function(req, res) {
			Task.findOne({_id: req.params.id})
				.populate("users")
				.populate({path: 'messages', model: 'Message', populate: {path: '_user', model: 'User'}})
				.exec(function(err, task) {
					if(err){
						console.log('cannot show all tasks');
					} else{
						console.log(task)
						res.json(task);
					}
			})
		},

		create: function(req, res) {
			var task = new Task({objective: req.body.objective, expiration_date: req.body.expiration_date, _room: req.body._room, users: req.body.users});
			task.save(function(err, task){
				if (err){
					console.log(err.errors);
					console.log('cannot create task');
				} else {
					console.log('succesfully created task');
					Room.findOneAndUpdate({_id:req.body._room}, {'$push': {tasks: task._id}}, {new: true}).exec(function(err, room){
						if(err){
							console.log('error updating task to room');
						} else{
							console.log('successfully updated task to room')
							console.log(room)
							res.json(room);
						}
					});
				}
				
			});
		},

		update: function(req, res) {
			Task.findOneAndUpdate({_id: req.params.id}, {objective: req.body.objective, expiration_date: req.body.expiration_date, users: req.body.users}, function(err, tasks) {
				if(err){
					console.log('cannot update task information');
				} else {
					console.log('successfully updated task information');
					res.json(tasks);
				}
			})
		},

		complete: function(req, res) {
			Task.findOneAndUpdate({_id: req.body._id}, {completed: "completed"}, function(err, tasks) {
				if(err){
					console.log('cannot complete task');
				} else {
					console.log('successfully completed task');
					res.json(tasks);
				}
			})
		},

		remove: function(req, res) {
			console.log(req.body);
			Task.remove({_id: req.body._id}, function(err, tasks) {
				if(err) {
					console.log('cannot remove task');
					return err.errors;
				} else {
					console.log('successfully removed task!');
					Room.findOneAndUpdate({_id: req.body._room}, {'$pull': {tasks: req.body._id}}).exec(function(err, tasks){
						if(err){
							console.log('cannot remove task in room');
						} else {
							console.log('successfully removed task in room');
							User.update({tasks: req.body._id}, {'$pull': {tasks: req.body._id}}).exec(function(err, users){
								if(err){
									console.log('cannot remove task in users')
								} else {
									Message.remove({_task: req.body.id}, function(err, message){
										if(err){
											console.log('cannot remove task in message')
										} else {
											console.log('successfully removed messages for task')
											res.json(message);
										}
									})
								}
							})
						}
					})
				}
			})
			
			
		}


	}
})();