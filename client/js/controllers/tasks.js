roomies.controller('taskController', function ($scope, $localStorage, roomFactory, taskFactory, messageFactory){
	$scope.room = $localStorage.room;
	console.log($scope.room);
})