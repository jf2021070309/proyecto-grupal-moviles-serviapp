import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serviapp/modelo/usuario_model.dart';
import 'package:serviapp/modelo/global_user.dart';

class UsuarioController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(Usuario usuario) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: usuario.email,
            password: usuario.password,
          );

      final User? user = userCredential.user;

      if (user != null) {
        GlobalUser.uid = user.uid;

        Map<String, dynamic> userData = {
          'nombre': usuario.nombre,
          'email': usuario.email,
          'rol': usuario.rol,
          'dni': usuario.dni,
          'celular': usuario.celular,
        };

        // Si es proveedor, agregamos los campos extra
        if (usuario.rol == 'proveedor') {
          userData['tipoTrabajo'] = usuario.tipoTrabajo ?? '';
          userData['experiencia'] = usuario.experiencia ?? '';
          userData['tokens'] = 0;
        }

        await _firestore.collection('users').doc(user.uid).set(userData);
      }
    } catch (e) {
      print('Error al crear el usuario: $e');
      throw Exception('Error al crear el usuario');
    }
  }

  Future<void> updateUser(Usuario usuario) async {
    try {
      // Aquí ya se incluye tipoTrabajo y experiencia porque toMap() los tiene
      await _firestore
          .collection('users')
          .doc(usuario.id)
          .update(usuario.toMap());
    } catch (e) {
      print('Error al actualizar el usuario: $e');
      throw Exception('Error al actualizar el usuario');
    }
  }
}
