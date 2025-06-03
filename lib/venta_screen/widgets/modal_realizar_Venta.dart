import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/promociones/controllers/obenerPromociones.dart';
import 'package:cafe/logica/promociones/controllers/obtener_promociones_productos_gratis.dart';
import 'package:cafe/logica/venta/controllers/realizar_venta_controller.dart';
import 'package:cafe/venta_screen/widgets/modal_promociones_disponibles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cafe/logica/clientes/controllers/obtenerClientes.dart';
import 'package:cafe/logica/clientes/clientesModel.dart';
import 'package:cafe/usuarios/widgets/registerClientes.dart';
import 'package:cafe/logica/promociones/promocionModel.dart';
import 'package:cafe/logica/promociones/promocion_producto_gratis_modelo.dart';
import 'package:cafe/logica/productos/producto_modelos.dart';
import 'package:cafe/logica/promociones/promociones_Canjeadas.dart';

class ModalRealizarVenta extends StatefulWidget {
  final void Function(
      usuariMmodel?,
      int?,
      int?,
      PromocionProductoGratiConNombreDelProductosModelo?,
      double)? onIrAPagar; // Agregar double para descuento
  final double totalVenta;
  final double descuento;
  final List<ProductoCarrito> carrito;

  const ModalRealizarVenta({
    super.key,
    this.onIrAPagar,
    required this.totalVenta,
    required this.descuento,
    required this.carrito,
  });

  @override
  State<ModalRealizarVenta> createState() => _ModalRealizarVentaState();
}

class _ModalRealizarVentaState extends State<ModalRealizarVenta> {
  usuariMmodel? usuarioSeleccionado;
  Promocion? promocionDescuentoSeleccionada;
  PromocionProductoGratiConNombreDelProductosModelo?
      promocionProductoGratisSeleccionada;
  final TextEditingController _buscadorController = TextEditingController();
  final ObtenerClientesController clientesController =
      Get.put(ObtenerClientesController());
  final ObtenerPromocionesController obtenerPromocionesController =
      Get.put(ObtenerPromocionesController());
  final ObtenerPromocionesProductosGratisController
      obtenerPromocionesProductosGratisController =
      Get.put(ObtenerPromocionesProductosGratisController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    obtenerPromocionesController.obtenerPromociones();
    obtenerPromocionesProductosGratisController.obtenerPromociones();
  }

  @override
  void dispose() {
    _buscadorController.dispose();
    _scrollController.dispose();
    clientesController.filtro.value = '';
    super.dispose();
  }

  Future<void> _abrirModalRegistrarCliente() async {
    await showDialog(
      context: context,
      builder: (context) => const ModalRegistrarCliente(),
    );
    await clientesController.obtenerClientes();
  }

  Future<void> _abrirModalPromociones(
      List<Promocion> promociones,
      List<PromocionProductoGratiConNombreDelProductosModelo>
          promocionesProductoGratis) async {
    final resultado = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => ModalPromocionesDisponibles(
        promocionesDescuento: promociones,
        promocionesProductosGratis: promocionesProductoGratis,
        promocionDescuentoSeleccionada: promocionDescuentoSeleccionada,
        promocionProductoGratisSeleccionada:
            promocionProductoGratisSeleccionada,
      ),
    );

    if (resultado != null) {
      setState(() {
        promocionDescuentoSeleccionada =
            resultado['promocionDescuento'] as Promocion?;
        promocionProductoGratisSeleccionada =
            resultado['promocionProductoGratis']
                as PromocionProductoGratiConNombreDelProductosModelo?;
      });
    }
  }

  // Método para promociones de descuento con validación async
  Future<List<Promocion>> getPromocionesDescuentoFiltradas() async {
  
    final promocionesDescuento = <Promocion>[];

    for (final promo in obtenerPromocionesController.promocionesFiltradas) {

      // Condición 1: Status activo
      bool condicion1 = promo.status;

      // Condición 2: Dinero necesario
      bool condicion2 = widget.totalVenta >= promo.dineroNecesario;
  

      // Condición 3: Compras necesarias
      bool condicion3 =
          promo.comprasNecesarias <= usuarioSeleccionado!.cantidadCompras;


      // Condición 4: No ha canjeado esta promoción antes
      bool condicion4 =
          !(await PromocionesCanjeadasService.clienteYaCanjeoPromocion(
              usuarioSeleccionado!.idCliente, promo.idPromocion));


      // Resultado final
      bool resultado = condicion1 && condicion2 && condicion3 && condicion4;
      

      if (resultado) {
        promocionesDescuento.add(promo);
      }
    }
    return promocionesDescuento;
  }

  // Método para promociones de productos gratis con validación async
  Future<List<PromocionProductoGratiConNombreDelProductosModelo>>
      getPromocionesProductosGratisFiltradas() async {
   

    if (widget.carrito.isEmpty) {
    
      return [];
    }

    final productosEnCarrito =
        widget.carrito.map((item) => item.producto.idProducto).toSet();

  
    final promociones = <PromocionProductoGratiConNombreDelProductosModelo>[];

    for (final promo
        in obtenerPromocionesProductosGratisController.listaPromociones) {
     

      // Condición 1: Status
      bool condicion1 = promo.status;
      

      // Condición 2: Producto en carrito
      bool condicion2 = productosEnCarrito.contains(promo.idProducto);
   

      // Condición 3: Dinero suficiente
      bool condicion3 = widget.totalVenta >= promo.dineroNecesario;
    
      // Condición 4: Compras suficientes
      bool condicion4 = promo.comprasNecesarias <=
          (usuarioSeleccionado?.cantidadCompras ?? 0);
    

      // Condición 5: No ha canjeado esta promoción antes
      bool condicion5 =
          !(await PromocionesCanjeadasService.clienteYaCanjeoPromocionGratis(
              usuarioSeleccionado!.idCliente, promo.idPromocionProductoGratis));
     

      bool resultado =
          condicion1 && condicion2 && condicion3 && condicion4 && condicion5;
     

      if (resultado) {
        promociones.add(promo);
      }
    }

  

    return promociones;
  }

  // Método helper para cargar ambas promociones
  Future<Map<String, List>> cargarPromociones() async {
    if (usuarioSeleccionado == null) {
      return {
        'descuento': <Promocion>[],
        'productos_gratis':
            <PromocionProductoGratiConNombreDelProductosModelo>[]
      };
    }

    final promocionesDescuento = await getPromocionesDescuentoFiltradas();
    final promocionesProductosGratis =
        await getPromocionesProductosGratisFiltradas();

    return {
      'descuento': promocionesDescuento,
      'productos_gratis': promocionesProductosGratis,
    };
  }

  double calcularDescuento() {
    if (promocionDescuentoSeleccionada == null) {
      return 0.0;
    }

    // Calcular descuento basado en porcentaje
    double descuento =
        widget.totalVenta * (promocionDescuentoSeleccionada!.porcentaje / 100);

    // Verificar si hay un tope de descuento
    if (promocionDescuentoSeleccionada!.topeDescuento > 0 &&
        descuento > promocionDescuentoSeleccionada!.topeDescuento) {
      descuento = promocionDescuentoSeleccionada!.topeDescuento;
    }

    return descuento;
  }

  @override
  Widget build(BuildContext context) {
    final double ancho = MediaQuery.of(context).size.width * 0.7;
    final double alto = MediaQuery.of(context).size.height * 0.7;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SizedBox(
        width: ancho,
        height: alto,
        child: Row(
          children: [
            // Columna izquierda: listado de usuarios + buscador + boton registrar
            Expanded(
              flex: 13,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF9F1E7),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Usuarios registrados (opcional)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Color.fromARGB(255, 153, 103, 8),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: "Registrar nuevo cliente",
                          icon: const Icon(Icons.person_add,
                              color: Colors.amber, size: 30),
                          onPressed: _abrirModalRegistrarCliente,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _buscadorController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "Buscar por número de celular...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 10),
                      ),
                      onChanged: (value) {
                        clientesController.filtro.value = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Obx(() {
                        if (clientesController.estado.value == Estado.carga) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (clientesController.estado.value == Estado.error) {
                          return Center(
                              child: Text(clientesController.mensaje.value));
                        }
                        final lista = clientesController.clientesFiltrados;
                        if (lista.isEmpty) {
                          return const Center(
                              child: Text('No hay usuarios registrados.'));
                        }
                        return ListView.separated(
                          itemCount: lista.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final usuario = lista[index];
                            final seleccionado =
                                usuarioSeleccionado?.idCliente ==
                                    usuario.idCliente;
                            return InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                setState(() {
                                  usuarioSeleccionado =
                                      seleccionado ? null : usuario;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: seleccionado
                                      ? Colors.amber[200]
                                      : Colors.white,
                                  border: Border.all(
                                    color: seleccionado
                                        ? Colors.amber
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.07),
                                      blurRadius: 8,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: Row(
                                  children: [
                                    Icon(
                                      seleccionado
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      color: seleccionado
                                          ? Colors.amber[800]
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            usuario.nombre,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            usuario.numeroTelefono,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
            // Columna derecha: detalles o controles
            Expanded(
              flex: 12,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(30, 80, 80, 80),
                      blurRadius: 10,
                      offset: Offset(-2, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ir a pagar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color.fromARGB(255, 153, 103, 8),
                      ),
                    ),
                    const SizedBox(height: 26),
                    // --- SCROLLABLE AREA for usuario info and promociones ---
                    Expanded(
                      child: usuarioSeleccionado == null
                          ? const Center(
                              child: Text(
                                "Puedes asociar la venta a un usuario seleccionándolo de la lista, o proceder sin usuario.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 17, color: Colors.black54),
                              ),
                            )
                          : FutureBuilder<Map<String, List>>(
                              future: cargarPromociones(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text('Error: ${snapshot.error}'),
                                  );
                                }

                                final promocionesDescuento =
                                    snapshot.data?['descuento']
                                            as List<Promocion>? ??
                                        [];
                                final promocionesProductosGratis =
                                    snapshot.data?['productos_gratis'] as List<
                                            PromocionProductoGratiConNombreDelProductosModelo>? ??
                                        [];

                                if (promocionesDescuento.isEmpty &&
                                    promocionesProductosGratis.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      "No hay promociones disponibles para esta compra o ya han sido canjeadas",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  );
                                }

                                // Mostrar un resumen de las promociones seleccionadas
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Flexible(
                                          child: Text(
                                            "Promociones disponibles",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.brown,
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: TextButton.icon(
                                            icon: const Icon(Icons.local_offer,
                                                size: 20),
                                            label: const Text("Ver ofertas"),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.amber,
                                              textStyle: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                            onPressed: () =>
                                                _abrirModalPromociones(
                                                    promocionesDescuento,
                                                    promocionesProductosGratis),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Promociones de descuento: ${promocionesDescuento.length}',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.green),
                                    ),
                                    Text(
                                      'Productos gratis: ${promocionesProductosGratis.length}',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.amber),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                    // --- BLOQUE FIJO: Totales y botones ---
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '\$${widget.totalVenta.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          // Reemplaza el widget Row que muestra el descuento con este
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Descuento:',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                '-\$${calcularDescuento().toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          // Agregar una nueva fila para mostrar el total con descuento
                          const SizedBox(height: 3),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total con descuento:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                '\$${(widget.totalVenta - calcularDescuento()).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.shopping_cart_checkout),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22)),
                          elevation: 0,
                        ),
                        // Modifica el onPressed del botón "Ir a pagar"
                        onPressed: () {

                          RealizarVentaController realizarVentaController =
                              Get.put(RealizarVentaController());
                          realizarVentaController.cambiarEstadoAcarga();

                          final descuentoCalculado =
                              calcularDescuento(); // Calcular el descuento

                          if (widget.onIrAPagar != null) {
                            widget.onIrAPagar!(
                                usuarioSeleccionado,
                                promocionDescuentoSeleccionada?.idPromocion,
                                promocionProductoGratisSeleccionada
                                    ?.idPromocionProductoGratis,
                                promocionProductoGratisSeleccionada,
                                descuentoCalculado); // Pasar el descuento calculado
                          }

                          Navigator.of(context).pop({
                            'usuario': usuarioSeleccionado,
                            'promocionDescuento':
                                promocionDescuentoSeleccionada,
                            'promocionProductoGratis':
                                promocionProductoGratisSeleccionada,
                            'descuentoCalculado': descuentoCalculado,
                          });
                        },
                        label: const Text(
                          'Ir a pagar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          alignment: Alignment.centerLeft,
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.normal),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
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
}

class CardPromocionDescuento extends StatelessWidget {
  final Promocion promocion;
  final bool seleccionada;

  const CardPromocionDescuento({
    Key? key,
    required this.promocion,
    this.seleccionada = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        color: seleccionada
            ? const Color(
                0xFFB9F6CA) // Verde más intenso cuando está seleccionado
            : const Color(0xFFE8F5E9), // Color verde claro por defecto
        elevation: seleccionada ? 2 : 0,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: seleccionada
              ? const BorderSide(color: Colors.green, width: 2)
              : BorderSide.none,
        ),
        child: ListTile(
          leading: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.discount, color: Colors.green, size: 24),
              if (seleccionada)
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  promocion.nombrePromocion,
                  style: TextStyle(
                    fontWeight:
                        seleccionada ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ),
              if (seleccionada)
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                promocion.descripcion,
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (promocion.comprasNecesarias > 0)
                    Text(
                      'Compras necesarias: ${promocion.comprasNecesarias}',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  if (promocion.comprasNecesarias > 0 &&
                      promocion.dineroNecesario > 0)
                    const Text(
                      ' • ',
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  if (promocion.dineroNecesario > 0)
                    Text(
                      'Mínimo: \$${promocion.dineroNecesario.toStringAsFixed(2)}',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                ],
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${promocion.porcentaje.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 18,
                ),
              ),
              if (promocion.topeDescuento > 0)
                Text(
                  'Tope: \$${promocion.topeDescuento.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
            ],
          ),
        ));
  }
}
// Primero, vamos a crear un nuevo widget para el modal de selección de promociones

class ModalSeleccionPromociones extends StatefulWidget {
  final List<Promocion> promocionesDescuento;
  final List<PromocionProductoGratiConNombreDelProductosModelo>
      promocionesProductosGratis;
  final Promocion? promocionDescuentoSeleccionadaInicial;

  const ModalSeleccionPromociones({
    Key? key,
    required this.promocionesDescuento,
    required this.promocionesProductosGratis,
    this.promocionDescuentoSeleccionadaInicial,
  }) : super(key: key);

  @override
  State<ModalSeleccionPromociones> createState() =>
      _ModalSeleccionPromocionesState();
}

class _ModalSeleccionPromocionesState extends State<ModalSeleccionPromociones> {
  Promocion? promocionDescuentoSeleccionada;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    promocionDescuentoSeleccionada =
        widget.promocionDescuentoSeleccionadaInicial;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Promociones disponibles",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Color.fromARGB(255, 153, 103, 8),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: ListView(
                  controller: _scrollController,
                  children: [
                    // Sección de promociones de descuento
                    if (widget.promocionesDescuento.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          "Selecciona una promoción de descuento:",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                      DropdownButtonFormField<int>(
                        value: promocionDescuentoSeleccionada?.idPromocion,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.green[50],
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.green[200]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.green[200]!),
                          ),
                        ),
                        items: [
                          // Opción para no seleccionar ninguna promoción
                          DropdownMenuItem<int>(
                            value: null,
                            child: Text(
                              'Ninguna promoción seleccionada',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          // Opciones para cada promoción
                          ...widget.promocionesDescuento
                              .map(
                                (promo) => DropdownMenuItem<int>(
                                  value: promo.idPromocion,
                                  child: Text(
                                    '${promo.nombrePromocion} (${promo.porcentaje.toStringAsFixed(0)}%) - Mín: \$ ${promo.dineroNecesario.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              )
                              .toList(),
                        ],
                        onChanged: (int? selectedId) {
                          setState(() {
                            promocionDescuentoSeleccionada = selectedId == null
                                ? null
                                : widget.promocionesDescuento.firstWhere(
                                    (promo) => promo.idPromocion == selectedId);
                          });
                        },
                      ),

                      // Si hay una promoción seleccionada, mostrar detalles
                      if (promocionDescuentoSeleccionada != null) ...[
                        const SizedBox(height: 12),
                        CardPromocionDescuento(
                          promocion: promocionDescuentoSeleccionada!,
                          seleccionada: true,
                        ),
                      ],

                      const SizedBox(height: 20),
                    ],

                    // Sección de promociones de productos gratis
                    if (widget.promocionesProductosGratis.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10, top: 10),
                        child: Text(
                          "Productos gratis disponibles:",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                      // Mostrar tarjetas de productos gratis
                      ...widget.promocionesProductosGratis
                          .map((promo) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: CardPromocionProductoGratis(
                                  promocion: promo,
                                  seleccionada:
                                      true, // Siempre seleccionada automáticamente
                                ),
                              ))
                          .toList(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  onPressed: () {
                    // Devolver la promoción de descuento seleccionada
                    Navigator.of(context).pop(promocionDescuentoSeleccionada);
                  },
                  child: const Text('Aplicar promoción'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CardPromocionProductoGratis extends StatelessWidget {
  final PromocionProductoGratiConNombreDelProductosModelo promocion;
  final bool seleccionada;

  const CardPromocionProductoGratis({
    Key? key,
    required this.promocion,
    this.seleccionada = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: seleccionada
          ? const Color(
              0xFFFFECB3) // Ámbar más intenso cuando está seleccionado
          : const Color(0xFFFFF8E1), // Color ámbar claro por defecto
      elevation: seleccionada ? 2 : 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: seleccionada
            ? const BorderSide(color: Colors.amber, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.card_giftcard, color: Colors.amber, size: 24),
            if (seleccionada)
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.amber,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                promocion.nombrePromocion,
                style: TextStyle(
                  fontWeight: seleccionada ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ),
            if (seleccionada)
              const Icon(Icons.check_circle, color: Colors.amber, size: 20),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              promocion.descripcion,
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (promocion.comprasNecesarias > 0)
                  Text(
                    'Compras necesarias: ${promocion.comprasNecesarias}',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                if (promocion.comprasNecesarias > 0 &&
                    promocion.dineroNecesario > 0)
                  const Text(
                    ' • ',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                if (promocion.dineroNecesario > 0)
                  Text(
                    'Mínimo: \$${promocion.dineroNecesario.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Producto: ${promocion.nombreProducto}",
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.deepOrange),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${promocion.cantidadProducto.toStringAsFixed(promocion.cantidadProducto.truncateToDouble() == promocion.cantidadProducto ? 0 : 2)} ${promocion.unidadDeMedidaProducto}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: promocion.status ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                promocion.status ? 'Activa' : 'Inactiva',
                style: TextStyle(
                  fontSize: 10,
                  color: promocion.status ? Colors.green[800] : Colors.red[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardPromocion01 extends StatelessWidget {
  final IconData icono;
  final Color iconColor;
  final Color cardColor;
  final String titulo;
  final String subtitulo;

  const CardPromocion01({
    super.key,
    required this.icono,
    required this.iconColor,
    required this.cardColor,
    required this.titulo,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icono, color: iconColor),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitulo),
      ),
    );
  }
}
