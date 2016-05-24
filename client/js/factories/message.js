roomies.factory('messageFactory', function ($http){
	var factory = {};
	factory.addMessage = function (info, callback){
		$http.post('/messages/create', info).success(function (output){
			if (output){
				callback(output);
			}
		})
	}

	return factory
})