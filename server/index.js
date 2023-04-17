const express = require("express");
const { Server } = require("ws");

const PORT = process.env.PORT || 1000; //port for https

const server = express()
  .use((req, res) => res.send("Hi there"))
  .listen(PORT, () => console.log(`Listening on ${PORT}`));

const wss = new Server({ server });

const arr = new Map();

wss.on("connection", function (ws, req) {
  ws.on("message", (message) => {
    var dataString = message.toString();
    out = dataString.split(",");
    if (out[0] != 0) {
      arr.set(out[0], out);
    }
    console.log(out[0]);
    console.log(out[1]);
    console.log(arr);
  });
});
