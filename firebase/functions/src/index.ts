/**
 * Author: Paul van den Berg and Dirk Leiacker
 * 
 * Scaffold by  Google Inc.
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
*/

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as mysql from "mysql";
import {dbCredentials as dbCredentials} from "./db_credentials";
var syncSql = require('sync-sql');
const cors = require('cors')({ origin: true });

admin.initializeApp(functions.config().firebase);
const db = admin.firestore();

//######################START SQL Service #####################################
const connect = {
  user: dbCredentials["user"], // e.g. 'my-db-user'
  password: dbCredentials["password"], // e.g. 'my-db-password'
  database: dbCredentials["database"], // e.g. 'my-database'
  host: dbCredentials["host"], // e.g. '127.0.0.1'
  port: dbCredentials["port"],// e.g. '3306'
  connectionLimit: 1,
  connectTimeout: 10000, //10 seconds
  acquireTimeout: 10000, // 10 seconds
  waitForConnections: true, // Default: true
  queueLimit: 0, // Default: 0
}

const createPool = async () => {
  return mysql.createPool(connect);
};

const createPoolAndEnsureSchema = async () =>
  await createPool()
    .then(async pool => {
      return pool;
    })
    .catch(err => {
      throw err;
    });
let dbConnection: mysql.Pool;

/**
 * 
 * @param query_str 
 * @param query_vars 
 * @returns undefined if error occurs.
 */
async function sendSQLQuery(query_str: string, query_vars?: any) {
  let statement: string;
  if (query_vars === undefined) {
    statement = query_str;
  } else {
    statement = mysql.format(query_str, query_vars);
  }

  functions.logger.info(`SQLQuery: ${statement}`);

  dbConnection = dbConnection || (await createPoolAndEnsureSchema());

  try {
    const query_result = syncSql.mysql(connect, statement); //run the SQL Statement.
    const err = query_result.data.err;
    const rows = query_result.data.rows;
    const _fields = query_result.data.fields;

    if (err) {
      functions.logger.error(`Error in SQL Query: ${JSON.stringify(err)}`);
      return undefined;
    }
    functions.logger.info(`SQL Returned: ${JSON.stringify(rows)}, fields: ${JSON.stringify(_fields)}`);
    return rows;

  } catch (err) {
    functions.logger.error(err)
    return undefined;
  }
  return "fuck, I shouldnt be here.";
}

//######################END SQL Service #####################################


/**
 * 
 * @param authToken 
 * @returns the uid : string or undefined. corresponding to the submitted authToken if the AuthToken is valid.
 *                                         If the authToken is invalid, undefined is returned.
 */
let getUIDfromIDToken = async (authToken: string, skipFirebaseAuth: boolean): Promise<string | undefined> => {
  functions.logger.info(`ID-Token: -${authToken}-`);

  let ret: string | undefined = undefined;
  authToken = authToken.split('Bearer')[1].trim();

  if (skipFirebaseAuth) {
    functions.logger.info(`The Firebase UserAuthentication is being skipped. The provided string will be used as uid.`)
    ret = authToken;
    //uid = undefined;
  } else {
    functions.logger.info(`The Auth-ID-Token is: ${authToken}`);
    if (authToken !== undefined) {
      await admin.auth().verifyIdToken(authToken)
        .then((decodedToken) => { ret = decodedToken.uid; })
        .catch((err) => {
          functions.logger.error(`Error in Auth Token Verifying: ${err}`);
          ret = undefined;
        });
    }
  }
  functions.logger.info(`getUIDfromIDToken returned: ${ret}`);
  if (ret === undefined) {
    functions.logger.error(`Decoding Firebase ID Token failed. The provided Token was: ${authToken}`);
  }
  return ret;
}


exports.auth = functions
  .region('europe-west3')
  .https.onRequest((req, res) => {
    cors(req, res, () => {
      const tokenId = req.get('Authorization');//.split('Bearer ')[1];
      functions.logger.info(`ID-Token: -${tokenId}-`);
      if (tokenId !== undefined) {
        return admin.auth().verifyIdToken(tokenId)
          .then((decoded) => res.status(200).send(decoded))
          .catch((err) => {
            functions.logger.error(`error : ${err}`)
            res.status(401).send(err);
          });
      }
      return res.status(401).send("error");
    });
  });



/**
 * - A User can request new keys to vote for the polls he submits. 
 * @param request-body must contain a JSON Object with a field "pollIds" that holds a list with the requested Poll-IDs.
 * {
 *    pollIds: [
 *                poll_id1, 
 *                poll_id2
 *              ]
 *    
 * }
 * @param request-header the "Authorization" field must hold the JWT Token of the firebase user: (see: https://firebase.google.com/docs/auth/admin/verify-id-tokens#retrieve_id_tokens_on_clients)
 * 
 * @returns A JSON Object containing the pollIDs and keys for the polls the user got no keys for.
 * {
 *    polls: [
 *             {
 *                 "key": "d76a1e63b4313e4e5780c3c47b0eb91d",
 *                 "poll_id": "0.008885798229917308"
 *             },
 *             {
 *                 "key": "ae6ee97b17402c0f21646316e7639128",
 *                 "poll_id": "0.5776163791698585"
 *             }
 *           ]
 * 
 * }
 * 
 */
export const requestKeysForPolls = functions
  .region('europe-west3')
  .https.onRequest(async (request, response) => {

    functions.logger.info(`Function was called with body: ${JSON.stringify(request.body)}`);
    let pollIds_raw: string[] = request.body.data.pollIds;
    let return_Message: string = "";

    //BEGIN: get the uuid
    //Verify the User by the provided Authentication JWT Token (see: https://firebase.google.com/docs/auth/admin/verify-id-tokens#retrieve_id_tokens_on_clients)
    const skipFirebaseAuth: boolean = false;
    const authTokenId = request.get('Authorization');
    let uid: string | undefined;

    if (authTokenId === undefined) { //There has no Auth Token been transfered.
      let errStr = "Error: There has no Authentication Token been transferred. Verify the User by the provided Authentication JWT Token in the Header-Field `Authorization`. (see: https://firebase.google.com/docs/auth/admin/verify-id-tokens#retrieve_id_tokens_on_clients)";
      functions.logger.error(errStr);
      response.status(401).send(errStr).end();
      return;
    }
    else {
      uid = await getUIDfromIDToken(authTokenId, skipFirebaseAuth);
      if (uid === undefined) {  //if undefined is thrown, then exit the function because the user is not a valid user.
        let errStr = "Error: The transmitted AuthenticationToken is not valid. (check: https://firebase.google.com/docs/auth/admin/verify-id-tokens#retrieve_id_tokens_on_clients)";
        functions.logger.error(errStr);
        response.status(403).send(errStr).end();
        return;
      }
      functions.logger.info(`The provided AuthToken is valid. The corresponding uuid is ${uid}. [Trying to fetch vote keys for ${JSON.stringify(pollIds_raw)}]`);
    }
    //END: get the uuid

    //check that the fields pollids and answers are given syntactically correct.
    if (pollIds_raw === undefined) {
      let errStr = "Error: The pollIds field is missing or incorrect formated.";
      functions.logger.error(errStr);
      response.status(400).send(errStr).end();
      return;
    }

    //BEGIN: get all valid pollIds.
    pollIds_raw = [...new Set(pollIds_raw)]; //remove duplicates from pollIDs list.
    //check that the pollIds are  polls existing in the DB
    for (let index in pollIds_raw) {
      //functions.logger.info(`in for loop: the pollId is: ${pollIds_raw[index]}`);
      try {
        const docRef = db.doc(`polls/${pollIds_raw[index]}`);
        const doc = await docRef.get();
        if (!doc.exists) {
          let errStr = `Warning: poll with transmitted pollId ${pollIds_raw[index]} does not exist.`;
          functions.logger.error(errStr);
          return_Message = return_Message.concat('\n', errStr);
          if (+index > -1) { //+index converts the string into a number.
            delete pollIds_raw[index];
          }
        }
      } catch (error) {
        console.log("Error getting document:", error);
      }
    }

    //check, that there is at least one poll that is valid. Export all the valid Polls into pollIds.
    let pollIds: string[] = [];
    for (let pollId in pollIds_raw) {
      if (pollId !== undefined) {
        pollIds.push(pollIds_raw[pollId]);
      }
    }
    functions.logger.info(`Validated ${pollIds.length} of ${pollIds_raw.length} submitted pollIds.`)
    if (pollIds.length === 0) {
      let errStr = "Error: No transmitted PollId exists.";
      functions.logger.error(errStr);
      response.status(400).send(errStr).end();
      return;
    }
    //END: get all valid pollIds.

    //BEGIN: request new keys for the polly by the SQLAuthDB
    let err_begin = await sendSQLQuery("START TRANSACTION;")  //start the transaction
    if (err_begin === undefined) {//If undefined is returned, then the SQL Query had an error. (like malformed query)
      response.status(403)
        .send("The SQL Query returned with an error. Check the logs for detailed information.")
        .end();
      return;
    }

    //get the distributions to the submitted pollid-uid.
    let query_vars_select = pollIds;
    let query_str_select = `SELECT (\`poll_id\`) from \`distribution\` where `;
    functions.logger.info(`The pollIds: ${JSON.stringify(pollIds)}`);
    for (let index in pollIds) {
      if (+index != 0) { // +index converts index to num
        query_str_select = query_str_select.concat(" OR ")
      }
      query_str_select = query_str_select.concat(` (\`distribution\`.\`uuid\` = '${uid}' and \`distribution\`.\`poll_id\` = ?) `);
    }
    query_str_select = query_str_select.concat(";");
    let already_distributed = await sendSQLQuery(query_str_select, query_vars_select);
    if (already_distributed === undefined) { //If undefined is returned, then the SQL Query had an error. (like malformed query)
      await sendSQLQuery("ROLLBACK;");
      response.status(403)
        .send("The SQL Query returned with an error. Check the logs for detailed information.")
        .end();
      return;
    }
    //remove pollIds that are already in the db. The user should already obtain the keys for these polls.
    for (let index in already_distributed) {
      let pollId = already_distributed[index]["poll_id"];
      let pollIds_index = pollIds.indexOf(pollId);
      if (pollIds_index > -1) {
        pollIds = [...pollIds.slice(0, pollIds_index), ...pollIds.slice(pollIds_index + 1)]; //remove the element from the array
      }
    }
    if (pollIds.length === 0) {
      let errStr = "Info: All transmitted polls already have a voting key for this user.";
      functions.logger.info(errStr);
      response.status(200).send({"data":{}}).end();
      return;
    }

    //insert all pollIds into the key table to get the keys.
    let query_vars_keys = [];
    for (let index in pollIds) {
      query_vars_keys.push([pollIds[index]]);
    }
    query_vars_keys = [query_vars_keys];
    const query_str_keys = `INSERT IGNORE INTO \`keys\` (\`poll_id\`) VALUES ? RETURNING (\`key\`), (\`poll_id\`);`;
    let new_keys = await sendSQLQuery(query_str_keys, query_vars_keys);
    if (new_keys === undefined) { //If undefined is returned, then the SQL Query had an error. (like malformed query)
      await sendSQLQuery("ROLLBACK;");
      response.status(403)
        .send("The SQL Query returned with an error. Check the logs for detailed information.")
        .end();
      return;
    }

    //insert all the poll_id-uuid pairs into the distribution table.
    let query_vars_dist = pollIds;
    let query_str_dist = `INSERT IGNORE INTO \`distribution\` (\`uuid\`,\`poll_id\`) VALUES `;
    for (let index in query_vars_dist) {
      if (+index != 0) {
        query_str_dist = query_str_dist.concat(", ");
      }
      query_str_dist = query_str_dist.concat(` ('${uid}', ? ) `);
    }
    query_str_dist = query_str_dist.concat(";");

    let err_dist = await sendSQLQuery(query_str_dist, query_vars_dist);
    if (err_dist === undefined) { //If undefined is returned, then the SQL Query had an error. (like malformed query)
      await sendSQLQuery("ROLLBACK;");
      response.status(403)
        .send("The SQL Query returned with an error. Check the logs for detailed information.")
        .end();
      return;
    }

    let err = await sendSQLQuery("COMMIT;")  //end the transaction
    if (err === undefined) {//If undefined is returned, then the SQL Query had an error. (like malformed query)
      response.status(403)
        .send("The SQL Query returned with an error. Check the logs for detailed information.")
        .end();
      return;
    }
    //END: request new keys for the polly by the SQLAuthDB

    response
      .status(200)
      .send({ "data": { "polls": new_keys } })
      .end();

    return
  });

//  user document interface
interface userDoc {
  authLevel: "EMAIL_VERIFIED" | "SMS_VERIFIED" | "UNVERIFIED",
  userName?: string,
  uuid: string,
  email?: string,
  phoneNumber?: string,
}

/**
 * Automatically create a new user document when a new user signed up.
 * The fields email, userName and phoneNumber only get added
 *  if there is valid data in the auth.user
 */
exports.createProfile = functions
  .region('europe-west3')
  .auth.user().onCreate((user) => {
    const userObject: userDoc = {
      uuid: user.uid,
      authLevel: user.emailVerified ? "EMAIL_VERIFIED" : "UNVERIFIED",
      ...(user.email ? { email: user.email } : {}),
      ...(user.phoneNumber ? { phoneNumber: user.phoneNumber } : {}),
      ...(user.displayName ? { userName: user.displayName } : {}),
    };
    return admin.firestore().doc("users/" + user.uid).set(userObject);
  });

/**
 * The Body has to look like the following:
 * {
 *   "key": "ab2d6829a9f6939e1d584f44fbda8c3e",
 *   "pollId": "_aaaaaa-poll_id100",
 *   "answers": {
 *       "0": 0
 *   }
 * }
 *  The answers dict has the question IDs as keys and the selected choice-id as value.
 * 
 * Returns status ode 200 and text "1" if successful. 
 * Otherwise error status codes will be thrown with corresponding error messages.
 */
export const submitSelection = functions
  .region('europe-west3')
  .https.onRequest(async (request, response) => {
    let key: string = request.body.data.key;
    let pollId: string = request.body.data.pollId;
    let answers: Map<number, number> = request.body.data.answers;

    //check that the fields key, pollid and answers are given syntactically correct.
    if (key === undefined || pollId === undefined || answers === undefined) {
      let errStr = "Error: The key, pollId and/or answers field are missing or incorrect formated.";
      functions.logger.error(errStr);
      response.status(400).send(errStr).end();
      return;
    }
    //check that the pollId is a poll existing in the DB

    //check that the pollId is a poll existing in the DB
    try {
      const docRef = db.doc(`polls/${pollId}`);
      const doc = await docRef.get();
      if (!doc.exists) {
        let errStr = "Error: poll with transmitted pollId does not exist.";
        functions.logger.error(errStr);
        response.status(404).send(errStr).end();
        return;
      } else { //check if poll is active at the moment of submission
        const data = doc.data();
        if (data !== undefined) {
          const startTime = data.requirements.timeRequirement.startTime;
          const endTime   = data.requirements.timeRequirement.endTime;
          const currentTime = admin.firestore.Timestamp.now().toMillis();
          if ( currentTime < startTime  || endTime < currentTime) {
            let errStr = `Error: Poll not active. You can not vote at the moment. Servertime: ${currentTime}, starttime: ${startTime}, endTime: ${endTime}`;
            functions.logger.error(errStr);
            response.status(403).send(errStr).end();
            return;
          }
        }
      }
    } catch (error) {
      console.log("Error getting document:", error);
    }

    //BEGIN: get the uuid
    //Verify the User by the provided Authentication JWT Token (see: https://firebase.google.com/docs/auth/admin/verify-id-tokens#retrieve_id_tokens_on_clients)
    const skipFirebaseAuth: boolean = false;
    const authTokenId = request.get('Authorization');
    let uid: string | undefined;

    if (authTokenId === undefined) { //There has no Auth Token been transfered.
      let errStr = "Error: There has no Authentication Token been transferred. Verify the User by the provided Authentication JWT Token in the Header-Field `Authorization`. (see: https://firebase.google.com/docs/auth/admin/verify-id-tokens#retrieve_id_tokens_on_clients)";
      functions.logger.error(errStr);
      response.status(401).send(errStr).end();
      return;
    }
    else {
      uid = await getUIDfromIDToken(authTokenId, skipFirebaseAuth);
      if (uid === undefined) {  //if undefined is thrown, then exit the function because the user is not a valid user.
        let errStr = "Error: The transmitted AuthenticationToken is not valid. (check: https://firebase.google.com/docs/auth/admin/verify-id-tokens#retrieve_id_tokens_on_clients)";
        functions.logger.error(errStr);
        response.status(403).send(errStr).end();
        return;
      }
      functions.logger.info(`The provided AuthToken is valid. The corresponding uuid is ${uid}. [Trying to submit vote on poll-id: ${pollId} with key: ${key}]`);
    }
    //END: get the uuid

    //BEGIN: check the pollid and key with the SQLAuthDB
    //Test if the key and pollid is in the keys table.
    let query_vars = [key, pollId];
    const query_str = `SELECT (EXISTS (SELECT 1 FROM \`keys\` WHERE \`keys\`.\`key\` = ? AND \`keys\`.\`poll_id\` = ? LIMIT 1)) AS \`isValid\`;`;
    let isValid = await sendSQLQuery(query_str, query_vars);
    if (isValid === undefined) { //If undefined is returned, then the SQL Query had an error. (like malformed query)
      response.status(403)
        .send("The SQL Query returned with an error. Check the logs for detailed information.")
        .end();
      return;
    }
    if (isValid[0]["isValid"] != 1) { //if 0 is returned, then the key is not valid for the poll.
      response.status(403)
        .send("The submitted key is not valid for the given poll.")
        .end();
      return;
    }
    //END: check the pollid and key with the SQLAuthDB

    //BEGIN: update the Vote document.
    functions.logger.info(`Key: ${key}`);
    db.doc(`polls/${pollId}/votes/${key}`).set({
      'key': key,
      'answers': answers,
    });
    functions.logger.info(`Wrote to ${pollId}: ${answers}`);
    //END: update the Vote document.
    //response.status(200).json({ "data": {} });
    response.status(200).send({"data":{}}).end();
    return;
  });

export const updateVoteCount = functions
  .region('europe-west3')
  .firestore.document(`polls/{docId}/votes/{key}`).onWrite((change, context) => {
    const docRef = db.doc(`polls/${context.params.docId}`);
    db.runTransaction(async (t: admin.firestore.Transaction) => {
      const doc = await t.get(docRef);
      const before = change.before?.data()?.answers;
      const after = change.after.data()?.answers;

      functions.logger.info(`beforeObject: ${JSON.stringify(change.before.data())}`);
      functions.logger.info(`BeforeMap: ${JSON.stringify(before)}`);
      functions.logger.info(`AfterMap: ${String(after)}`);

      let questionCount = doc.data()?.questions.length;
      let decrementList: number[] = new Array<number>(questionCount);
      let incrementList: number[] = new Array<number>(questionCount);

      for (const key in after) {
        functions.logger.info(`${key}, ${after[key]}`);
      }

      for (const questionIdString in after) {
        let questionId = Number(questionIdString);
        let afterChoice = after[questionIdString];
        if (before === undefined && afterChoice !== undefined) {
          incrementList[questionId] = afterChoice;
        }
        else {
          let beforeChoice = before[questionIdString];
          if (beforeChoice != afterChoice && afterChoice !== undefined) {
            incrementList[questionId] = afterChoice;
          }
        }
      }

      if (before !== undefined) {
        for (const questionIdString in before) {
          let questionId = Number(questionIdString);
          let beforeChoice = before[questionIdString];
          let afterChoice = after[questionIdString];
          if (afterChoice == null && beforeChoice !== undefined) {
            decrementList[questionId] = beforeChoice;
          }
          else {
            if (afterChoice != beforeChoice && beforeChoice !== undefined) {
              decrementList[questionId] = beforeChoice;
            }
          }
        }
      }
      let newQuestions = doc.data()?.questions;
      for (var i = 0; i < questionCount; i++) {
        newQuestions[i].choices[incrementList[i]].counter += 1;
        if (before !== undefined) { newQuestions[i].choices[decrementList[i]].counter -= 1; }
      }
      t.update(docRef, {
        "questions": newQuestions
      });
    });
  });

/** 
 * 
 * Schedule a notification on the start time of a newly created Poll. 
 */
export const schedulePollStartingNotification = functions
  .region('europe-west3')
  .firestore.document(`polls/{pollId}`)
  .onWrite(async (change, context) => {
    const messagesDocRef = db.doc(`messaging/messages`);

    //get pollId
    var pollTitle = "noPollTitleAvailable";
    var startTime = -1;
    const pollId = context.params.pollId;

    //check if this is a delete operation
    if (!change.after.exists) {
      //remove the scheduled event from the messaging/messages document
      await messagesDocRef.update({
        [pollId]: admin.firestore.FieldValue.delete()
      });
    }

    //get pollTitle, startTime
    const docRef = db.doc(`polls/${pollId}`);
    const doc = await docRef.get();
    if (!doc.exists) {
      functions.logger.warn(`Document ${pollId} does not exist.`)
      return;
    } else {
      const data = doc.data();
      if (data !== undefined) {
        pollTitle = data.title;
        startTime = data.requirements.timeRequirement.startTime;
        functions.logger.info(`Poll with Title '${pollTitle}' and StartTime ${startTime} was created. (PollId: ${pollId})`);
      }
      else {
        functions.logger.warn(`Document ${pollId} does not exist or has invalid data.`);
        return;
      }
    }
    //check if correct title and time could get extracted.
    if (pollTitle == 'noPollTitleAvailable' || startTime == -1) {
      functions.logger.warn(`Could not extract title or startTime. No message will be scheduled.`)
      return;
    }

    // Notification details.
    const title = 'A new Poll has started';
    const body = `Vote now on '${pollTitle}'`;

    functions.logger.info(`Scheduling a push Notification for time: '${startTime}' with title: '${title}', body: '${body}'. \n It is stored in document messaging/messages`);

    //save the scheduled message.
    await messagesDocRef.update({ [pollId]: { "title": title, "body": body, "time": startTime } });
    return;
  });


/**
 * - A User can send his FCM Token to get stored in firebase. This way he can recive notifications. 
 * @param request-body must contain a JSON Object with a field "token" that holds the FCM Token previously obtained by firebase.
 * {
 *    "data": {token: "myFCMToken"}
 * }
 * @param request-header the "Authorization" field must hold the JWT Token of the firebase user: (see: https://firebase.google.com/docs/auth/admin/verify-id-tokens#retrieve_id_tokens_on_clients)
 * 
**/
export const storeFCMToken = functions
  .region('europe-west3')
  .https.onRequest(async (request, response) => {

    //check that the field token is present.
    let token: string = request.body.data.token;
    if (token === undefined) {
      let errStr = `Error: The token field is missing or incorrect formated. Message Body was: ${JSON.stringify(request.body.data)}`;
      functions.logger.error(errStr);
      response.status(400).send(errStr).end();
      return;
    }

    //BEGIN: get the uuid
    //Verify the User by the provided Authentication JWT Token (see: https://firebase.google.com/docs/auth/admin/verify-id-tokens#retrieve_id_tokens_on_clients)
    const skipFirebaseAuth: boolean = false;
    const authTokenId = request.get('Authorization');
    let uid: string | undefined;

    if (authTokenId === undefined) { //There has no Auth Token been transfered.
      let errStr = "Error: There has no Authentication Token been transferred. Verify the User by the provided Authentication JWT Token in the Header-Field `Authorization`. (see: https://firebase.google.com/docs/auth/admin/verify-id-tokens#retrieve_id_tokens_on_clients)";
      functions.logger.error(errStr);
      response.status(401).send(errStr).end();
      return;
    }
    else {
      uid = await getUIDfromIDToken(authTokenId, skipFirebaseAuth);
      if (uid === undefined) {  //if undefined is thrown, then exit the function because the user is not a valid user.
        let errStr = "Error: The transmitted AuthenticationToken is not valid. (check: https://firebase.google.com/docs/auth/admin/verify-id-tokens#retrieve_id_tokens_on_clients)";
        functions.logger.error(errStr);
        response.status(403).send(errStr).end();
        return;
      }
      functions.logger.info(`The provided AuthToken is valid. The corresponding uuid is ${uid}.`);
    }
    //END: get the uuid

    //store/update token to messaging/tokens
    const tokensDocRef = db.doc(`messaging/tokens`);
    tokensDocRef.update({ [uid]: token });
    //response.status(200).json({ "data": {} });
    response.status(200).send({"data":{}}).end();
    return;
  });

/**
 * This function checks on an interval of 1 minute if there are polls that just started to send a notifications to all devices.
 */
exports.checkAndSendNotificationsService = functions
  .region('europe-west3')
  .pubsub.schedule('every 1 mins')
  .onRun(async (context) => {
    functions.logger.info('checkAndSendNotificationsService is running on its interval of 1 minute.');
    var notifications: { pollId: string; title: any; body: any; }[] = [];
    const currentTime = Date.now();
    functions.logger.info(`current Time is ${currentTime}`);

    //get all scheduled notifications from messaging/messages and check if there are polls where startdate < currentTime (they started)
    const messagesDocRef = db.doc(`messaging/messages`);
    const messagesDoc = await messagesDocRef.get();
    if (!messagesDoc.exists) {
      functions.logger.warn(`Document 'messaging/messages' does not exist. No messages can be sent.`);
      return;
    }
    const messagesData = messagesDoc.data();
    var messageCount = 0;
    if (messagesData !== undefined) {
      const messages = new Map(Object.entries(messagesData));
      messages.forEach((key, value) => {
        messageCount++;
        var pollId = value;
        var title = key.title;
        var body = key.body;
        var startTime = key.time;
        if (startTime < currentTime) { //check if poll started
          notifications.push({ pollId: pollId, title: title, body: body });
        }
        return;
      });
    }

    //if no polls started: no notifications have to be send. return.
    if (notifications.length == 0) {
      functions.logger.info(`There are no messages to be sent now. ( ${messageCount} messages are pending.)`);
      return;
    }

    //get messaging Tokens
    var registrationTokens: string[] = []; // These registration tokens come from the client FCM SDKs. They are stored at messagingTokens/tokens.
    const tokensDocRef = db.doc(`messaging/tokens`);
    const tokensDoc = await tokensDocRef.get();
    if (!tokensDoc.exists) {
      functions.logger.warn(`Document 'messaging/tokens' does not exist. But needs to exist for Cloud messaging to work.`)
      return;
    } else {
      const data = tokensDoc.data();      
      if (data !== undefined) {
        const docDataMap = new Map(Object.entries(data));        
        docDataMap.forEach((key, value) => {          
          typeof key === 'string' ? registrationTokens.push(key) :
            functions.logger.warn(`The value ${value} of user ${key} in the messaging/tokens is not a string. It will be ignored.`);
        });
        functions.logger.info(`There are Notifications to be triggered. Extracted the FCM messaging tokens: ${JSON.stringify(registrationTokens)}`);
      }
    }

    //for every pending notification: send Notification to users on the tokens extracted.
    notifications.forEach(async (value) => {
      functions.logger.info(`sending notification for startedPoll ${value.pollId} to devices. `)
      const payload = {
        notification: {
          title: value.title,
          body: value.body,
        },
      };

      // Send a message to devices subscribed to the provided topic.
      admin.messaging().sendToDevice(registrationTokens, payload).then(async (response) => {
        // Response is a message ID string.
        console.log('Notification Trigger response:', response);
        // Remove the notification field from the messaging/messages document
        await messagesDocRef.update({
          [value.pollId]: admin.firestore.FieldValue.delete()
        });
      })
        .catch((error) => {
          console.log('Error sending message:', error);
        });
    });
    return null;
  });