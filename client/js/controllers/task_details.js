roomies.controller('taskDetailsController', function ($scope, $location, $localStorage, taskFactory, messageFactory, socketFactory){
	$scope.room = $localStorage.room;
	$scope.currentUser = $localStorage.user;
	$scope.currentTask = $localStorage.currentTask;
	$scope.messages = [];
	
	$scope.back = function () {
		$location.path('/room/' + $scope.room);	
	}
	$scope.updateTask = function (taskContent, taskId){
		if (taskContent.expiration_time == 'PM'){
			var parsed = parseInt(taskContent.expiration_hour);
			parsed += 12;
			taskContent.expiration_hour = String(parsed);
		}
		var fullTask = {};
		fullTask.objective = taskContent.objective;
		var fulldate = taskContent.expiration_date + " " + taskContent.expiration_hour+':'+taskContent.expiration_minute + " " + taskContent.expiration_time;
		console.log(fulldate);
		fullTask.expiration_date = fulldate;
		fullTask._id = taskId._id;
		taskFactory.updateTask(fullTask, function (data){
			if (data){
				$location.path('/room/' + data._id)
			}
		})
	}
	taskFactory.getTaskById($localStorage.currentTask, function (data){
		$scope.messages = data.messages;
	})


	$scope.addMessage = function (message){
		var newMessage = {};
		newMessage._room = $scope.room;
		newMessage._user = $scope.currentUser._id;
		newMessage._task = $scope.currentTask._id;
		newMessage.content = message;
		console.log(newMessage);
		messageFactory.addMessage(newMessage, function (data){
			if (data){
				$scope.messages.push(data.messages[data.messages.length - 1]);
				$scope.message = "";
			}
		})
	}
})