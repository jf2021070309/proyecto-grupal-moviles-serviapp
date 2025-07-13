import 'package:flutter/material.dart';
import '../modelo/categoria_model.dart';
import '../modelo/servicio_model.dart';

class HomeController {
  List<Categoria> obtenerCategorias() {
    return [
      Categoria(
        label: 'Tecnologia',
        icon: Icons.devices,
        color: Colors.blue,
        gradient: LinearGradient(colors: [Colors.blue, Colors.lightBlue])),
      Categoria(
        label: 'Vehículos',
        icon: Icons.directions_car,
        color: Colors.red,
        gradient: LinearGradient(colors: [Colors.red, Colors.orange])),
      Categoria(
        label: 'Eventos',
        icon: Icons.event,
        color: Colors.purple,
        gradient: LinearGradient(colors: [Colors.purple, Colors.deepPurple])),
      Categoria(
        label: 'Estetica',
        icon: Icons.spa,
        color: Colors.pink,
        gradient: LinearGradient(colors: [Colors.pink, Colors.pinkAccent])),
      Categoria(
        label: 'Salud y Bienestar',
        icon: Icons.favorite,
        color: Colors.green,
        gradient: LinearGradient(colors: [Colors.green, Colors.teal])),
      Categoria(
        label: 'Servicios Generales',
        icon: Icons.build,
        color: Colors.indigo,
        gradient: LinearGradient(colors: [Colors.indigo, Colors.indigoAccent])),
      Categoria(
        label: 'Educacion',
        icon: Icons.school,
        color: Colors.amber,
        gradient: LinearGradient(colors: [Colors.amber, Colors.orangeAccent])),
      Categoria(
        label: 'Limpieza',
        icon: Icons.cleaning_services,
        color: Colors.teal,
        gradient: LinearGradient(colors: [Colors.teal, Colors.greenAccent])),
    ];
  }

  List<Servicio> obtenerServiciosPopulares() {
    return [
      Servicio(
        id: '1',
        titulo: 'Reparación de computadoras',
        descripcion: 'Servicio técnico especializado',
        telefono: '+123456789',
        subcategoria: 'Tecnologia',
        idusuario: 'proveedor123', // ID del proveedor
        sumaCalificaciones: 576.0, // 4.8 * 120
        totalCalificaciones: 120,
        icon: Icons.computer,
        color: Colors.blue,
      ),
      Servicio(
        id: '2',
        titulo: 'Limpieza del hogar',
        descripcion: 'Limpieza profesional',
        telefono: '+987654321',
        subcategoria: 'Limpieza',
        idusuario: 'proveedor456', // ID del proveedor
        sumaCalificaciones: 399.5, // 4.7 * 85
        totalCalificaciones: 85,
        icon: Icons.cleaning_services,
        color: Colors.teal,
      ),
      Servicio(
        id: '3',
        titulo: 'Plomería de emergencia',
        descripcion: 'Servicio 24/7',
        telefono: '+112233445',
        subcategoria: 'Servicios Generales',
        idusuario: 'proveedor789', // ID del proveedor
        sumaCalificaciones: 1029.0, // 4.9 * 210
        totalCalificaciones: 210,
        icon: Icons.plumbing,
        color: Colors.indigo,
      ),
    ];
  }

  // Método para agregar una nueva calificación
  Future<void> agregarCalificacion(String servicioId, double calificacion) async {
    final servicio = obtenerServiciosPopulares()
        .firstWhere((s) => s.id == servicioId);
    
    // En una app real, aquí harías la actualización en Firestore
    // await FirebaseFirestore.instance
    //     .collection('servicios')
    //     .doc(servicioId)
    //     .update(servicio.toUpdateMap(calificacion));
    
    // Para datos mock, actualizamos localmente (solo para demostración)
    final index = obtenerServiciosPopulares().indexWhere((s) => s.id == servicioId);
    if (index != -1) {
      obtenerServiciosPopulares()[index] = Servicio(
        id: servicio.id,
        titulo: servicio.titulo,
        descripcion: servicio.descripcion,
        telefono: servicio.telefono,
        subcategoria: servicio.subcategoria,
        idusuario: servicio.idusuario,
        sumaCalificaciones: servicio.sumaCalificaciones + calificacion,
        totalCalificaciones: servicio.totalCalificaciones + 1,
        icon: servicio.icon,
        color: servicio.color,
      );
    }
  }

  // Método para obtener servicios por categoría
  List<Servicio> obtenerServiciosPorCategoria(String categoria) {
    return obtenerServiciosPopulares()
        .where((servicio) => servicio.subcategoria == categoria)
        .toList();
  }

  // Método para buscar servicios
  List<Servicio> buscarServicios(String query) {
    return obtenerServiciosPopulares()
        .where((servicio) =>
            servicio.titulo.toLowerCase().contains(query.toLowerCase()) ||
            servicio.descripcion.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Método para obtener servicios por proveedor
  List<Servicio> obtenerServiciosPorProveedor(String proveedorId) {
    return obtenerServiciosPopulares()
        .where((servicio) => servicio.idusuario == proveedorId)
        .toList();
  }

  // Método para validar si un proveedor tiene servicios
  bool proveedorTieneServicios(String proveedorId) {
    return obtenerServiciosPopulares()
        .any((servicio) => servicio.idusuario == proveedorId);
  }
}