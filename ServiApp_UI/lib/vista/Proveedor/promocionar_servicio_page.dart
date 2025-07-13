import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serviapp/modelo/global_user.dart';

final List<Map<String, dynamic>> planesPromocion = [
  {
    'nombre': 'Básico',
    'duracionDias': 3,
    'tokens': 30,
    'descripcion': 'Tu servicio se promociona por 3 días',
    'icon': Icons.star,
    'color': Colors.blue,
  },
  {
    'nombre': 'Pro',
    'duracionDias': 7,
    'tokens': 60,
    'descripcion': 'Promoción destacada durante una semana',
    'icon': Icons.flash_on,
    'color': Colors.orange,
  },
  {
    'nombre': 'Premium',
    'duracionDias': 15,
    'tokens': 110,
    'descripcion': 'Máxima visibilidad por 15 días',
    'icon': Icons.workspace_premium,
    'color': Colors.purple,
  },
];

class PromocionarServicioPage extends StatefulWidget {
  final Map<String, dynamic> servicio;
  const PromocionarServicioPage({required this.servicio});

  @override
  State<PromocionarServicioPage> createState() => _PromocionarServicioPageState();
}

class _PromocionarServicioPageState extends State<PromocionarServicioPage> {
  int _seleccionado = 0;
  bool _cargando = false;
  int _tokensUsuario = 0;

  @override
  void initState() {
    super.initState();
    _cargarTokensUsuario();
  }

  Future<void> _cargarTokensUsuario() async {
    final uid = GlobalUser.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        _tokensUsuario = (doc.data()?['tokens'] ?? 0) as int;
      });
    }
  }

  Future<void> _promocionar() async {
    setState(() => _cargando = true);
    final plan = planesPromocion[_seleccionado];
    final tokensRequeridos = plan['tokens'] as int;

    final uid = GlobalUser.uid;
    if (uid == null) {
      _mostrarError('Sesión expirada, vuelve a iniciar sesión');
      setState(() => _cargando = false);
      return;
    }

    // Verifica que el usuario tenga suficientes tokens
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final servicioRef = FirebaseFirestore.instance.collection('servicios').doc(widget.servicio['id']);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final userSnap = await transaction.get(userRef);
      int tokensActuales = (userSnap.data()?['tokens'] ?? 0) as int;

      if (tokensActuales < tokensRequeridos) {
        throw Exception('No tienes suficientes tokens');
      }

      // Resta tokens
      transaction.update(userRef, {'tokens': tokensActuales - tokensRequeridos});

      // Calcula fechas de promoción
      final ahora = DateTime.now();
      final fin = ahora.add(Duration(days: plan['duracionDias'] as int));

      // Actualiza servicio
      transaction.update(servicioRef, {
        'slide': 'true',
        'promocionInicio': Timestamp.fromDate(ahora),
        'promocionFin': Timestamp.fromDate(fin),
        'promocionTipo': plan['nombre'],
        'promocionTokensUsados': tokensRequeridos,
      });
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Servicio promocionado correctamente!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }).catchError((e) {
      String mensaje = e.toString().contains('tokens') ? 'No tienes suficientes tokens' : 'Ocurrió un error';
      _mostrarError(mensaje);
    });

    setState(() => _cargando = false);
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = planesPromocion[_seleccionado];
    return Scaffold(
      appBar: AppBar(
        title: Text('Promocionar Servicio'),
      ),
      body: _cargando
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecciona un plan de promoción',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text('Tokens disponibles: $_tokensUsuario',
                    style: TextStyle(fontSize: 15, color: Colors.amber[900], fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 16),
                  ...List.generate(planesPromocion.length, (i) {
                    final p = planesPromocion[i];
                    return Container(
                      margin: EdgeInsets.only(bottom: 18),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: p['color'].withOpacity(0.15),
                          child: Icon(p['icon'], color: p['color']),
                        ),
                        title: Text('${p['nombre']} (${p['duracionDias']} días)'),
                        subtitle: Text(p['descripcion']),
                        trailing: Text(
                          '${p['tokens']} tokens',
                          style: TextStyle(
                            color: Colors.amber[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        tileColor: i == _seleccionado ? p['color'].withOpacity(0.07) : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: i == _seleccionado ? p['color'] : Colors.transparent,
                            width: i == _seleccionado ? 2 : 0,
                          ),
                        ),
                        onTap: () => setState(() => _seleccionado = i),
                      ),
                    );
                  }),
                  SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.campaign, color: Colors.white),
                      label: Text('Promocionar ahora', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: plan['color'],
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _tokensUsuario < plan['tokens']
                          ? null
                          : _promocionar,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}