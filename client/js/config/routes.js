roomies.config(function ($routeProvider){
	$routeProvider
	.when('/', {
		templateUrl: '../partials/login.html'
	})
	.when('/room', {
		templateUrl: '../partials/room.html'
	})
	.when('/room/:id', {
		templateUrl: '../partials/tasks.html'
	})
	.otherwise({
		redirectTo: '/'
	})
});