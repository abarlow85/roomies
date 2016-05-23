roomies.controller('taskController', function ($scope, $localStorage, roomFactory){
	$scope.room = $localStorage.room;
	console.log($scope.room);
})