#!/usr/bin/env node

const waipurl = process.env.npm_config_waipurl;
const wachennr = process.env.npm_config_wachennr;
let standbyurl = process.env.npm_config_standbyurl;

if (!waipurl || !wachennr) {
  console.log("Variablen waipurl und / oder wachennr nicht gesetzt)");
  process.exit(1);
}

if (!standbyurl) {
  standbyurl = "";
}

const io = require("socket.io-client");
const { exec } = require("child_process");

function isURL(str) {
  // Regular expression for URL validation
  const urlRegex =
    /^(?:(?:https?|ftp):\/\/)?(?:www\.)?[a-z0-9-]+(?:\.[a-z0-9-]+)+[^\s]*$/i;

  return urlRegex.test(str);
}

console.log("start", waipurl, wachennr);

const socket = io(waipurl, {
  transports: ["websocket"],
  rejectUnauthorized: false,
});

socket.on("connect", function () {
  console.log("connect", waipurl, wachennr, standbyurl);
  socket.emit("WAIP", wachennr);
});

socket.on("connect_error", (err) => {
  console.log("Socket.IO-Fehler", err.message);
});

socket.on("io.new_waip", function () {
  if (isURL(standbyurl)) {
    // zum Alarmmonitor-Tab wechseln
    console.log("zum ersten Tab - Alarmmonitor - wechseln");
    exec("xdotool key ctrl+1", (error, stdout, stderr) => {
      if (error) {
        console.error(`Fehler beim Ausführen von xdotool: ${error}`);
        return;
      }
      console.log("zum ersten Tab mit STRG+1 gewechselt");
    });
  } else {
    // Monitor einschalten
    console.log("AN - Display einschalten");
    var yourscript = exec("~/screen-on.sh", (error, stdout, stderr) => {
      console.log(stdout);
      console.log(stderr);
      if (error !== null) {
        console.log(`exec error: ${error}`);
      }
    });
  }
});

socket.on("io.standby", function () {
  if (isURL(standbyurl)) {
    // zweiten Tab im Browser oeffnen und Standby-URL oeffnen
    console.log("zum letzten Tab - Standbyseite - wechseln");
    exec("xdotool key ctrl+9", (error, stdout, stderr) => {
      if (error) {
        console.error(`Fehler beim Ausführen von xdotool: ${error}`);
        return;
      }
      console.log("zum letzten Tab mit STRG+9 gewechselt");
    });
  } else {
    // keine Standby-URl ---> Bildschirm ausschalten
    console.log("AUS - Display ausschalten");
    var yourscript = exec("~/screen-off.sh", (error, stdout, stderr) => {
      console.log(stdout);
      console.log(stderr);
      if (error !== null) {
        console.log(`exec error: ${error}`);
      }
    });
  }
});
