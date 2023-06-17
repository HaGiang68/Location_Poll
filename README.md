# location_poll

This project has been developed for the course "Internet - Praktikum Telekooperation WS 2021/22" at TU Darmstadt. 
We developed an android application for location based voting. It is build on Flutter, Firebase and Google Fences.

## Getting Started

To use the application, install the .apk inside the `/Deliverables` folder onto your device.

To setup a local instance of the application including the backend for your own developement you will need a MariaDB database as described in the following section as well as a firebase project. You can find all needed files to initialize the firebase project inside the `/firebase` folder.

To build the app you need a working Flutter environment. A documentation on how to setup Flutter on your system can be found [here](https://docs.flutter.dev/get-started/install). The flutter project cn be found under `/flutter-app`.


## Connect MariaDB
Setup an instance of Maria DB >= 10.5.
The firebase cloud funtions user for the database only needs permissions for the SELECT and INSERT query on the tables.

Initialize the MariaDB instance with the schema

```
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT /;
/!40101 SET NAMES utf8 /;
/!50503 SET NAMES utf8mb4 /;
/!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 /;
/!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' /;
/!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 /;

CREATE DATABASE IF NOT EXISTS locpollauth /!40100 DEFAULT CHARACTER SET latin1 /;
USE locpollauth;

CREATE TABLE IF NOT EXISTS distribution (
  uuid varchar(45) NOT NULL,
  poll_id varchar(45) NOT NULL,
  PRIMARY KEY (uuid,poll_id) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS keys (
  key varchar(128) NOT NULL DEFAULT md5(rand()),
  poll_id varchar(45) NOT NULL,
  PRIMARY KEY (key,poll_id) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') /;
/!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) /;
/!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT /;
/!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;

```

In `firebase/functions/src/db_credentials.ts` fill in the credentials for your MariaDB database.
```
const dbCredentials = {
    user: 'user', // e.g. 'my-db-user'
    password: 'pwd', // e.g. 'my-db-password'
    database: 'db-name', // e.g. 'my-database' - if used above initialization then 'locpollauth'
    host: "host", // e.g. '127.0.0.1'
    port: port // e.g. 3066
};
```

## Firebase

To connect your Firebase service with the MariaDB database you need to put your database credentials into the file `/firebase/functions/db_credentials.ts`. 

To setup the firebase project locally and being able to deploy it on your firebase account see the [Firestore introduction](https://firebase.google.com/docs/build) and [Getting started with Cloud Firestore](https://firebase.google.com/docs/firestore/quickstart)

### Firebase Emulator Suite
To run the Unit tests and run your project locally you need to have working [Firebase Emulators](https://firebase.google.com/docs/emulator-suite) setup inside the `firebase` folder. You can find a guide on how to setup the Local Firebase Emulator Suite [here](https://firebase.google.com/docs/rules/emulator-setup). You will need the Authentication, Firestore and CloudFunctions enabled.

### Firestore: Run Unit Tests
With a working Emulator Suite just run the command `$ firebase emulators:exec --only firestore "npm run test-firestore"`inside the `firebase/` folder.

### Build and Run Emulator
For local testing and developement you can run the whole Firebase Service including the Authentication, Firestore and Cloud Functions locally on your machine. If you already setup a local MariaDB instance then you can run the app fully locally.

To use the Emulator you first need to build the Cloud Functions. For this run the command inside the `firestore` folder.
`$ cd functions && npm run build && cd .. && firebase emulators:start --import=./firebase-data/ --export-on-exit`




