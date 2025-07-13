import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serviapp/modelo/global_user.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para iniciar sesión
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;

      if (user != null) {
        // Obtener información del usuario desde Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          // VALIDACIÓN DE USUARIO BLOQUEADO - Verificar si el usuario está bloqueado
          // Si el campo 'bloqueado' existe y es true, denegar el acceso
          bool estaBloqueado = userData['bloqueado'] ?? false; // Por defecto false si no existe el campo
          
          if (estaBloqueado) {
            // Cerrar la sesión inmediatamente si el usuario está bloqueado
            await _auth.signOut();
            return {'error': 'blocked', 'message': 'Tu cuenta ha sido bloqueada. Contacta al administrador.'};
          }
          // FIN VALIDACIÓN DE USUARIO BLOQUEADO

          // Actualizar isOnline a true
          await _firestore.collection('users').doc(user.uid).update({
            'isOnline': true,
          });

          GlobalUser.uid = user.uid;
          GlobalUser.rol = userData['rol'] ?? 'cliente';

          return {'user': user, 'rol': GlobalUser.rol};
        }

        // Si no existe documento, crear uno por defecto con isOnline = true
        await _firestore.collection('users').doc(user.uid).set({
          'rol': 'cliente',
          'isOnline': true,
        });

        GlobalUser.uid = user.uid;
        GlobalUser.rol = 'cliente';

        return {'user': user, 'rol': 'cliente'};
      }

      return null;
    } catch (e) {
      print('Error de login: $e');
      return null;
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    if (GlobalUser.uid != null) {
      try {
        await _firestore.collection('users').doc(GlobalUser.uid).update({
          'isOnline': false,
        });
        print('isOnline actualizado a false');
      } catch (e) {
        print('Error al actualizar isOnline: $e');
      }
    }

    await _auth.signOut();
    GlobalUser.uid = null;
    GlobalUser.rol = null;
  }
}
