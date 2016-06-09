var express = require('express');
var path = require('path');
var app = express();
var http = require('http').Server(app);
var bodyParser = require('body-parser');
var passport = require('passport');
var session = require('express-session');
var flash = require('connect-flash');
var messages = [];

app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, './client')));
app.use(session({ secret: 'secretroomiekey' }));
app.use(passport.initialize());
app.use(passport.session());
app.use(flash());

require('./server/config/mongoose.js');
require('./server/config/passport.js')(passport);

var server = app.listen(1000, function() {
 console.log('go to localhost:8000')
};

require('./server/config/routes.js')(app, passport, server, http);