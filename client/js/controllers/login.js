roomies.controller('loginController', function ($scope, $location, $localStorage){
	$scope.register = function () {
		$localStorage.user = $scope.newUser.name;
		$location.path('room')
	}
})