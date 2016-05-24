roomies.factory('roomFactory', function ($http){
	var factory = {};
	factory.index = function (callback){
		$http.get('/rooms').success(function (output){
			if (output){
				callback(output);
			}
		})
	}
	factory.addNewRoom = function (info, callback){
		$http.post('/rooms/create', info).success(function (output){
			if (output) {
				callback(output);
			}
		})
	}
	factory.chooseRoom = function (info, callback){
		console.log(info)
		$http.post('/users/addtoroom', info).success(function (output){
			if (output){
				callback(output);
			}
		})
	}
	return factory
})