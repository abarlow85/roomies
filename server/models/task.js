var mongoose = require('mongoose');

var Schema = mongoose.Schema;
var taskSchema = new mongoose.Schema({
	objective: String,
	expiration_date: String,
	completed: {type: String, default: "notcompleted"},
	_room: {type: Schema.Types.ObjectId, ref: 'Room'},
	users: [{type: Schema.Types.ObjectId, ref: 'User'}],
	messages: [{type: Schema.Types.ObjectId, ref: 'Message'}],
	created_at: {type: Date, default: new Date}
});

var Task = mongoose.model('Task', taskSchema);

