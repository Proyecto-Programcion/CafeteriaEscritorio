import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModalConfirmarImpresion extends StatefulWidget {
  final VoidCallback onConfirmar;
  final VoidCallback onCancelar;
  final double totalVenta;
  final double descuento;

  const ModalConfirmarImpresion({
    Key? key,
    required this.onConfirmar,
    required this.onCancelar,
    required this.totalVenta,
    required this.descuento,
  }) : super(key: key);

  @override
  State<ModalConfirmarImpresion> createState() => _ModalConfirmarImpresionState();
}

class _ModalConfirmarImpresionState extends State<ModalConfirmarImpresion> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleConfirmar() {
    widget.onConfirmar();
  }

  void _handleCancelar() {
    widget.onCancelar();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            _handleConfirmar();
          }
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 16,
        child: Container(
          padding: const EdgeInsets.all(24),
          width: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de impresora
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 153, 103, 8).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.print,
                  size: 48,
                  color: Color.fromARGB(255, 153, 103, 8),
                ),
              ),

              const SizedBox(height: 16),

              // Título
              const Text(
                '¿Imprimir Ticket?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 153, 103, 8),
                ),
              ),

              const SizedBox(height: 8),

              // Subtítulo
              Text(
                'La venta se ha completado exitosamente',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Puedes mostrar info adicional si quieres:
              // Text('Total: \$${widget.totalVenta.toStringAsFixed(2)}   Descuento: \$${widget.descuento.toStringAsFixed(2)}'),

              const SizedBox(height: 24),

              // Botones de acción
              Row(
                children: [
                  // Botón Cancelar
                  Expanded(
                    child: TextButton(
                      onPressed: _handleCancelar,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                      ),
                      child: const Text(
                        'No Imprimir',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Botón Confirmar
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleConfirmar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 153, 103, 8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.print, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Imprimir',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}