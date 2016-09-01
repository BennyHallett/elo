// pull in desired CSS/SASS files
require( './styles/main.scss' );

// inject bundled Elm app into div#main
var Elm = require( './Elo' );
var app = Elm.Elo.fullscreen();

app.ports.save.subscribe(function (data) {
  localStorage.setItem('elo-state', JSON.stringify(data));
});

window.setTimeout(function() {
    console.log('sending state');
    app.ports.load.send(localStorage.getItem('elo-state'));
}, 100);
