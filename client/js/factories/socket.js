roomies.factory('socketFactory', function (){
	// var socket = io.connect();
	var socket = io.connect({'force new connection': true});
	return {
		on: function (eventName, callback) {
			socket.on(eventName, callback); 
		},
		emit: function (eventName, data){
			socket.emit(eventName, data); 
		}
	}
})