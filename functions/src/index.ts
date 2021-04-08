import * as functions from "firebase-functions";
import * as admin from "firebase-admin"; // firebaseStore
import * as express from "express"; // REST API 프레임워크
import {addEntry} from "./entryController";

const app = express();
app.post("/entries", addEntry);
app.get("/", (req, res) => res.status(200).send("Hey there!"));
exports.app = functions.https.onRequest(app);

const db = admin.firestore();
export {admin, db};

export const randomNumber =
functions.https.onRequest((request, response) => {
  console.log("request.body => ", request.body);
  // 왜 안찍힐까?
  // FIXME: body parser가 필요함!!
  console.log("xxxxx => " + request.body.title);
  const number = Math.round(Math.random() * 100);
  console.log(number);
  response.send(number.toString());
});

export const toTheQbbangBlog =
functions.https.onRequest((request, response) => {
  response.redirect("https://www.qbbang.me");
});

// firestore trigger for tracking activity
export const logActivities =
functions.firestore.document("/{collection}/{id}").onCreate((snap, context) => {
  console.log(snap.data());
  const collection = context.params.collection;
  const id = context.params.id;
  console.log(id);
  const activities = admin.firestore().collection("activities");
  if (collection === "requests" ) {
    return activities.add({text: "a new tutorial request was added"});
  }
  if (collection === "users" ) {
    return activities.add({text: "a new user signed up"});
  }
  return null;
});
