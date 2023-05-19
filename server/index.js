const express = require("express");
const { Server } = require("ws");

const PORT = 3000; //port for https

const server = express()
  .use((req, res) => res.send("Hi there"))
  .listen(PORT, () => console.log(`Listening on ${PORT}`));

const wss = new Server({ server });

const arr = new Map();

wss.on("connection", function (ws, req) {
  console.log("hit");
  ws.on("message", (message) => {
    var dataString = message.toString();
    out = dataString.split(",");
    if (out[0] != 0) {
      arr.set(out[0], new Array(out[1], out[2]));
    }
    console.log(outputDistanceArray());
  });
});

function outputDistanceArray(localUID) {
  const localLoc = new Array(arr.get(localUID));

  const output = new Map();
  for (uid in arr) {
    remLoc = arr.get(uid);
    output.set(
      uid,
      outputdistanceFormula(localLoc[0], localLoc[1], remLoc[0], remLoc[1])
    );
  }
  return output;
}

function distanceFormula(x1, y1, x2, y2) {
  return Math.sqrt(x2 * x2 - x1 * x1 + (y2 * y2 - y1 * y1));
}
