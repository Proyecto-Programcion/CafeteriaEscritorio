import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/administradores/administrador_modelo.dart';
import 'package:cafe/logica/administradores/controller/actualizar_administrador_controller.dart';

import 'package:cafe/logica/administradores/controller/listar_sucursales_controller.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Agrega esta importación
import 'package:get/get.dart';

class ModalActualizarAdministrador extends StatefulWidget {
  final AdministradorModelo administradorModelo;
  const ModalActualizarAdministrador(
      {super.key, required this.administradorModelo});

  @override
  State<ModalActualizarAdministrador> createState() =>
      _ModalActualizarAdministradorState();
}

class _ModalActualizarAdministradorState
    extends State<ModalActualizarAdministrador> {
  final ListarSucursalesController listarSucursalesController = Get.put(
    ListarSucursalesController(),
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controladores para los campos
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();

  int? selectedSucursalId;
  String? imagenbase64;

  @override
  void initState() {
    super.initState();

    // Inicializa los controladores con los datos del administrador
    nombreController.text = widget.administradorModelo.nombre;
    correoController.text = widget.administradorModelo.correo ?? '';
    telefonoController.text = widget.administradorModelo.telefono;
    contrasenaController.text = widget.administradorModelo.contrasena;
    selectedSucursalId = widget.administradorModelo.idSucursal;

    // Si la imagen es nula, no la asignamos
    if (widget.administradorModelo.imagen != null) {
      imagenbase64 = widget.administradorModelo.imagen!;
    }

    // Cargar sucursales después de establecer los valores iniciales
    listarSucursalesController.obtenerSucursales();
  }

  //Seleccionar la imagen
  String imagenController = '';

  Future<void> selectImage() async {
    XTypeGroup typeGroup = const XTypeGroup(
      label: 'images',
      extensions: <String>['jpg', 'png'],
    );

    final XFile? file =
        await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);

    if (file == null) return;

    setState(() {
      imagenController = file.path;
    });
  }

  void editarAdministrador() async {
    if (_formKey.currentState!.validate()) {
      final ActualizarAdministradorController agregarAdministradorController =
          Get.put(ActualizarAdministradorController());
      final resp = await agregarAdministradorController.actualizarAdministrador(
        widget.administradorModelo.idUsuario,
        nombreController.text,
        correoController.text,
        telefonoController.text,
        contrasenaController.text,
        selectedSucursalId!,
        imagenController.isNotEmpty ? imagenController : null,
      );

      if (resp) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Administrador actualizado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar el administrador'),
            backgroundColor: Colors.red,
          ),
        );
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: Container(
        padding: const EdgeInsets.all(20),
        width: 800,
        height: 580,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Agregar Administrador',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // Campo Nombre
              Row(
                children: [
                  _buildLabel("Nombre: "),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextFormField(
                      labelText: 'Nombre',
                      controller: nombreController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el nombre';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo Correo y Teléfono
              Row(
                children: [
                  _buildLabel("Correo: "),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildTextFormField(
                      labelText: 'Correo',
                      controller: correoController,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          // Expresión regular para validar correo electrónico
                          String pattern =
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                          RegExp regExp = RegExp(pattern);

                          if (!regExp.hasMatch(value)) {
                            return 'Ingrese un correo válido';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildLabel("Teléfono: "),
                  Expanded(
                    child: _buildPhoneTextFormField(
                      // Usa el widget especializado
                      labelText: 'Teléfono',
                      controller: telefonoController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el teléfono';
                        }
                        if (value.length != 10) {
                          return 'El teléfono debe tener exactamente 10 dígitos';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Campo Sucursal
              Row(
                children: [
                  _buildLabel("Sucursal: "),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Obx(() {
                      if (listarSucursalesController.estado.value ==
                          Estado.carga) {
                        return const Center(
                          child: Text(
                            'Cargando sucursales...',
                            style: TextStyle(color: Colors.black),
                          ),
                        );
                      }
                      if (listarSucursalesController.estado.value ==
                          Estado.error) {
                        return const Center(
                          child: Text(
                            'Error al cargar sucursales',
                            style: TextStyle(
                                color: Color.fromARGB(255, 255, 16, 16)),
                          ),
                        );
                      }
                      if (listarSucursalesController.estado.value ==
                          Estado.exito) {
                        if (listarSucursalesController.sucursales.isEmpty) {
                          return const Center(
                            child: Text(
                              'No hay sucursales registradas',
                              style: TextStyle(color: Colors.black),
                            ),
                          );
                        }
                        return DropdownButtonFormField<int>(
                          value: (selectedSucursalId! + 1),
                          decoration: InputDecoration(
                            labelText: 'Seleccionar Sucursal',
                            labelStyle: const TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                          ),
                          dropdownColor:
                              const Color.fromARGB(255, 255, 255, 255),
                          style: const TextStyle(color: Colors.black),
                          items: listarSucursalesController.sucursales
                              .map((sucursal) {
                            return DropdownMenuItem<int>(
                              value: sucursal.idSucursal,
                              child: Text(
                                sucursal.nombre,
                                style: const TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            selectedSucursalId = value;
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Por favor seleccione una sucursal';
                            }
                            return null;
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildLabel("Imagen: "),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      selectImage();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 153, 103, 8),
                    ),
                    child: Text(
                      _getButtonText(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 20),
                  _buildImagePreview(),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      editarAdministrador();
                    },
                    child: const Text('Agregar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    telefonoController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  // Widget reutilizable para TextFormField
  Widget _buildTextFormField({
    required String labelText,
    TextEditingController? controller,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      style: const TextStyle(color: Colors.black),
    );
  }

  // Widget reutilizable para las etiquetas
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
    );
  }

  // Widget especializado para el campo de teléfono
  Widget _buildPhoneTextFormField({
    required String labelText,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 10,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly, // Solo permite dígitos
      ],
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black),
        ),
        counterText: '', // Oculta el contador "0/10"
      ),
      style: const TextStyle(color: Colors.black),
    );
  }

  // Método para obtener el texto del botón
  String _getButtonText() {
    if (imagenController.isNotEmpty) {
      return 'Cambiar imagen';
    } else if (imagenbase64 != null && imagenbase64!.isNotEmpty) {
      return 'Cambiar imagen';
    } else {
      return 'Seleccionar imagen';
    }
  }

  Widget _buildImagePreview() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: _getImageWidget(),
      ),
    );
  }

  // Widget para mostrar la imagen según la prioridad
  Widget _getImageWidget() {
    // Prioridad 1: Si hay una nueva imagen seleccionada, mostrarla
    if (imagenController.isNotEmpty) {
      return Image.file(
        File(imagenController),
        fit: BoxFit.cover,
      );
    }

    // Prioridad 2: Si hay imagen base64, mostrarla
    if (imagenbase64 != null && imagenbase64!.isNotEmpty) {
      try {
        Uint8List imageBytes = base64Decode(imagenbase64!);
        return Image.memory(
          imageBytes,
          fit: BoxFit.cover,
        );
      } catch (e) {
        print('Error al decodificar imagen base64: $e');
        return const Icon(
          Icons.image,
          size: 40,
          color: Colors.grey,
        );
      }
    }

    // Si no hay ninguna imagen, mostrar el ícono gris
    return const Icon(
      Icons.image,
      size: 40,
      color: Colors.grey,
    );
  }
}
