import 'package:cafe/common/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cafe/logica/clientes/controllers/obtenerClientes.dart';
import 'package:cafe/logica/clientes/clientesModel.dart';
import 'package:cafe/usuarios/widgets/registerClientes.dart';

class ModalRealizarVenta extends StatefulWidget {
  final void Function(usuariMmodel?)? onIrAPagar;
  final double totalVenta;
  final double descuento;

  const ModalRealizarVenta({
    super.key,
    this.onIrAPagar,
    required this.totalVenta,
    required this.descuento,
  });

  @override
  State<ModalRealizarVenta> createState() => _ModalRealizarVentaState();
}

class _ModalRealizarVentaState extends State<ModalRealizarVenta> {
  usuariMmodel? usuarioSeleccionado;
  final TextEditingController _buscadorController = TextEditingController();
  final ObtenerClientesController clientesController =
      Get.put(ObtenerClientesController());
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _buscadorController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _abrirModalRegistrarCliente() async {
    await showDialog(
      context: context,
      builder: (context) => const ModalRegistrarCliente(),
    );
    await clientesController.obtenerClientes();
  }

  final List<Map<String, dynamic>> promociones = [
    {
      'icono': Icons.local_offer,
      'iconColor': Colors.deepOrange,
      'cardColor': const Color(0xFFFFF8E1),
      'titulo': "Café gratis en tu próxima compra",
      'subtitulo': "Válido hasta el 31/05/2025",
    },
    {
      'icono': Icons.discount,
      'iconColor': Colors.green,
      'cardColor': const Color(0xFFE8F5E9),
      'titulo': "10% de descuento en alimentos",
      'subtitulo': "Válido para pedidos superiores a \$100",
    },
    // ...más promociones...
  ];

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
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person,
                                        size: 30, color: Colors.amber),
                                    const SizedBox(width: 12),
                                    Text(
                                      usuarioSeleccionado!.nombre,
                                      style: const TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Icon(Icons.phone_android,
                                        size: 26, color: Colors.amber),
                                    const SizedBox(width: 12),
                                    Text(
                                      usuarioSeleccionado!.numeroTelefono,
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                const Text(
                                  "Promociones vigentes para el usuario",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.brown,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Scrollbar(
                                    controller: _scrollController,
                                    thumbVisibility: true,
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      padding: EdgeInsets.zero,
                                      itemCount: promociones.length,
                                      itemBuilder: (context, index) {
                                        final promo = promociones[index];
                                        return CardPromocion01(
                                          icono: promo['icono'],
                                          iconColor: promo['iconColor'],
                                          cardColor: promo['cardColor'],
                                          titulo: promo['titulo'],
                                          subtitulo: promo['subtitulo'],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    // --- BLOQUE FIJO: Totales y botones ---
                    Divider(height: 32, thickness: 2, color: Colors.grey[200]),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 4),
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
                                '-\$${widget.descuento.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
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
                          foregroundColor: Colors.deepPurple,
                          textStyle: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (widget.onIrAPagar != null) {
                            widget.onIrAPagar!(usuarioSeleccionado);
                          }
                          Navigator.of(context).pop(usuarioSeleccionado);
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
                          foregroundColor: Colors.white,
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
