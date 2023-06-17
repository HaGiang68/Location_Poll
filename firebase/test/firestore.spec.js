/**
 * Author: Paul van den Berg
 * 
 * Scaffold by  Google LLC
 * Copyright (c) 2020 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * 
 * 
 */
const firebase = require("@firebase/rules-unit-testing");
const { assert } = require("console");
const fs = require("fs");
const http = require("http");
const { start } = require("repl");


//Import constants
const {aVote, PROJECT_ID, myId, theirId, myAuth, myPoll, myPollId, myPoll_noChoices, myPoll_oneChoice, myPoll_missingRequirements, myPoll_missingOwner, myPoll_missingTitle, myPoll_datatype_longLat, myPoll_datatype_time_str, myPoll_datatype_time_float, myPoll_datatype_radius_str, myUserDoc, theirAuth, theirUserDoc} = require("./constants.js");

/**
 * 
 * to run the tests: firebase emulators:exec --only firestore "npm run test-firestore"
 * 
 * Rules deployment status: 
 * 
users
      √ require users to log in before creating a profile (not logged in)
      √ allow user to create own profile document if logged in
      √ user can edit its profile
      √ user can not create profile documents of other users
      √ user can not edit profile documents of other users
      √ user-document: must provide same uid-field as login information
      √ user-document: authLevel must be one of the defined enums
      √ user can only read its own profile
      √ no user can delete any users-document
      √ user can not edit its authLevel
    polls
      √ only logged in users can create poll
      √ only owner can edit a poll
      √ must provide at least 2 choices
      √ all required fields must exist. No more fields are present.
      √ all fields hold correct data Types 
      votes
        √ no user can create a vote document 
        √ no user can update/edit a vote document 
        √ no user can delete a vote document

 */

Date.prototype.addDays = function(days) {
  var date = new Date(this.valueOf());
  date.setDate(date.getDate() + days);
  return date;
}

const adminAuth = { uid: "owner"};

/**
 * The FIRESTORE_EMULATOR_HOST environment variable is set automatically
 * by "firebase emulators:exec"
 */
const COVERAGE_URL = `http://${process.env.FIRESTORE_EMULATOR_HOST}/emulator/v1/projects/${PROJECT_ID}:ruleCoverage.html`;

/**
 * Creates a new client FirebaseApp with authentication and returns the Firestore instance.
 */
function getAuthedFirestore(auth) {
  return firebase
    .initializeTestApp({ projectId: PROJECT_ID, auth })
    .firestore();
};

function getAdminFirestore() {
  return firebase
    .initializeAdminApp({ projectId: PROJECT_ID })
    .firestore();
};

beforeEach(async () => {
  // Clear the database between tests
  await firebase.clearFirestoreData({ projectId: PROJECT_ID });
});

before(async () => {
  // Load the rules file before the tests begin
  const rules = fs.readFileSync("firestore.rules", "utf8");
  await firebase.loadFirestoreRules({ projectId: PROJECT_ID, rules });
});

after(async () => {
  // Delete all the FirebaseApp instances created during testing
  // Note: this does not affect or clear any data
  await Promise.all(firebase.apps().map((app) => app.delete()));

  // Write the coverage report to a file
  const coverageFile = 'firestore-coverage.html';
  const fstream = fs.createWriteStream(coverageFile);
  await new Promise((resolve, reject) => {
      http.get(COVERAGE_URL, (res) => {
        res.pipe(fstream, { end: true });

        res.on("end", resolve);
        res.on("error", reject);
      });
  });

  console.log(`View firestore rule coverage information at ${coverageFile}\n`);
});

describe("My app", () => {
  
//#################### USERS collection Tests #################
  describe("users", () => {
    it("require users to log in before creating a profile (not logged in)", async () => {
      const db = getAuthedFirestore(null);
      const profile = db.collection("users").doc(myId);
      await firebase.assertFails(profile.set(myUserDoc));
    });

    it("allow user to create own profile document if logged in", async () => {
      const db = getAuthedFirestore(myAuth);
      const profile = db.collection("users").doc(myId);
      await firebase.assertSucceeds(profile.set(myUserDoc));
    });

    it("user can edit its profile", async () => {
      const admin = getAdminFirestore();
      const setupProfile = admin.collection("users").doc(myId);
      await setupProfile.set(myUserDoc);

      const db = getAuthedFirestore(myAuth);
      const profile = db.collection("users").doc(myId);
      await firebase.assertSucceeds(profile.update({userName: "newUserName",}));
    });

    it("user can not create profile documents of other users", async () => {
      const mydb = getAuthedFirestore(myAuth); 
      await firebase.assertFails(mydb.collection("users").doc(theirId).set(theirUserDoc));      
    });

    it("user can not edit profile documents of other users", async () => {
      const admin = getAdminFirestore();
      await admin.collection("users").doc(theirId).set(theirUserDoc);

      const mydb = getAuthedFirestore(myAuth); 
      await firebase.assertFails(mydb.collection("users").doc(theirId).update({userName: "newUserName",}));      
    });

    it("user-document: must provide same uid-field as login information", async () => {
      const db = getAuthedFirestore(myAuth);
      const profile = db.collection("users").doc(myId);
      await firebase.assertFails(profile.set({
        uuid: theirId,
      }));
      await firebase.assertSucceeds(profile.set({
        uuid: myId,
      }));
    });

    it("user-document: authLevel must be one of the defined enums", async () => {
      const db = getAuthedFirestore(myAuth);
      const profile = db.collection("users").doc(myId);
      await firebase.assertFails(profile.set({
        authLevel: "WRONG_LEVEL",
      }));
    });

    it("user can only read its own profile", async () => {
      const db = getAuthedFirestore(myAuth);
      const myProfile = db.collection("users").doc(myId);
      const theirProfile = db.collection("users").doc(theirId);
      await firebase.assertSucceeds(myProfile.get());
      await firebase.assertFails(theirProfile.get());
    });

    it("no user can delete any users-document", async () => {
      const db = getAuthedFirestore(myAuth);
      const myProfile = db.collection("users").doc(myId);
      const theirProfile = db.collection("users").doc(theirId);
      await firebase.assertFails(myProfile.delete());
      await firebase.assertFails(theirProfile.delete());
    });    

    it("user can not edit its authLevel", async () => {
      const db = getAuthedFirestore(myAuth);
      const profile = db.collection("users").doc(myId);
      await firebase.assertSucceeds(profile.set(myUserDoc));
      await firebase.assertSucceeds(profile.update({userName: "newUserName",}));
      await firebase.assertFails(profile.update({authLevel: "SMS_VERIFIED",}));

    });
  });


//#################### POLLS collection Tests #################
  describe("polls", () => {

    it("only logged in users can create poll", async () => {
      const logged_out_db = getAuthedFirestore(null);
      const logged_in_db = getAuthedFirestore(myAuth);
      const logged_out_poll = logged_out_db.collection("polls").doc(myPollId);
      const logged_in_poll  = logged_in_db.collection("polls").doc(myPollId);
      await firebase.assertFails(logged_out_poll.set(myPoll));
      await firebase.assertSucceeds(logged_in_poll.set(myPoll));
    });

    it("only owner can edit a poll", async () => {
      const admin = getAdminFirestore();
      const db = getAuthedFirestore(myAuth);
      const poll = db.collection("polls").doc(myPollId);
      await firebase.assertSucceeds(poll.set(myPoll));
      const setupPoll = admin.collection("polls").doc(myPollId);
      await firebase.assertSucceeds(setupPoll.set(myPoll));
      const theirdb = getAuthedFirestore(theirAuth);
      const poll2 = theirdb.collection("polls").doc(myPollId);
      await firebase.assertFails(poll2.update({title: "my New Title",}));
    });

    it("must provide at least 2 choices", async () => {
      const db = getAuthedFirestore(myAuth);
      const poll = db.collection("polls").doc(myPollId);
      await firebase.assertFails(poll.set(myPoll_noChoices));
      await firebase.assertFails(poll.set(myPoll_oneChoice));
      await firebase.assertSucceeds(poll.set(myPoll));
    });

    it("all required fields must exist. No more fields are present.", async () => {
      const db = getAuthedFirestore(myAuth);
      const poll = db.collection("polls").doc(myPollId);
      await firebase.assertFails(poll.set(myPoll_missingRequirements));
      await firebase.assertFails(poll.set(myPoll_missingOwner));
      await firebase.assertFails(poll.set(myPoll_missingTitle));
    })

    it("all fields hold correct data Types", async () => {
      const db = getAuthedFirestore(myAuth);
      const poll = db.collection("polls").doc(myPollId);
      await firebase.assertFails(poll.set(myPoll_datatype_longLat));
      await firebase.assertFails(poll.set(myPoll_datatype_time_str));
      await firebase.assertFails(poll.set(myPoll_datatype_time_float));
      await firebase.assertFails(poll.set(myPoll_datatype_radius_str));
    })

  
//#################### VOTES collection Tests #################
    describe("votes", () => {
      it("no user can create a vote document", async () => {
        const admin = getAdminFirestore();
        const db = getAuthedFirestore(myAuth);
        const vote = db.collection("polls").doc(myPollId).collection("votes").doc(aVote.key);
        await firebase.assertFails(vote.set(aVote));
        await firebase.assertFails(vote.delete());
      });

      it("no user can update/edit a vote document", async () => {
        const admin = getAdminFirestore();
        const db = getAuthedFirestore(myAuth);
        const setupVote = admin.collection("polls").doc(myPollId).collection("votes").doc(aVote.key);
        firebase.assertSucceeds(setupVote.set(aVote));

        const vote = db.collection("polls").doc(myPollId).collection("votes").doc(aVote.key);
        await firebase.assertFails(vote.update({key: "newKey"}));
        await firebase.assertFails(vote.update({newField: "content"}));
        await firebase.assertFails(vote.update({answers: {"0":1}}));
      });

      it("no user can delete a vote document", async () => {
        const admin = getAdminFirestore();
        const db = getAuthedFirestore(myAuth);
        const setupVote = admin.collection("polls").doc(myPollId).collection("votes").doc(aVote.key);
        firebase.assertSucceeds(setupVote.set(aVote));

        const vote = db.collection("polls").doc(myPollId).collection("votes").doc(aVote.key);
        await firebase.assertFails(vote.delete());
      });
    });
  });  
});
