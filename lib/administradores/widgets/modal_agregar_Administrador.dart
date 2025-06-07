import 'dart:io';

import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/administradores/controller/agregar_administrador_controller.dart';
import 'package:cafe/logica/administradores/controller/listar_sucursales_controller.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Agrega esta importación
import 'package:get/get.dart';

class ModalAgregarAdministrador extends StatefulWidget {
  const ModalAgregarAdministrador({super.key});

  @override
  State<ModalAgregarAdministrador> createState() =>
      _ModalAgregarAdministradorState();
}

class _ModalAgregarAdministradorState extends State<ModalAgregarAdministrador> {
  final ListarSucursalesController listarSucursalesController = Get.put(
    ListarSucursalesController(),
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controladores para los campos
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController tipoAdminController = TextEditingController();

  int? selectedSucursalId;

  @override
  void initState() {
    super.initState();
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

  void agregarAdministrador() async {
    if (_formKey.currentState!.validate()) {
      final AgregarAdministradorController agregarAdministradorController =
          Get.put(AgregarAdministradorController());
      final resp = await agregarAdministradorController.agregarAdministrador(
          nombre: nombreController.text,
          telefono: telefonoController.text,
          correo: correoController.text,
          urlImagen: imagenController,
          idSucursal: selectedSucursalId!,
          contrasena: contrasenaController.text,
          rol: tipoAdminController.text
          );

    }
  }

  List<DropdownMenuItem<String>> tipoAdmin = [
    const DropdownMenuItem(
      value: "Admin",
      child: Text("Administrador"),
    ),
    const DropdownMenuItem(
      value: "Empleado",
      child: Text("Empleado"),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: Container(
        padding: const EdgeInsets.all(20),
        width: 840,
        height: 650,
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

              // Campo Contraseña
              Row(
                children: [
                  _buildLabel("Contraseña: "),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextFormField(
                      labelText: 'Contraseña',
                      controller: contrasenaController,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese la contraseña';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
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
                      return DropdownButtonFormField<int>(
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
                        dropdownColor: const Color.fromARGB(255, 255, 255, 255),
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
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo Tipo de Administrador
              Row(
                children: [
                  _buildLabel("Tipo de Administrador: "),
                  const SizedBox(width: 10),
                  Expanded( // Agregado Expanded para dar ancho al dropdown
                    child: DropdownButtonFormField<String>(
                      value: "Admin",
                      decoration: InputDecoration(
                        labelText: 'Seleccionar el tipo de administrador',
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
                      dropdownColor: const Color.fromARGB(255, 255, 255, 255),
                      style: const TextStyle(color: Colors.black),
                      items: tipoAdmin,
                      onChanged: (value) {
                        tipoAdminController.text = value!;
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor seleccione un tipo';
                        }
                        return null;
                      },
                    ),
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
                      imagenController.isNotEmpty
                          ? 'Cambiar Imagen'
                          : 'Seleccionar Imagen',
                      style: TextStyle(color: Colors.white),
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
                      agregarAdministrador();
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

  Widget _buildImagePreview() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      child: imagenController.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(imagenController),
                fit: BoxFit.cover,
              ),
            )
          : const Icon(
              Icons.image,
              size: 40,
              color: Colors.grey,
            ),
    );
  }
}
