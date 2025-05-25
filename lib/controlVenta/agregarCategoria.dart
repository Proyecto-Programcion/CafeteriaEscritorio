import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/categoriaGastos/controllers/actualizarCategoriaGastosController.dart';
import 'package:cafe/logica/categoriaGastos/controllers/agregarCategoriaGastosController.dart';
import 'package:cafe/logica/categoriaGastos/controllers/eliminarCategoriaGastosController.dart';
import 'package:cafe/logica/categoriaGastos/controllers/obtenerCategoriaGastosController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegistrarCategoriasGastos extends StatefulWidget {
  const RegistrarCategoriasGastos({super.key});

  @override
  State<RegistrarCategoriasGastos> createState() => _RegistrarCategoriasGastosState();
}

class _RegistrarCategoriasGastosState extends State<RegistrarCategoriasGastos> {
  static const cardColor = Colors.white;
  static const primaryTextColor = Color(0xFF9B7B22);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final AgregarCategoriaGastosController _agregarController = Get.put(AgregarCategoriaGastosController());
  final ActualizarCategoriaGastoController _actualizarController = Get.put(ActualizarCategoriaGastoController());
  final EliminarCategoriaGastoController _eliminarController = Get.put(EliminarCategoriaGastoController());

  bool _isLoading = false;
  String? _errorText;
  int? _editIdCategoria;

  void _llenarParaEditar(int id, String nombre, String? descripcion) {
    setState(() {
      _editIdCategoria = id;
      _nombreController.text = nombre;
      _descripcionController.text = descripcion ?? '';
      _errorText = null;
    });
  }

  Future<void> _guardarCategoria() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    bool exito;
    if (_editIdCategoria != null) {
      exito = await _actualizarController.actualizarCategoria(
        idCategoria: _editIdCategoria!,
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
      );
    } else {
      exito = await _agregarController.agregarCategoria(
        _nombreController.text.trim(),
        _descripcionController.text.trim(),
      );
    }

    setState(() => _isLoading = false);

    if (exito) {
      Navigator.pop(context, true);
      Get.snackbar(
        '¡Éxito!',
        _editIdCategoria != null ? 'Categoría editada correctamente' : 'Categoría agregada correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      setState(() {
        _errorText = _editIdCategoria != null
            ? _actualizarController.mensaje.value
            : _agregarController.mensaje.value;
      });
    }
  }

  void _limpiarFormulario() {
    setState(() {
      _editIdCategoria = null;
      _nombreController.clear();
      _descripcionController.clear();
      _errorText = null;
    });
  }

  Future<void> _eliminarCategoria(int idCategoria) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar categoría?'),
        content: const Text('Esta acción no se puede deshacer. ¿Estás seguro que deseas eliminar la categoría?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _isLoading = true);
    final exito = await _eliminarController.eliminarCategoria(idCategoria);
    setState(() => _isLoading = false);
    if (exito) {
      Navigator.pop(context, true);
      Get.snackbar('¡Éxito!', 'Categoría eliminada correctamente', snackPosition: SnackPosition.BOTTOM);
      _limpiarFormulario();
    } else {
      Get.snackbar('Error', _eliminarController.mensaje.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red[50]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriasController = Get.find<ObtenerCategoriasGastosController>();
    return Dialog(
      insetPadding: const EdgeInsets.all(40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SizedBox(
        width: 700,
        height: 420,
        child: Row(
          children: [
            // Apartado izquierdo: Agregar/Editar categoría
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.category, color: primaryTextColor),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _editIdCategoria != null ? 'Editar Categoría' : 'Agregar Categoría',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: primaryTextColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                          if (_editIdCategoria != null)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.redAccent),
                              tooltip: "Cancelar edición",
                              onPressed: _limpiarFormulario,
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text('Nombre de la categoría *'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nombreController,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Ingrese el nombre'
                            : null,
                        decoration: InputDecoration(
                          hintText: 'Ej: Papelería',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: cardColor,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text('Descripción'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descripcionController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Descripción opcional',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: cardColor,
                        ),
                      ),
                      if (_errorText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            _errorText!,
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                      const Spacer(),
                      Center(
                        child: SizedBox(
                          width: 170,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _guardarCategoria,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryTextColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.3,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.save_alt, color: Colors.white, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        _editIdCategoria != null ? 'Guardar Cambios' : 'Guardar',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: 1,
              height: double.infinity,
              color: Colors.grey.shade200,
              margin: const EdgeInsets.symmetric(vertical: 24),
            ),
            // Apartado derecho: Lista de categorías (SOLO EN EL MODAL)
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: Obx(() {
                  if (categoriasController.estado.value == Estado.carga) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (categoriasController.listaCategorias.isEmpty) {
                    return const Center(
                      child: Text(
                        "No hay categorías registradas",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: categoriasController.listaCategorias.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final cat = categoriasController.listaCategorias[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: primaryTextColor.withOpacity(0.08),
                          child: const Icon(Icons.folder, color: primaryTextColor, size: 19),
                        ),
                        title: Text(cat.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(cat.descripcion ?? ""),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              tooltip: "Editar",
                              onPressed: () {
                                _llenarParaEditar(cat.idCategoria, cat.nombre, cat.descripcion);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              tooltip: "Eliminar",
                              onPressed: () {
                                _eliminarCategoria(cat.idCategoria);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}