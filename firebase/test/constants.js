const firebase = require("@firebase/rules-unit-testing");

/**
 * Define Standard User that is logged in and standard user not logged in.
 */
const myId = "user_abc";
const theirId = "user_xyz";
const myAuth = { uid: myId, email: "alice@example.com"};
const theirAuth = { uid: theirId, email: "bob@example.com"};

/**
* Define valid User profile documents
*/
const myUserDoc = { 
  authLevel: "EMAIL_VERIFIED",
  email: "alice@example.com",
  userName: "slice_420",
  uuid: myId,
};

const theirUserDoc = { 
    authLevel: "EMAIL_VERIFIED",
    email: "bob@example.com",
    userName: "mono_24",
    uuid: theirId,
  };

/**
* Define a valid Poll document
*/
const myPollId = "poll_xyz";
const myPoll = { 
  owner: {
    userName: myUserDoc.userName, 
    uuid: myUserDoc.uuid,
  },
  questions: [
    {
      questionId: 0, 
      question: "Eichhörnchen fangbar?",
      choices: [
        {
          choiceId: 0,
          counter: 12,
          choice: "ja",
        }, 
        {
          choiceId: 1,
          counter: 34,
          choice: "nein",
        },
      ],
    },
  ],
  requirements: {
    locationRequirement: {
      geoHash: "GeoHash123",
      geoPoint: {
        latitude: 49.12312312,
        longitude: 8.65123123,
      },
      radius: 2000,
    },
    authRequirement: {
      auth: "MAIL_VERIFIED",
    },
    timeRequirement: {
      endTime: 1644328800000,
      startTime: 1643727600000,
    },
  },
  title: "Eichhörnchen fangbar?",
};

/**
 * Define invalid Poll Documents
 */
const myPoll_oneChoice = { 
  owner: {
    userName: myUserDoc.userName, 
    uuid: myUserDoc.uuid,
  },
  questions: [
    {
      questionId: 0, 
      question: "Eichhörnchen fangbar?",
      choices: [
        {
          choiceId: 0,
          counter: 12,
          choice: "ja",
        },
      ],
    },
  ],
  requirements: {
    locationRequirement: {
      geoHash: "GeoHash123",
      geoPoint: {
        latitude: 49.12312312,
        longitude: 8.65123123,
      },
      radius: 2000,
    },
    authRequirement: {
      auth: "MAIL_VERIFIED",
    },
    timeRequirement: {
      endTime: 1644328800000,
      startTime: 1643727600000,
    },
  },
  title: "Eichhörnchen fangbar?",
};
const myPoll_noChoices = { 
  owner: {
    userName: myUserDoc.userName, 
    uuid: myUserDoc.uuid,
  },
  questions: [
    {
      questionId: 0, 
      question: "Eichhörnchen fangbar?",
      choices: [],
    },
  ],
  requirements: {
    locationRequirement: {
      geoHash: "GeoHash123",
      geoPoint: {
        latitude: 49.12312312,
        longitude: 8.65123123,
      },
      radius: 2000,
    },
    authRequirement: {
      auth: "MAIL_VERIFIED",
    },
    timeRequirement: {
      endTime: 1644328800000,
      startTime: 1643727600000,
    },
  },
  title: "Eichhörnchen fangbar?",
};

const myPoll_missingRequirements = {
  owner: {
    userName: myUserDoc.userName, 
    uuid: myUserDoc.uuid,
  },
  questions: [
    {
      questionId: 0, 
      question: "Eichhörnchen fangbar?",
      choices: [
        {
          choiceId: 0,
          counter: 12,
          choice: "ja",
        }, 
        {
          choiceId: 1,
          counter: 34,
          choice: "nein",
        },
      ],
    },
  ],
  title: "Eichhörnchen fangbar?",
};
const myPoll_missingOwner = { 
  questions: [
    {
      questionId: 0, 
      question: "Eichhörnchen fangbar?",
      choices: [
        {
          choiceId: 0,
          counter: 12,
          choice: "ja",
        }, 
        {
          choiceId: 1,
          counter: 34,
          choice: "nein",
        },
      ],
    },
  ],
  requirements: {
    locationRequirement: {
      geoHash: "GeoHash123",
      geoPoint: {
        latitude: 49.12312312,
        longitude: 8.65123123,
      },
      radius: 2000,
    },
    authRequirement: {
      auth: "MAIL_VERIFIED",
    },
    timeRequirement: {
      endTime: 1644328800000,
      startTime: 1643727600000,
    },
  },
  title: "Eichhörnchen fangbar?",
};
const myPoll_missingTitle = { 
  owner: {
    userName: myUserDoc.userName, 
    uuid: myUserDoc.uuid,
  },
  questions: [
    {
      questionId: 0, 
      question: "Eichhörnchen fangbar?",
      choices: [
        {
          choiceId: 0,
          counter: 12,
          choice: "ja",
        }, 
        {
          choiceId: 1,
          counter: 34,
          choice: "nein",
        },
      ],
    },
  ],
  requirements: {
    locationRequirement: {
      geoHash: "GeoHash123",
      geoPoint: {
        latitude: 49.12312312,
        longitude: 8.65123123,
      },
      radius: 2000,
    },
    authRequirement: {
      auth: "MAIL_VERIFIED",
    },
    timeRequirement: {
      endTime: 1644328800000,
      startTime: 1643727600000,
    },
  },
};

const myPoll_datatype_longLat = { 
  owner: {
    userName: myUserDoc.userName, 
    uuid: myUserDoc.uuid,
  },
  questions: [
    {
      questionId: 0, 
      question: "Eichhörnchen fangbar?",
      choices: [
        {
          choiceId: 0,
          counter: 12,
          choice: "ja",
        }, 
        {
          choiceId: 1,
          counter: 34,
          choice: "nein",
        },
      ],
    },
  ],
  requirements: {
    locationRequirement: {
      geoHash: "GeoHash123",
      geoPoint: {
        latitude: "49.12312312",
        longitude: "8.65123123",
      },
      radius: 2000,
    },
    authRequirement: {
      auth: "MAIL_VERIFIED",
    },
    timeRequirement: {
      endTime: 1644328800000,
      startTime: 1643727600000,
    },
  },
  title: "Eichhörnchen fangbar?",
};
const myPoll_datatype_time_str = { 
  owner: {
    userName: myUserDoc.userName, 
    uuid: myUserDoc.uuid,
  },
  questions: [
    {
      questionId: 0, 
      question: "Eichhörnchen fangbar?",
      choices: [
        {
          choiceId: 0,
          counter: 12,
          choice: "ja",
        }, 
        {
          choiceId: 1,
          counter: 34,
          choice: "nein",
        },
      ],
    },
  ],
  requirements: {
    locationRequirement: {
      geoHash: "GeoHash123",
      geoPoint: {
        latitude: 49.12312312,
        longitude: 8.65123123,
      },
      radius: 2000,
    },
    authRequirement: {
      auth: "MAIL_VERIFIED",
    },
    timeRequirement: {
      endTime: "1644328800000",
      startTime: "1643727600000",
    },
  },
  title: "Eichhörnchen fangbar?",
};
const myPoll_datatype_time_float = { 
  owner: {
    userName: myUserDoc.userName, 
    uuid: myUserDoc.uuid,
  },
  questions: [
    {
      questionId: 0, 
      question: "Eichhörnchen fangbar?",
      choices: [
        {
          choiceId: 0,
          counter: 12,
          choice: "ja",
        }, 
        {
          choiceId: 1,
          counter: 34,
          choice: "nein",
        },
      ],
    },
  ],
  requirements: {
    locationRequirement: {
      geoHash: "GeoHash123",
      geoPoint: {
        latitude: 49.12312312,
        longitude: 8.65123123,
      },
      radius: 2000,
    },
    authRequirement: {
      auth: "MAIL_VERIFIED",
    },
    timeRequirement: {
      endTime: 16443288000.50,
      startTime: 16437276000.40,
    },
  },
  title: "Eichhörnchen fangbar?",
};
const myPoll_datatype_radius_str = { 
  owner: {
    userName: myUserDoc.userName, 
    uuid: myUserDoc.uuid,
  },
  questions: [
    {
      questionId: 0, 
      question: "Eichhörnchen fangbar?",
      choices: [
        {
          choiceId: 0,
          counter: 12,
          choice: "ja",
        }, 
        {
          choiceId: 1,
          counter: 34,
          choice: "nein",
        },
      ],
    },
  ],
  requirements: {
    locationRequirement: {
      geoHash: "GeoHash123",
      geoPoint: {
        latitude: 49.12312312,
        longitude: 8.65123123,
      },
      radius: "2000",
    },
    authRequirement: {
      auth: "MAIL_VERIFIED",
    },
    timeRequirement: {
      endTime: 1644328800000,
      startTime: 1643727600000,
    },
  },
  title: "Eichhörnchen fangbar?",
};
const myPoll_datatype_radius_float = { 
  owner: {
    userName: myUserDoc.userName, 
    uuid: myUserDoc.uuid,
  },
  questions: [
    {
      questionId: 0, 
      question: "Eichhörnchen fangbar?",
      choices: [
        {
          choiceId: 0,
          counter: 12,
          choice: "ja",
        }, 
        {
          choiceId: 1,
          counter: 34,
          choice: "nein",
        },
      ],
    },
  ],
  requirements: {
    locationRequirement: {
      geoHash: "GeoHash123",
      geoPoint: {
        latitude: 49.12312312,
        longitude: 8.65123123,
      },
      radius: 2000.10,
    },
    authRequirement: {
      auth: "MAIL_VERIFIED",
    },
    timeRequirement: {
      endTime: 1644328800000,
      startTime: 1643727600000,
    },
  },
  title: "Eichhörnchen fangbar?",
};

//Votes
const aVote = {
  key: "abcxyz123",
  answers: {
    "0": 0
  } 
}

/**
 * The emulator will accept any project ID for testing.
 */
 const PROJECT_ID = "locationpoll";

 module.exports = {aVote, PROJECT_ID, myId, theirId, myAuth, myPoll, myPollId, myPoll_noChoices, myPoll_oneChoice, myPoll_missingRequirements, myPoll_missingOwner, myPoll_missingTitle, myPoll_datatype_longLat, myPoll_datatype_time_str, myPoll_datatype_time_float, myPoll_datatype_radius_str, myPoll_datatype_radius_float, myUserDoc, theirAuth, theirUserDoc}