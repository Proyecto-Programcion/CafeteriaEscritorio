import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';


class CabezeraAccionesVentana extends StatelessWidget {
  const CabezeraAccionesVentana({
    super.key,
    required this.isMaximized,
  });

  final bool isMaximized;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
              child: GestureDetector(
            onPanStart: (_) => windowManager.startDragging(),
            behavior: HitTestBehavior.translucent,
            child: Container(
              color: Colors.transparent,
            ),
          )),
          InkWell(
            onTap: () {
              windowManager.minimize();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.minimize,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Botón Maximizar/Restaurar
          InkWell(
            onTap: () async {
              if (isMaximized) {
                await windowManager.unmaximize();
              } else {
                await windowManager.maximize();
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isMaximized ? Icons.fullscreen_exit : Icons.fullscreen,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Botón Cerrar
          InkWell(
            onTap: () {
              windowManager.close();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}