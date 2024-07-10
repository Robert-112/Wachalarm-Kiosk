#!/usr/bin/env node

const waipurl = process.env.npm_config_waipurl;
const wachennr = process.env.npm_config_wachennr;

if (!waipurl || !wachennr) {
  process.exit(1);
};

const io = require('socket.io-client');
const { exec } = require('child_process');

console.log('start', waipurl, wachennr);

const socket = io(waipurl, {
  transports: ['websocket'],
  rejectUnauthorized: false
});

socket.on('connect', function () {
  console.log('connect', wachennr);
  socket.emit('WAIP', wachennr);
});

socket.on('connect_error', (err) => {
  console.log('Socket.IO-Fehler', err.message);
});

socket.on('io.new_waip', function () {
  console.log('AN - Display einschalten');
  var yourscript = exec('~/screen-on.sh', (error, stdout, stderr) => {
    console.log(stdout);
    console.log(stderr);
    if (error !== null) {
      console.log(`exec error: ${error}`);
    };
  });
});

socket.on('io.standby', function () {
  console.log('AUS - Display ausschalten');
  var yourscript = exec('~/screen-off.sh', (error, stdout, stderr) => {
    console.log(stdout);
    console.log(stderr);
    if (error !== null) {
      console.log(`exec error: ${error}`);
    };
  });
});
