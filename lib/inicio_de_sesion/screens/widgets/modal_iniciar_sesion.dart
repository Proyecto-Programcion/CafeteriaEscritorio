import 'package:flutter/material.dart';

class ModalIniciarSesion extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController correoController;
  final TextEditingController contrasenaController;
  final VoidCallback inicioDeSesion;

  const ModalIniciarSesion({
    super.key,
    required this.formKey,
    required this.correoController,
    required this.contrasenaController,
    required this.inicioDeSesion,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: Container(
        width: 800,
        height: 500,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 16,
              offset: const Offset(4, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header negro con texto blanco
            Container(
              width: double.infinity,
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Expanded para los campos
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Correo o celular
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Correo o celular',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _CustomTextField(
                        hintText: 'Correo o celular',
                        obscureText: false,
                        controller: correoController,
                      ),
                      const SizedBox(height: 60),
                      // Contraseña
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Contraseña',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _CustomTextField(
                        hintText: 'Contraseña',
                        obscureText: true,
                        controller: contrasenaController,
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 220,
                        child: ElevatedButton(
                          onPressed: inicioDeSesion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 6,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTextField extends StatefulWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;

  const _CustomTextField({
    required this.hintText,
    required this.obscureText,
    required this.controller,
    super.key,
  });

  @override
  State<_CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<_CustomTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscure,
        decoration: InputDecoration(
          hintText: widget.hintText,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: Colors.black, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[700],
                  ),
                  onPressed: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                  },
                  padding: const EdgeInsets.only(right: 16),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
