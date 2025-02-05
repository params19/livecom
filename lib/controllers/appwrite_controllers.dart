import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

const String db = "67a318110036e2465bea";
const String collection = "67a31826000e0b271f0b";

// ✅ Define client globally
Client client = Client()
    .setEndpoint('https://cloud.appwrite.io/v1') // Required
    .setProject('67a316ad003a50945b8b'); // Your project ID

// ✅ Use client for services
Account account = Account(client);
Databases database = Databases(client);

// Save phone number to the database
Future<bool> savePhoneToDB(
    {required String phoneNumber, required String userId}) async {
  try {
    await database.createDocument(
      databaseId: db,
      collectionId: collection,
      documentId: userId,
      data: {'phone': phoneNumber, 'userId': userId},
    );
    print("Phone number saved successfully!");
    return true;
  } on AppwriteException catch (e) {
    print("Error: $e");
    return false;
  }
}

// Check if phone number exists in the database
Future<String> doesPhoneNumberExist(String phoneNumber) async {
  try {
    final DocumentList match = await database.listDocuments(
      databaseId: db,
      collectionId: collection,
      queries: [Query.equal("phone", phoneNumber)],
    );
    if (match.documents.isNotEmpty) {
      final Document doc = match.documents.first;
      if (doc.data['phone'] != null || doc.data['phone'] != "") {
        return doc.data['userId'];
      } else {
        print("Phone number not found!");
        return "user_not_found";
      }
    } else {
      print("Phone number not found!");
      return "user_not_found";
    }
  } on AppwriteException catch (e) {
    print("Error on readind DB $e");
    return "user_not_found";
  }
}

//Pjpne number authentication
Future<String> createPhoneSession({required String phoneNumber}) async {
  try {
    final userId = await doesPhoneNumberExist(phoneNumber);
    if (userId == "user_not_found") {
      final Token data = await account.createPhoneToken(
          userId: ID.unique(), phone: phoneNumber);
      await savePhoneToDB(phoneNumber: phoneNumber, userId: data.userId);
      return data.userId;
    } else {
      final Token data =
          await account.createPhoneToken(userId: userId, phone: phoneNumber);
      return data.userId;
    }
  } catch (e) {
    print("Login error $e");
    return "error";
  }
}

//Login with OTP
Future<bool> loginWithOTP({required String userId, required String otp}) async {
  try {
    final Session session = await account.createSession(
      userId: userId,
      secret: otp,
    );
    print(session.userId);
    print("Login successful with OTP!");
    return true;
  } catch (e) {
    print("Login error using OTP: $e");
    return false;
  }
}

//to check whether the session exist or not
Future<bool> checkSessions() async {
  try {
    final Session session = await account.getSession(sessionId: "current");
    print("Session exist ${session.userId}");
    return true;
  } catch (e) {
    print("Session does not exist $e");
    return false;
  }
}
Future<bool> savePhoneToDb(
    {required String phoneno, required String userId}) async {
  try {
    final response = await database.createDocument(
        databaseId: db,
        collectionId: collection,
        documentId: userId,
        data: {"phone": phoneno, "userId": userId});

    print(response);
    return true;
  } on AppwriteException catch (e) {
    print("Cannot save to user database :$e");
    return false;
  }
}

// // check whether phone number exist in DB or not
// Future<String> checkPhoneNumber({required String phoneno}) async {
//   try {
//     final DocumentList matchUser = await database.listDocuments(
//         databaseId: db,
//         collectionId: collection,
//         queries: [Query.equal("phone", phoneno)]);

//     if (matchUser.total > 0) {
//       final Document user = matchUser.documents[0];

//       if (user.data["phone"] != null || user.data["phone"] != "") {
//         return user.data["userId"];
//       } else {
//         print("no user exist on db");
//         return "user_not_exist";
//       }
//     } else {
//       print("no user exist on db");
//       return "user_not_exist";
//     }
//   } on AppwriteException catch (e) {
//     print("error on reading database $e");
//     return "user_not_exist";
//   }
// }

// // create a phone session , send otp to the phone number
// Future<String> createPhoneSession({required String phone}) async {
//   try {
//     final userId = await checkPhoneNumber(phoneno: phone);
//     if (userId == "user_not_exist") {
//       // creating a new account
//       final Token data =
//           await account.createPhoneToken(userId: ID.unique(), phone: phone);

//       // save the new user to user collection
//       savePhoneToDb(phoneno: phone, userId: data.userId);
//       return data.userId;
//     }

//     // if user is an existing user
//     else {
//       // create phone token for existing user
//       final Token data =
//           await account.createPhoneToken(userId: userId, phone: phone);
//       return data.userId;
//     }
//   } catch (e) {
//     print("error on create phone session :$e");
//     return "login_error";
//   }
// }

// // login with otp
// Future<bool> loginWithOtp({required String otp, required String userId}) async {
//   try {
//     final Session session =
//         await account.updatePhoneSession(userId: userId, secret: otp);
//     print(session.userId);
//     return true;
//   } catch (e) {
//     print("error on login with otp :$e");
//     return false;
//   }
// }

// // to check whether the session exist or not
// Future<bool> checkSessions() async {
//   try {
//     final Session session = await account.getSession(sessionId: "current");
//     print("session exist ${session.$id}");
//     return true;
//   } catch (e) {
//     print("session does not exist please login");
//     return false;
//   }
// }
