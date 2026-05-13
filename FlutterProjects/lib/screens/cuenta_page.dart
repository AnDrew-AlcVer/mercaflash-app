import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

class CuentaPage extends StatefulWidget {
  final bool sesionIniciada;
  final String nombreUsuario;
  final ValueChanged<String> onLogin;
  final VoidCallback onLogout;

  const CuentaPage({
    super.key,
    required this.sesionIniciada,
    required this.nombreUsuario,
    required this.onLogin,
    required this.onLogout,
  });

  @override
  State<CuentaPage> createState() => _CuentaPageState();
}

class _CuentaPageState extends State<CuentaPage> {
  final TextEditingController _nombreController = TextEditingController(text: 'Jordi');
  final TextEditingController _emailController = TextEditingController(text: 'jordi@email.com');
  final TextEditingController _passwordController = TextEditingController(text: '123456');

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sesionIniciada) {
      return Column(
        children: [
          SimpleHeader(title: widget.nombreUsuario),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
              children: [
                const Text(
                  'Entrega en 46026',
                  style: TextStyle(
                    color: AppTheme.green,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 22),
                const AccountRow(icon: Icons.receipt_long_outlined, title: 'Mis pedidos'),
                const AccountRow(icon: Icons.person_outline_rounded, title: 'Datos personales'),
                const AccountRow(icon: Icons.location_on_outlined, title: 'Direcciones'),
                const AccountRow(icon: Icons.credit_card_rounded, title: 'Métodos de pago'),
                const AccountRow(icon: Icons.help_outline_rounded, title: 'Ayuda'),
                const AccountRow(icon: Icons.privacy_tip_outlined, title: 'Privacidad y datos'),
                const SizedBox(height: 12),
                AnimatedTap(
                  onTap: widget.onLogout,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded, color: AppTheme.red),
                        SizedBox(width: 14),
                        Text(
                          'Cerrar sesión',
                          style: TextStyle(
                            color: AppTheme.red,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
      children: [
        const Text(
          'Iniciar sesión',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text(
          'Accede para ver tus pedidos, direcciones y carrito guardado.',
          style: TextStyle(color: AppTheme.gray, height: 1.35),
        ),
        const SizedBox(height: 24),
        LoginField(controller: _nombreController, label: 'Nombre'),
        LoginField(controller: _emailController, label: 'Correo electrónico'),
        LoginField(controller: _passwordController, label: 'Contraseña', obscure: true),
        const SizedBox(height: 12),
        AnimatedTap(
          onTap: () => widget.onLogin(_nombreController.text),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.green,
              borderRadius: BorderRadius.circular(26),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Iniciar sesión',
              style: TextStyle(
                color: AppTheme.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.greenLight,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text(
            'Demo: puedes pulsar iniciar sesión directamente. Luego verás el área de cuenta como en la app real.',
            style: TextStyle(color: AppTheme.green, height: 1.35, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}