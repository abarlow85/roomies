roomies.factory('taskFactory', function ($http){
	var factory = {};
	factory.getRoomById = function (info, callback){
		$http.get('/rooms/' + info).success(function (output){
			if (output){
				console.log(output);
				callback(output);
			}
		})
	}
	factory.getTaskById = function (info, callback){
		console.log(info);
		$http.get('/tasks/' + info._id).success(function (output){
			console.log(output);
			callback(output);
		})
	}
	factory.createTask = function (info, callback){
		console.log(info);
		$http.post('/tasks/create', info).success(function (output){
			if (output){
				console.log(output);
				callback(output);
			}
		})
	}
	factory.updateTask = function (info, callback){
		console.log(info);
		var paramId = info._id;
		var task = {};
		task.objective = info.objective;
		task.expiration_date = info.expiration_date;
		$http.post('/tasks/update/' + paramId, task).success(function (output){
			if (output){
				callback(output)
			}
		})
	}
	factory.removeTask = function (info, callback){
		$http.post('/tasks/remove', info).success(function (output){
			if (output){
				callback(output)
			}
		})
	}
	factory.completeTask = function (info, callback){
		$http.post('/tasks/complete', info).success(function (output){
			if (output){
				callback(output);
			}
		})
	}

	return factory
})