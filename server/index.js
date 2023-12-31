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
    const uids = new Array();
    const distances = new Array();
    console.log(...outputDistanceArray(out[0], arr));
    outputDistanceArray(out[0], arr).forEach((key, value) => {
      uids.push(key);
      distances.push(value);
    });
    ws.send(distances.concat("0", uids).toString());
  });
});

function outputDistanceArray(localUID, array) {
  const localLoc = arr.get(localUID);
  const output = new Map();

  arr.forEach((val, key) => {
    if (key != localUID) {
      output.set(
        key,
        distanceFormula(localLoc[0], localLoc[1], val[0], val[1])
      );
    }
  });
  return output;
}

function distanceFormula(x1, y1, x2, y2) {
  return (
    2 *
    6378100 *
    Math.sqrt(
      sinSquare(x1, x2) +
        Math.cos((Math.PI / 180) * x1) *
          Math.cos((Math.PI / 180) * x2) *
          sinSquare(y1, y2)
    )
  );
}

function sinSquare(x1, x2) {
  return Math.pow(Math.sin((((x1 - x2) / 2) * Math.PI) / 180), 2);
}
