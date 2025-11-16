import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_mocks/firebase_core_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';

/// -----------------------------------------------------------
/// 🔥 Mock Classes
/// -----------------------------------------------------------

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

/// -----------------------------------------------------------
/// 🔥 GLOBAL MOCK INSTANCES
/// -----------------------------------------------------------
late MockFirebaseAuth mockAuth;
late MockFirebaseFirestore mockFirestore;
late MockGoogleSignIn mockGoogleSignIn;

/// -----------------------------------------------------------
/// 🚀 Initialize all mocks before each test
/// -----------------------------------------------------------
Future<void> setupFirebaseMocks() async {
  // 1. Setup core firebase mock
  MockFirebase.initialize();

  // 2. Create mock instances
  mockAuth = MockFirebaseAuth();
  mockFirestore = MockFirebaseFirestore();
  mockGoogleSignIn = MockGoogleSignIn();

  // 3. Ensure Firebase.initializeApp() works
  await Firebase.initializeApp();
}
