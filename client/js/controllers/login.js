roomies.controller('loginController', function ($scope, $location, $localStorage, userFactory, socketFactory){
	$scope.newUser = false;
	$localStorage.login = true;
	$scope.toggleForm = function () {
		$scope.loginError = ""
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
				$scope.loginError = data.error;
			}
			else if (data){
				console.log(data)
				console.log(data._lastRoom);
				var room_id = data._lastRoom;
				$localStorage.user = data;
				$localStorage.room = data._lastRoom;
				$location.path('/room/' + room_id);
			}
		})
	}
})