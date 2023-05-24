const express = require("express");
const { Server } = require("ws");

const PORT = 3000; //port for https

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
      arr.set(out[0], new Array(out[1], out[2]));
    }
    console.log(arr);
    const uids = new Array();
    const distances = new Array();
    console.log(...outputDistanceArray(out[0], arr));
    outputDistanceArray(out[0], arr).forEach((key, value) => {
      uids.push(key);
      distances.push(value);
    });
    ws.send(uids.concat(" ", distances));
  });
});

function outputDistanceArray(localUID, array) {
  const localLoc = arr.get(localUID);
  const output = new Map();

  arr.forEach((val, key) => {
    console.log("uid:" + key);
    console.log("val:" + val);
    output.set(key, distanceFormula(localLoc[0], localLoc[1], val[0], val[1]));
  });
  return output;
}

function distanceFormula(x1, y1, x2, y2) {
  return Math.sqrt(x2 * x2 - x1 * x1 + (y2 * y2 - y1 * y1));
}
