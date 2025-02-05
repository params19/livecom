import 'package:appwrite/appwrite.dart';

const String db = "67a318110036e2465bea";
const String collection = "67a31826000e0b271f0b";

// ✅ Define client globally
Client client = Client()
    .setEndpoint('https://cloud.appwrite.io/v1') // Required
    .setProject('67a316ad003a50945b8b'); // Your project ID

// ✅ Use client for services
Account account = Account(client);
Databases database = Databases(client);

Future savePhoneToDB(
    {required String phoneNumber, required String userId}) async {
  try {
    await database.createDocument(
      databaseId: db,
      collectionId: collection,
      documentId: userId,
      data: {'phone': phoneNumber, 'userId': userId},
    );
    print("Phone number saved successfully!");
  } catch (e) {
    print("Error: $e");
  }
}
