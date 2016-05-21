var mongoose = require('mongoose');

var Schema = mongoose.Schema;
var roomSchema = new mongoose.Schema({
	name: String,
	category: String,
	users: [{type: Schema.Types.ObjectId, ref: 'User'}],
	tasks: [{type: Schema.Types.ObjectId, ref:'Task'}],
	messages: [{type: Schema.Types.ObjectId, ref: 'Message'}],
	created_at: {type: Date, default: new Date}
});

var Room = mongoose.model('Room', roomSchema);

