import 'package:flutter/material.dart';

class CabezeraTablaProductosWidget extends StatelessWidget {
  const CabezeraTablaProductosWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: Text(
                    'N°',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  )),
              Expanded(
                  flex: 3,
                  child: Text(
                    'Nombre',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  )),
              Expanded(
                  flex: 3,
                  child: Text(
                    'Categoria',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  )),
              Expanded(
                flex: 2,
                child: Text(
                  'Precio Por unidad',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Text(
                    'Descuentos',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  )),
              Expanded(
                  flex: 3,
                  child: Text(
                    'Codigo de barras',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  )),
              Expanded(
                  flex: 2,
                  child: Text(
                    'stock',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  )),
              SizedBox(
                  width: 120,
                  child: Text(
                    'imagen',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  )),
              Expanded(
                  flex: 2,
                  child: Text(
                    'acciones',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
