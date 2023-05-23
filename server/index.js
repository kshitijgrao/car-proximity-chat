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
    const uids = new Array();
    const distances = new Array();
    outputDistanceArray().forEach((key, value) => {
      uids.append(key);
      distances.append(value);
    });
    console.log(uids.concat(" ", distances));
    ws.send(uids.concat(" ", distances));
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
  return 2 * (6378100) * Math.sqrt(sinSquare(x1,x2)+Math.cos(Math.PI/180 * x1) * Math.cos(Math.PI / 180 * x2) * sinSquare(y1,y2))
}

function sinSquare(x1,x2){
  return Math.pow(Math.sin((x1-x2)/2 * Math.PI/180),2)
}
