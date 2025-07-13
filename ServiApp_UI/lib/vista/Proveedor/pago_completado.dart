import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PagoCompletadoScreen extends StatefulWidget {
  final int tokens;
  final String uid;
  final Color color;

  const PagoCompletadoScreen({super.key, required this.tokens, required this.uid, required this.color});

  @override
  State<PagoCompletadoScreen> createState() => _PagoCompletadoScreenState();
}

class _PagoCompletadoScreenState extends State<PagoCompletadoScreen> {
  bool _actualizado = false;

  @override
  void initState() {
    super.initState();
    _sumarTokens();
  }

  Future<void> _sumarTokens() async {
    if (_actualizado) return;
    final userRef = FirebaseFirestore.instance.collection('users').doc(widget.uid);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final current = (snapshot.data()?['tokens'] as int?) ?? 0;
      transaction.update(userRef, {'tokens': current + widget.tokens});
    });
    setState(() {
      _actualizado = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.color.withOpacity(0.08),
      body: Center(
        child: _actualizado
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified, size: 72, color: Colors.green[600]),
                  SizedBox(height: 24),
                  Text(
                    '¡Pago exitoso!',
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "+${widget.tokens} tokens sumados a tu cuenta.",
                    style: TextStyle(
                      fontSize: 20,
                      color: widget.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 36),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst); // Volver a inicio
                    },
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    label: Text("Volver", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              )
            : CircularProgressIndicator(color: widget.color),
      ),
    );
  }
}