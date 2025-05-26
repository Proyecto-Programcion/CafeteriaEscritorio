import 'package:cafe/configuraciones/widgets/modal_cerar_caja.dart';
import 'package:flutter/material.dart';
import 'package:cafe/common/sesion_activa.dart';

class ConfiguracionesScreen extends StatefulWidget {
  const ConfiguracionesScreen({super.key});

  @override
  State<ConfiguracionesScreen> createState() => _ConfiguracionesScreenState();
}

class _ConfiguracionesScreenState extends State<ConfiguracionesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: () {
            showDialog(context: context, builder: (context) {
              return ModalCerrarCaja();
            }).then((value) {
              if (value == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Caja cerrada exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
                SesionActiva().limpiarSesion();
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              } else if (value == false) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error al cerrar la caja'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
