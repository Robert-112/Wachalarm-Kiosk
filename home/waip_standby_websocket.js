#!/usr/bin/env node

// Robert Richter, 2025-08-08

let standby_screen = process.env.npm_config_standby_screen;
let standby_tab = process.env.npm_config_standby_tab;

// Standby-Optionen aus den Umgebungsvariablen lesen
if (!standby_screen || standby_screen === "false") {
  standby_screen = false;
}
if (standby_screen === "true") {
  standby_screen = true;
}

// Standby-Tab-Optionen aus den Umgebungsvariablen lesen
if (!standby_tab || standby_tab === "false") {
  standby_tab = false;
}
if (standby_tab === "true") {
  standby_tab = true;
}

// Importiere die benötigten Module
const CDP = require('chrome-remote-interface');
const { exec } = require("child_process");

async function waip_sniffer() {
  
  // mit Chrome DevTools Protocol (CDP) verbinden
  const client = await CDP();

  const { Network, Page } = client;

  await Network.enable();
  await Page.enable();

  // WebSocket-Nachrichten aus Chromium verarbeiten
  Network.webSocketFrameReceived(({ requestId, timestamp, response }) => {

    console.log('WS empfangen:', response);

    // Prüfen, ob die Nachricht ein WebSocket-Frame ist und mit '42' (Socket.io 4) beginnt
    if (typeof response.payloadData === 'string' && response.payloadData.startsWith('42')) {

      // Entferne alles vor dem ersten Komma
      const msg = response.payloadData.substring(response.payloadData.indexOf(',') + 1);

      // Konvertiere die Nachricht in ein JSON-Objekt
      const payload = JSON.parse(msg);

      const event = payload[0];
      const eventData = payload[1];

      console.log('Event:', event);

      if (event === 'io.standby') {
        console.log('Standby erkannt');

        // Monitor ausschalten
        if (standby_screen) {
          console.log("AUS - Display ausschalten");
          var yourscript = exec("~/screen-off.sh", (error, stdout, stderr) => {
            console.log(stdout);
            console.log(stderr);
            if (error !== null) {
              console.log(`exec error: ${error}`);
            }
          });
        }

        // Zum Standby-Tab wechseln
        if (standby_tab) {
          console.log("zum letzten Tab - Standbyseite - wechseln");
          exec("xdotool key ctrl+9", (error, stdout, stderr) => {
            if (error) {
              console.error(`Fehler beim Ausführen von xdotool: ${error}`);
              return;
            }
            console.log("zum letzten Tab mit STRG+9 gewechselt");
          });
        }
      }
      if (event === 'io.new_waip') {
        console.log('Einsatz erkannt');

        // Monitor einschalten
        if (standby_screen) {
          console.log("AN - Display einschalten");
          var yourscript = exec("~/screen-on.sh", (error, stdout, stderr) => {
            console.log(stdout);
            console.log(stderr);
            if (error !== null) {
              console.log(`exec error: ${error}`);
            }
          });
        }

        // Zum Alarmmonitor-Tab wechseln
        if (standby_tab) {
          console.log("zum ersten Tab - Alarmmonitor - wechseln");
          exec("xdotool key ctrl+1", (error, stdout, stderr) => {
            if (error) {
              console.error(`Fehler beim Ausführen von xdotool: ${error}`);
              return;
            }
            console.log("zum ersten Tab mit STRG+1 gewechselt");
          });
        }
      }
    }
  });
}

console.log('start', 'Display:', standby_screen, 'Tab:', standby_tab);
waip_sniffer();
