import 'package:cafe/configuraciones/widgets/modal_cerar_caja.dart';
import 'package:flutter/material.dart';
import 'package:cafe/common/sesion_activa.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ConfiguracionesScreen extends StatefulWidget {
  const ConfiguracionesScreen({super.key});

  @override
  State<ConfiguracionesScreen> createState() => _ConfiguracionesScreenState();
}

class _ConfiguracionesScreenState extends State<ConfiguracionesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    _nombreController.text = box.read('ticket_nombre') ?? '';
    _direccionController.text = box.read('ticket_direccion') ?? '';
    _telefonoController.text = box.read('ticket_telefono') ?? '';
  }

  void _guardarDatos() {
    if (_formKey.currentState!.validate()) {
      box.write('ticket_nombre', _nombreController.text);
      box.write('ticket_direccion', _direccionController.text);
      box.write('ticket_telefono', _telefonoController.text);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos guardados exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuraciones'),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Formulario de datos del ticket
            SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Información del Ticket',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Configure los datos que aparecerán en los tickets de venta:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Campo Nombre del negocio
                        TextFormField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre del Negocio',
                            hintText: 'Ej: Café Benito',
                            prefixIcon: Icon(Icons.store),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese el nombre del negocio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Campo Dirección
                        TextFormField(
                          controller: _direccionController,
                          decoration: const InputDecoration(
                            labelText: 'Dirección',
                            hintText: 'Ej: Calle Principal #123',
                            prefixIcon: Icon(Icons.location_on),
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese la dirección';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Campo Teléfono
                        TextFormField(
                          controller: _telefonoController,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono',
                            hintText: 'Ej: +1 234 567 8900',
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese el número de teléfono';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Botón Guardar
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _guardarDatos,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B4513),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save),
                                SizedBox(width: 8),
                                Text(
                                  'Guardar Configuración',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botón Cerrar Sesión
            InkWell(
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
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }
}
