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
  Future<String> createPhoneSession({required String phoneNumber}) async {
    try{
      final userId= await doesPhoneNumberExist(phoneNumber);
      if(userId=="user_not_found"){
        final Token data=await account.createPhoneToken(userId: ID.unique(), phone: phoneNumber);
        savePhoneToDB(phoneNumber: phoneNumber, userId: data.userId);
        return data.userId;
    }
    else{
        final Token data=await account.createPhoneToken(userId: userId, phone: phoneNumber);
        return data.userId;
    }
    }
    on AppwriteException catch(e){
      print("Login error $e");
      return "error";
    }
}
