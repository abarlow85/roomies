var mongoose = require('mongoose');

var Schema = mongoose.Schema;
var messageSchema = new mongoose.Schema({
	content: String,
	_room: {type: Schema.Types.ObjectId, ref: 'Room'},
	_user: {type: Schema.Types.ObjectId, ref: 'User'},
	_task: {type: Schema.Types.ObjectId, ref: 'Task'}, 
	created_at: {type: Date, default: new Date}
});

var Message = mongoose.model('Message', messageSchema);

