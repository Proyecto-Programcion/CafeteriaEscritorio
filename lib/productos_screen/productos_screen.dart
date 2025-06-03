import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/categorias/controllers/obtener_categorias_controller.dart';
import 'package:cafe/logica/productos/controllers/actualizar_imagen_producto_controller.dart';
import 'package:cafe/logica/productos/controllers/aumentar_stock_producto_controller.dart';
import 'package:cafe/logica/productos/controllers/obtener_productos_controllers.dart';
import 'package:cafe/productos_screen/widgets/cabezera_tabla_productos_widgets.dart';
import 'package:cafe/productos_screen/widgets/fila_tabla_producto_widget.dart';
import 'package:cafe/productos_screen/widgets/modal_agregar_categorias_widget.dart';
import 'package:cafe/productos_screen/widgets/modal_agregar_nuevo_producto_widget.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final ObtenerProductosControllers obtenerProductosControllers =
      Get.put(ObtenerProductosControllers());
  String imagenController = '';

  //Seleccionar la imagen
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

  void actualizarImagen(int idProducto) async {
    await selectImage();

    final ActualizarImagenProductoController
        actualizarImagenProductoController = Get.put(
      ActualizarImagenProductoController(),
    );
    final imagenActualizada = await actualizarImagenProductoController
        .actualizarImagenProducto(idProducto, imagenController);
    if (imagenActualizada) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imagen actualizada con éxito'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  final AumentarStockProductoController aumentarStockProductoController =
      Get.put(AumentarStockProductoController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    obtenerProductosControllers.obtenerProductos();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ////***********************************************TITULO DE LA PANTALLA */
          const Text(
            'LISTA DE PRODUCTOS',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 153, 103, 8),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ////***********************************************BOTON PARA AGREGAR UN NUEVO PRODUCTO */
          Row(
            children: [
              InkWell(
                onTap: () {
                  // Acción al presionar
                  showDialog(
                      context: context,
                      builder: (context) {
                        return ModalAgregarNuevoProductoWidget();
                      });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.add, color: Colors.black),
                      SizedBox(width: 10),
                      Text(
                        'Agregar nuevo producto',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              InkWell(
                onTap: () {
                  // Acción al presionar
                  final ObtenerCategoriasController
                      obtenerCategoriasController =
                      Get.put(ObtenerCategoriasController());
                  obtenerCategoriasController.obtenerCategorias();
                  showDialog(
                      context: context,
                      builder: (context) {
                        return ModalAgregarCategoriasWidget();
                      });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.add, color: Colors.black),
                      SizedBox(width: 10),
                      Text(
                        'Agregar categorias',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          ////***********************************************CONTENEDOR DE LA LISTA DE LOS PRODUCTOS */
          Expanded(
              child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                  color: const Color.fromARGB(255, 0, 0, 0), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const CabezeraTablaProductosWidget(),
                Expanded(child: Obx(() {
                  if (obtenerProductosControllers.estado.value ==
                      Estado.carga) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (obtenerProductosControllers.estado.value ==
                      Estado.error) {
                    return const Center(
                      child: Text('Error al cargar los productos'),
                    );
                  } else if (obtenerProductosControllers
                      .listaProductos.isEmpty) {
                    return const Center(
                      child: Text('No hay productos disponibles'),
                    );
                  } else {
                    return ListView.builder(
                      itemCount:
                          obtenerProductosControllers.listaProductos.length,
                      itemBuilder: (context, index) {
                        final producto =
                            obtenerProductosControllers.listaProductos[index];
                        return FilaTablaProductoWidget(
                          index: index,
                          producto: producto,
                          actualizarImagen: actualizarImagen,
                        );
                      },
                    );
                  }
                })),
              ],
            ),
          )),
           //Maneja el estado del controlador para mostrar mensajes sobre si se agrego correctamente el stock o si hubo un error
            Obx(() {
              final estado = aumentarStockProductoController.estado.value;
              if (estado == Estado.exito || estado == Estado.error) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 1),
                      content:
                          Text(aumentarStockProductoController.mensaje.value),
                      backgroundColor:
                          estado == Estado.exito ? Colors.green : Colors.red,
                    ),
                  );
                  // Resetear para evitar múltiples SnackBars
                  aumentarStockProductoController.estado.value = Estado.inicio;
                });
              }
              return const SizedBox.shrink();
            }),
        ],
      ),
    );
  }
}
