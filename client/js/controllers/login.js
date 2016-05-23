roomies.controller('loginController', function ($scope, $location, $localStorage, userFactory){
	$scope.newUser = false;
	$scope.toggleForm = function () {
		if ($scope.newUser == false){
			$scope.newUser = true;
		}
		else {
			$scope.newUser = false;
		}
	}
	$scope.userRegister = function (regUser) {
		console.log(regUser);
		userFactory.register(regUser, function (data){
			console.log('Registering: ' + data);
			if (data.error){
				console.log("error")
			}
			else if(data) {
				$localStorage.user = data
				$location.path('/room');
			}
		})
	}
	$scope.userLogin = function (loginUser) {
		userFactory.login(loginUser, function (data){
			console.log('Logging in: ' + data);
			if (data.error){
				console.log('error');
			}
			else if (data){
				$localStorage.user = data
				// $location.path('/room/' + room_id);
			}
		})
	}
})