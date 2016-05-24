roomies.factory('userFactory', function ($http){
	var factory = {};
	factory.register = function (info, callback){
		console.log(info);
		$http.post('/register', info).success(function (output){
			if (output.error){
				callback(output);
			}
			else if (output){
				callback(output);
			}
		})
	}
	factory.login = function (info, callback){
		console.log(info);
		$http.post('/login', info).success(function (output){
			if (output.error){
				callback(output);
			}
			else if (output){
				callback(output);
			}
		})
	}
	return factory
})