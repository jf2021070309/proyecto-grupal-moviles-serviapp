import 'package:flutter/material.dart';
import 'package:serviapp/vista/Proveedor/payment_screen.dart'; // Importa tu nuevo PaymentScreen
import 'package:serviapp/modelo/global_user.dart'; // Para obtener el uid

final List<Map<String, dynamic>> paquetesTokens = [
  {
    'nombre': 'Starter',
    'tokens': 120,
    'precio': 15,
    'descripcion': 'Ideal para empezar',
    'icon': Icons.stars,
    'color': Colors.blue,
  },
  {
    'nombre': 'Básico',
    'tokens': 260,
    'precio': 30,
    'descripcion': 'Mejor relación costo-beneficio',
    'icon': Icons.trending_up,
    'color': Colors.green,
  },
  {
    'nombre': 'Pro',
    'tokens': 540,
    'precio': 60,
    'descripcion': 'Para proveedores activos',
    'icon': Icons.flash_on,
    'color': Colors.orange,
  },
  {
    'nombre': 'Empresarial',
    'tokens': 1120,
    'precio': 120,
    'descripcion': '¡Pensado para empresas!',
    'icon': Icons.business_center,
    'color': Colors.purple,
  },
];

class RecargarTokensPage extends StatefulWidget {
  @override
  State<RecargarTokensPage> createState() => _RecargarTokensPageState();
}

class _RecargarTokensPageState extends State<RecargarTokensPage> {
  int _seleccionado = 0;

  @override
  Widget build(BuildContext context) {
    final uid = GlobalUser.uid; // O tu forma de obtener el uid actual

    return Scaffold(
      appBar: AppBar(
        title: Text('Recargar Tokens'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Selecciona un paquete de tokens",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                itemCount: paquetesTokens.length,
                separatorBuilder: (_, __) => SizedBox(height: 18),
                itemBuilder: (context, idx) {
                  final plan = paquetesTokens[idx];
                  final esSeleccionado = idx == _seleccionado;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _seleccionado = idx;
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: esSeleccionado ? plan['color'].withOpacity(0.08) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: esSeleccionado ? plan['color'] : Colors.grey.shade300,
                          width: esSeleccionado ? 2 : 1,
                        ),
                        boxShadow: [
                          if (esSeleccionado)
                            BoxShadow(
                              color: plan['color'].withOpacity(0.10),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: plan['color'].withOpacity(0.18),
                          child: Icon(plan['icon'], color: plan['color']),
                        ),
                        title: Text(
                          "${plan['tokens']} tokens",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        subtitle: Text(plan['descripcion']),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "S/ ${plan['precio']}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: plan['color'],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                final plan = paquetesTokens[_seleccionado];
                if (uid == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: Usuario no autenticado.')),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentScreen(
                      monto: plan['precio'].toDouble(),
                      tokens: plan['tokens'],
                      uid: uid!,
                      color: plan['color'],
                    ),
                  ),
                );
              },
              icon: Icon(Icons.shopping_cart, color: Colors.white),
              label: Text(
                "Comprar Tokens",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: paquetesTokens[_seleccionado]['color'],
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48),
                textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}