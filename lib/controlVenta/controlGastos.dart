import 'package:cafe/common/enums.dart';
import 'package:cafe/controlVenta/agregarCategoria.dart';
import 'package:cafe/controlVenta/gananciasPorCategoria.dart';
import 'package:cafe/logica/categoriaGastos/controllers/obtenerCategoriaGastosController.dart';
import 'package:cafe/logica/controlGastos/controlGastosModel.dart';
import 'package:cafe/logica/controlGastos/controllers/agregarControlGastos.dart';
import 'package:cafe/logica/controlGastos/controllers/elimnarGastoController.dart';
import 'package:cafe/logica/controlGastos/controllers/obtenerGastosContoller.dart';
import 'package:cafe/logica/controlGastos/controllers/actualizarGastoController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ControlDeGastosScreen extends StatefulWidget {
  const ControlDeGastosScreen({super.key});

  static const fondoColor = Color(0xFFFAF0E6);
  static const cardColor = Colors.white;
  static const sombra = 0.09;
  static const primaryTextColor = Color(0xFF9B7B22);

  @override
  State<ControlDeGastosScreen> createState() => _ControlDeGastosScreenState();
}

class _ControlDeGastosScreenState extends State<ControlDeGastosScreen> {
  final categoriasController = Get.put(ObtenerCategoriasGastosController());
  final gastosController = Get.put(ObtenerGastosController());
  final AgregarGastoController _agregarGastoController =
      Get.put(AgregarGastoController());
  final ActualizarGastoController _actualizarGastoController =
      Get.put(ActualizarGastoController());
  final EliminarGastoController _eliminarGastoController =
      Get.put(EliminarGastoController());

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  int? _categoriaSeleccionada;
  DateTime? _fechaGasto;
  String _metodoPago = "Efectivo";
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _notasController = TextEditingController();

  bool _isLoading = false;
  bool _editando = false;
  int? _idGastoEditando;

  void _limpiarFormulario() {
    _descripcionController.clear();
    _montoController.clear();
    _categoriaSeleccionada = null;
    _fechaGasto = null;
    _metodoPago = "Efectivo";
    _ubicacionController.clear();
    _notasController.clear();
    _idGastoEditando = null;
    _editando = false;
    setState(() {});
  }

  void _llenarFormularioParaEditar(GastoModelo gasto) {
    _descripcionController.text = gasto.descripcion;
    _montoController.text = gasto.monto.toStringAsFixed(2);
    _categoriaSeleccionada = gasto.idCategoria;
    _fechaGasto = gasto.fechaGasto;
    _metodoPago = gasto.metodoPago;
    _ubicacionController.text = gasto.ubicacion ?? '';
    _notasController.text = gasto.notas ?? '';
    _idGastoEditando = gasto.idGasto;
    _editando = true;
    setState(() {});
  }

  Future<void> _eliminarGasto() async {
    if (_idGastoEditando == null) return;
    final bool confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar gasto'),
        content: const Text(
            '¿Estás seguro de que deseas eliminar este gasto? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    setState(() => _isLoading = true);
    final exito =
        await _eliminarGastoController.eliminarGasto(_idGastoEditando!);
    setState(() => _isLoading = false);

    if (exito) {
      Get.snackbar('¡Éxito!', 'Gasto eliminado correctamente',
          snackPosition: SnackPosition.BOTTOM);
      await gastosController.obtenerGastos();
      _limpiarFormulario();
    } else {
      Get.snackbar('Error', _eliminarGastoController.mensaje.value,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red[50]);
    }
  }

  Future<void> _guardarOActualizarGasto() async {
    if (!_formKey.currentState!.validate() ||
        _categoriaSeleccionada == null ||
        _fechaGasto == null) {
      Get.snackbar('Campos requeridos', 'Llena todos los campos obligatorios',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.yellow[50]);
      return;
    }
    setState(() => _isLoading = true);

    bool exito = false;
    if (_editando && _idGastoEditando != null) {
      exito = await _actualizarGastoController.actualizarGasto(
        idGasto: _idGastoEditando!,
        idCategoria: _categoriaSeleccionada!,
        descripcion: _descripcionController.text.trim(),
        monto: double.tryParse(_montoController.text.trim()) ?? 0,
        fechaGasto: _fechaGasto!,
        metodoPago: _metodoPago,
        notas: _notasController.text.trim().isEmpty
            ? null
            : _notasController.text.trim(),
        ubicacion: _ubicacionController.text.trim().isEmpty
            ? null
            : _ubicacionController.text.trim(),
      );
    } else {
      exito = await _agregarGastoController.agregarGasto(
        idCategoria: _categoriaSeleccionada!,
        descripcion: _descripcionController.text.trim(),
        monto: double.tryParse(_montoController.text.trim()) ?? 0,
        fechaGasto: _fechaGasto!,
        metodoPago: _metodoPago,
        notas: _notasController.text.trim().isEmpty
            ? null
            : _notasController.text.trim(),
        ubicacion: _ubicacionController.text.trim().isEmpty
            ? null
            : _ubicacionController.text.trim(),
      );
    }
    setState(() => _isLoading = false);

    if (exito) {
      Get.snackbar(
          '¡Éxito!',
          _editando
              ? 'Gasto actualizado correctamente'
              : 'Gasto agregado correctamente',
          snackPosition: SnackPosition.BOTTOM);
      await gastosController.obtenerGastos();
      _limpiarFormulario();
    } else {
      Get.snackbar(
          'Error',
          _editando
              ? _actualizarGastoController.mensaje.value
              : _agregarGastoController.mensaje.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[50]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ControlDeGastosScreen.fondoColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth > 1400
              ? 40.0
              : constraints.maxWidth > 1100
                  ? 18.0
                  : 8.0;

          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: 24),
            child: Column(
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) =>
                              const RegistrarCategoriasGastos(),
                        );
                        await categoriasController.obtenerCategorias();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ControlDeGastosScreen.primaryTextColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 28),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add, size: 22),
                          SizedBox(width: 8),
                          Text("Agregar categoría"),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.bar_chart),
                      label: const Text('Ver Ganancias por Categoría'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ControlDeGastosScreen.primaryTextColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => GananciasPorCategoriaScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: LayoutBuilder(
                            builder: (context, colConstraints) {
                              return SizedBox(
                                height: double.infinity,
                                child: Card(
                                  elevation: 0,
                                  color: ControlDeGastosScreen.cardColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  shadowColor: Colors.black.withOpacity(
                                      ControlDeGastosScreen.sombra),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 30, horizontal: 26),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // ENCABEZADO
                                          Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: ControlDeGastosScreen
                                                      .primaryTextColor
                                                      .withOpacity(0.11),
                                                  shape: BoxShape.circle,
                                                ),
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Icon(
                                                  _editando
                                                      ? Icons.edit
                                                      : Icons.add,
                                                  size: 24,
                                                  color: ControlDeGastosScreen
                                                      .primaryTextColor,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                _editando
                                                    ? 'Editar Gasto'
                                                    : 'Registrar Nuevo Gasto',
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const Spacer(),
                                              if (_editando)
                                                IconButton(
                                                  tooltip: "Eliminar gasto",
                                                  icon: const Icon(Icons.delete,
                                                      color: Colors.red,
                                                      size: 28),
                                                  onPressed: _isLoading
                                                      ? null
                                                      : _eliminarGasto,
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 24),
                                          const Text('Descripción *'),
                                          const SizedBox(height: 4),
                                          TextFormField(
                                            controller: _descripcionController,
                                            validator: (v) =>
                                                (v == null || v.trim().isEmpty)
                                                    ? 'Ingrese la descripción'
                                                    : null,
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Ej: Almuerzo en restaurante',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                              filled: true,
                                              fillColor: ControlDeGastosScreen
                                                  .cardColor,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text('Monto *'),
                                                    const SizedBox(height: 4),
                                                    TextFormField(
                                                      controller:
                                                          _montoController,
                                                      validator: (v) => (v ==
                                                                  null ||
                                                              v.trim().isEmpty)
                                                          ? 'Ingrese el monto'
                                                          : double.tryParse(
                                                                      v) ==
                                                                  null
                                                              ? 'Ingrese un número válido'
                                                              : null,
                                                      keyboardType:
                                                          const TextInputType
                                                              .numberWithOptions(
                                                              decimal: true),
                                                      decoration:
                                                          InputDecoration(
                                                        hintText: '0.00',
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 12,
                                                                vertical: 10),
                                                        filled: true,
                                                        fillColor:
                                                            ControlDeGastosScreen
                                                                .cardColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text('Categoría *'),
                                                    const SizedBox(height: 4),
                                                    Obx(() {
                                                      final cats =
                                                          categoriasController
                                                              .listaCategorias;
                                                      return DropdownButtonFormField<
                                                          int>(
                                                        value:
                                                            _categoriaSeleccionada,
                                                        items: [
                                                          const DropdownMenuItem(
                                                              value: null,
                                                              child: Text(
                                                                  "Seleccione")),
                                                          ...cats.map((cat) =>
                                                              DropdownMenuItem(
                                                                value: cat
                                                                    .idCategoria,
                                                                child: Text(
                                                                    cat.nombre),
                                                              )),
                                                        ],
                                                        onChanged: (v) {
                                                          setState(() {
                                                            _categoriaSeleccionada =
                                                                v;
                                                          });
                                                        },
                                                        validator: (v) => v ==
                                                                null
                                                            ? 'Seleccione una categoría'
                                                            : null,
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 0),
                                                          filled: true,
                                                          fillColor:
                                                              ControlDeGastosScreen
                                                                  .cardColor,
                                                        ),
                                                      );
                                                    }),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                        'Fecha del Gasto *'),
                                                    const SizedBox(height: 4),
                                                    InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      onTap: () async {
                                                        final picked =
                                                            await showDatePicker(
                                                          context: context,
                                                          initialDate:
                                                              _fechaGasto ??
                                                                  DateTime
                                                                      .now(),
                                                          firstDate:
                                                              DateTime(2000),
                                                          lastDate:
                                                              DateTime(2100),
                                                        );
                                                        if (picked != null) {
                                                          setState(() {
                                                            _fechaGasto =
                                                                picked;
                                                          });
                                                        }
                                                      },
                                                      child: InputDecorator(
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              'dd/mm/aaaa',
                                                          prefixIcon: const Icon(
                                                              Icons
                                                                  .calendar_today,
                                                              size: 20),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 10),
                                                          filled: true,
                                                          fillColor:
                                                              ControlDeGastosScreen
                                                                  .cardColor,
                                                        ),
                                                        child: Text(
                                                          _fechaGasto == null
                                                              ? ''
                                                              : "${_fechaGasto!.day.toString().padLeft(2, '0')}/${_fechaGasto!.month.toString().padLeft(2, '0')}/${_fechaGasto!.year}",
                                                          style: TextStyle(
                                                            color:
                                                                _fechaGasto ==
                                                                        null
                                                                    ? Colors
                                                                        .grey
                                                                    : Colors
                                                                        .black,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                        'Método de Pago'),
                                                    const SizedBox(height: 4),
                                                    DropdownButtonFormField<
                                                        String>(
                                                      value: _metodoPago,
                                                      items: const [
                                                        DropdownMenuItem(
                                                            value: "Efectivo",
                                                            child: Text(
                                                                "Efectivo")),
                                                        DropdownMenuItem(
                                                            value: "Tarjeta",
                                                            child: Text(
                                                                "Tarjeta")),
                                                        DropdownMenuItem(
                                                            value: "Otro",
                                                            child:
                                                                Text("Otro")),
                                                      ],
                                                      onChanged: (v) {
                                                        setState(() {
                                                          _metodoPago = v!;
                                                        });
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 12,
                                                                vertical: 0),
                                                        filled: true,
                                                        fillColor:
                                                            ControlDeGastosScreen
                                                                .cardColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          const Text('Ubicación'),
                                          const SizedBox(height: 4),
                                          TextFormField(
                                            controller: _ubicacionController,
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Ej: Centro Comercial Plaza N',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                              filled: true,
                                              fillColor: ControlDeGastosScreen
                                                  .cardColor,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const Text('Notas Adicionales'),
                                          const SizedBox(height: 4),
                                          TextFormField(
                                            controller: _notasController,
                                            maxLines: 3,
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Observaciones opcionales...',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                              filled: true,
                                              fillColor: ControlDeGastosScreen
                                                  .cardColor,
                                            ),
                                          ),
                                          const Spacer(),
                                          // BOTONES ABAJO (ARREGLADO OVERFLOW)
                                          Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: SizedBox(
                                                    height: 48,
                                                    child: ElevatedButton.icon(
                                                      onPressed: _isLoading
                                                          ? null
                                                          : _guardarOActualizarGasto,
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            ControlDeGastosScreen
                                                                .primaryTextColor,
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 12),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                        ),
                                                        elevation: 2,
                                                      ),
                                                      icon: Icon(
                                                        _editando
                                                            ? Icons
                                                                .edit_outlined
                                                            : Icons.save_alt,
                                                        color: Colors.white,
                                                        size: 22,
                                                      ),
                                                      label: Text(
                                                        _editando
                                                            ? 'Actualizar'
                                                            : 'Guardar',
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                if (_editando)
                                                  Expanded(
                                                    child: SizedBox(
                                                      height: 48,
                                                      child:
                                                          OutlinedButton.icon(
                                                        onPressed:
                                                            _limpiarFormulario,
                                                        icon: const Icon(
                                                            Icons.close,
                                                            color:
                                                                Colors.black54,
                                                            size: 24),
                                                        label: const Text(
                                                          'Cancelar',
                                                          style: TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                        style: OutlinedButton
                                                            .styleFrom(
                                                          side:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .black26,
                                                                  width: 2),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30),
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      20),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 8,
                        child: Card(
                          elevation: 0,
                          color: ControlDeGastosScreen.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          shadowColor: Colors.black
                              .withOpacity(ControlDeGastosScreen.sombra),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 28, horizontal: 44),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: ControlDeGastosScreen
                                            .primaryTextColor
                                            .withOpacity(0.11),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: const Icon(
                                          Icons.sticky_note_2_outlined,
                                          color: ControlDeGastosScreen
                                              .primaryTextColor,
                                          size: 24),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Lista de Gastos',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Expanded(
                                  child: Obx(() {
                                    if (gastosController.estado.value ==
                                        Estado.carga) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }
                                    if (gastosController.listaGastos.isEmpty) {
                                      return const Center(
                                        child: Text(
                                          "No hay gastos registrados",
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 16),
                                        ),
                                      );
                                    }
                                    final gastos = gastosController.listaGastos;
                                    return ListView.separated(
                                      itemCount: gastos.length,
                                      separatorBuilder: (_, __) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final gasto = gastos[index];
                                        return ListTile(
                                          onTap: () =>
                                              _llenarFormularioParaEditar(
                                                  gasto),
                                          leading: CircleAvatar(
                                            backgroundColor:
                                                ControlDeGastosScreen
                                                    .primaryTextColor
                                                    .withOpacity(0.08),
                                            child: const Icon(
                                                Icons.attach_money,
                                                color: ControlDeGastosScreen
                                                    .primaryTextColor,
                                                size: 19),
                                          ),
                                          title: Text(
                                            gasto.descripcion,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          subtitle: Text(
                                            "${gasto.nombreCategoria}  |  ${gasto.fechaGasto.day.toString().padLeft(2, '0')}/${gasto.fechaGasto.month.toString().padLeft(2, '0')}/${gasto.fechaGasto.year}  |  \$${gasto.monto.toStringAsFixed(2)}",
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          trailing: Text(
                                            gasto.metodoPago,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black54),
                                          ),
                                        );
                                      },
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
