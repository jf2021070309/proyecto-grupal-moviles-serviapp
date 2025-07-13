import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serviapp/modelo/global_user.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener el usuario actual
  Future<User?> getUser() async {
    return _auth.currentUser;
  }

  // Iniciar sesión con Firebase Authentication
  Future<User?> loginUser(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;

      if (user != null) {
        // Asignar el UID a GlobalUser
        GlobalUser.uid = user.uid;
      }

      return user;
    } catch (e) {
      print('Error al logear: $e');
      return null;
    }
  }

  // Cerrar sesión de Firebase
  Future<void> logout() async {
    try {
      if (GlobalUser.uid != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(GlobalUser.uid)
            .update({'isOnline': false});
      }

      await _auth.signOut();
      GlobalUser.uid = null;
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }
}
