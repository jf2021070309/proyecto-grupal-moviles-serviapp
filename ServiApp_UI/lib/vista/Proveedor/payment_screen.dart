import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'pago_completado.dart';

class PaymentScreen extends StatelessWidget {
  final double monto;
  final int tokens;
  final String uid;
  final Color color;

  const PaymentScreen({
    super.key,
    required this.monto,
    required this.tokens,
    required this.uid,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final paymentItems = [
      PaymentItem(
        label: 'Total',
        amount: monto.toStringAsFixed(2),
        status: PaymentItemStatus.final_price,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text("Confirmar compra de tokens")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tarjeta resumen profesional
              Container(
                margin: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: color.withOpacity(0.25), width: 2),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: color.withOpacity(0.12),
                      child: Icon(
                        Icons.monetization_on,
                        color: color,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Compra de tokens",
                      style: TextStyle(
                        color: color,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Divider(height: 2, color: color.withOpacity(0.6)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Cantidad de tokens:",
                          style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                        ),
                        Text(
                          "$tokens",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total a pagar:",
                          style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                        ),
                        Text(
                          "S/ ${monto.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Mensaje resumen
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                child: Text(
                  "Revisa los detalles antes de confirmar tu compra. Al finalizar el pago recibirás tus tokens automáticamente.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700], fontSize: 15),
                ),
              ),
              SizedBox(height: 18),
              // Botón Google Pay
              FutureBuilder<PaymentConfiguration>(
                future: PaymentConfiguration.fromAsset('gpay.json'),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  return GooglePayButton(
                    paymentConfiguration: snapshot.data!,
                    paymentItems: paymentItems,
                    type: GooglePayButtonType.pay,
                    width: 220,
                    height: 55,
                    onPaymentResult: (result) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => PagoCompletadoScreen(
                            tokens: tokens,
                            uid: uid,
                            color: color,
                          ),
                        ),
                      );
                    },
                    loadingIndicator: const CircularProgressIndicator(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}