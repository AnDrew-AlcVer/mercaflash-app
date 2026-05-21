import 'package:flutter/material.dart';

import '../models/producto_model.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

typedef WelcomeAuthCallback = Future<String?> Function({
  required String nombre,
  required String email,
  required String password,
  required bool registrar,
  required List<int> alergenosIds,
});

class WelcomePage extends StatefulWidget {
  final VoidCallback onContinueAsGuest;
  final WelcomeAuthCallback onAuth;
  final List<Alergeno> alergenosDisponibles;

  const WelcomePage({
    super.key,
    required this.onContinueAsGuest,
    required this.onAuth,
    required this.alergenosDisponibles,
  });

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController _cpController = TextEditingController();
  final TextEditingController _emailAvisoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _modoInvitado = false;
  bool _mostrarLogin = false;
  bool _registro = false;
  bool _cargando = false;
  bool? _servicioDisponible;
  List<String> _tiendasCercanas = [];
  final Set<int> _alergenosSeleccionados = {};

  final Map<String, List<String>> _tiendasPorCodigoPostal = {
    '03801': [
      'Mercadona Alcoy Centro · 1,2 km',
      'Mercadona Alcoy Zona Norte · 2,8 km',
      'Mercadona Cocentaina · 6,8 km',
    ],
    '03802': [
      'Mercadona Alcoy Santa Rosa · 1,5 km',
      'Mercadona Alcoy Centro · 2,4 km',
      'Mercadona Cocentaina · 7,1 km',
    ],
    '03803': [
      'Mercadona Alcoy Ensanche · 1,3 km',
      'Mercadona Alcoy Centro · 2,6 km',
    ],
    '03820': [
      'Mercadona Cocentaina · 1,1 km',
      'Mercadona Alcoy Centro · 6,8 km',
    ],
  };

  @override
  void dispose() {
    _cpController.dispose();
    _emailAvisoController.dispose();
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _emailValido(String email) {
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    return regex.hasMatch(email.trim());
  }

  void _comprobarCodigoPostal() {
    final cp = _cpController.text.trim();

    setState(() {
      _tiendasCercanas = _tiendasPorCodigoPostal[cp] ?? [];
      _servicioDisponible = _tiendasCercanas.isNotEmpty;
    });
  }

  void _abrirModoInvitado() {
    setState(() {
      _modoInvitado = true;
      _mostrarLogin = false;
      _servicioDisponible = null;
      _tiendasCercanas = [];
    });
  }

  void _abrirLogin() {
    setState(() {
      _mostrarLogin = true;
      _modoInvitado = false;
      _servicioDisponible = null;
      _tiendasCercanas = [];
    });
  }

  Future<void> _autenticar() async {
    final nombre = _nombreController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_registro && nombre.isEmpty) {
      _mostrarMensaje('Introduce tu nombre');
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      _mostrarMensaje('Completa correo y contraseña');
      return;
    }

    if (!_emailValido(email)) {
      _mostrarMensaje('Introduce un correo electrónico válido');
      return;
    }

    if (password.length < 6) {
      _mostrarMensaje('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    setState(() => _cargando = true);
    final error = await widget.onAuth(
      nombre: nombre,
      email: email,
      password: password,
      registrar: _registro,
      alergenosIds: _alergenosSeleccionados.toList(),
    );

    if (!mounted) return;
    setState(() => _cargando = false);

    if (error != null) {
      _mostrarMensaje(error);
    }
  }

  void _toggleAlergeno(Alergeno alergeno, bool selected) {
    setState(() {
      if (selected) {
        _alergenosSeleccionados.add(alergeno.id);
      } else {
        _alergenosSeleccionados.remove(alergeno.id);
      }
    });
  }

  void _mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.red,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 38, 24, 30),
          children: [
            const Icon(
              Icons.shopping_basket_rounded,
              color: AppTheme.green,
              size: 70,
            ),
            const SizedBox(height: 24),
            const Text(
              'Bienvenid@ a Mercadona',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            const Text(
              'Compra online, consulta productos y descubre ofertas cerca de ti.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.gray, height: 1.4, fontSize: 15),
            ),
            const SizedBox(height: 34),
            _PrimaryButton(text: 'Crear cuenta / Iniciar sesión', onTap: _abrirLogin),
            const SizedBox(height: 14),
            _SecondaryButton(text: 'Entrar como invitado', onTap: _abrirModoInvitado),
            if (_mostrarLogin) ...[
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _ModePill(
                      text: 'Iniciar sesión',
                      selected: !_registro,
                      onTap: () => setState(() => _registro = false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ModePill(
                      text: 'Registrarme',
                      selected: _registro,
                      onTap: () => setState(() => _registro = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                _registro ? 'Crea tu cuenta' : 'Inicia sesión',
                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                _registro
                    ? 'Marca tus alérgenos al registrarte para recibir avisos personalizados.'
                    : 'Accede con tu correo y contraseña para ver tu perfil.',
                style: const TextStyle(color: AppTheme.gray, height: 1.35),
              ),
              const SizedBox(height: 16),
              if (_registro)
                TextField(
                  controller: _nombreController,
                  style: const TextStyle(color: AppTheme.black, fontWeight: FontWeight.w600),
                  decoration: _inputDecoration('Nombre'),
                ),
              if (_registro) const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppTheme.black, fontWeight: FontWeight.w600),
                decoration: _inputDecoration('Correo electrónico'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: AppTheme.black, fontWeight: FontWeight.w600),
                decoration: _inputDecoration('Contraseña'),
              ),
              if (_registro) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Alérgenos de tu perfil',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Puedes dejarlo vacío y configurarlo más tarde desde Mi cuenta.',
                        style: TextStyle(color: AppTheme.gray, fontSize: 13, height: 1.3),
                      ),
                      const SizedBox(height: 10),
                      AllergenSelector(
                        alergenos: widget.alergenosDisponibles,
                        selectedIds: _alergenosSeleccionados,
                        onChanged: _toggleAlergeno,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _PrimaryButton(
                text: _cargando
                    ? 'Cargando...'
                    : _registro
                        ? 'Crear cuenta'
                        : 'Entrar',
                onTap: _cargando ? () {} : _autenticar,
              ),
            ],
            if (_modoInvitado) ...[
              const SizedBox(height: 30),
              const Text(
                'Comprueba tu zona',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Introduce tu código postal para consultar si hay entrega disponible.',
                style: TextStyle(color: AppTheme.gray, height: 1.35),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cpController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.black, fontWeight: FontWeight.w600),
                decoration: _inputDecoration('Código postal'),
              ),
              const SizedBox(height: 14),
              _PrimaryButton(text: 'Comprobar disponibilidad', onTap: _comprobarCodigoPostal),
            ],
            if (_servicioDisponible == true) ...[
              const SizedBox(height: 22),
              _ResultCard(
                icon: Icons.check_circle_rounded,
                color: AppTheme.green,
                title: 'Entrega disponible',
                text: 'Hay reparto en tu zona. Puedes entrar como invitado y añadir productos al carrito.',
              ),
              const SizedBox(height: 14),
              _StoresCard(tiendas: _tiendasCercanas),
              const SizedBox(height: 18),
              _PrimaryButton(text: 'Continuar como invitado', onTap: widget.onContinueAsGuest),
            ],
            if (_servicioDisponible == false) ...[
              const SizedBox(height: 22),
              _ResultCard(
                icon: Icons.info_rounded,
                color: Colors.orange,
                title: 'Todavía no repartimos en tu zona',
                text: 'Puedes seguir navegando por la app. También puedes dejarnos tu correo y te avisaremos cuando haya entrega disponible.',
              ),
              const SizedBox(height: 14),
              const _StoresCard(
                tiendas: [
                  'Mercadona Alcoy Centro · 4,2 km',
                  'Mercadona Cocentaina · 6,8 km',
                  'Mercadona Muro de Alcoy · 9,1 km',
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _emailAvisoController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppTheme.black, fontWeight: FontWeight.w600),
                decoration: _inputDecoration('Correo para avisarte'),
              ),
              const SizedBox(height: 18),
              _PrimaryButton(
                text: 'Continuar igualmente',
                onTap: () {
                  final emailAviso = _emailAvisoController.text.trim();
                  if (emailAviso.isNotEmpty && !_emailValido(emailAviso)) {
                    _mostrarMensaje('Introduce un correo electrónico válido');
                    return;
                  }
                  widget.onContinueAsGuest();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppTheme.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _ModePill({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppTheme.green : AppTheme.white,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: selected ? AppTheme.green : AppTheme.border),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? AppTheme.white : AppTheme.black,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _PrimaryButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppTheme.green,
          borderRadius: BorderRadius.circular(27),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SecondaryButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(27),
          border: Border.all(color: AppTheme.border),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(color: AppTheme.black, fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String text;

  const _ResultCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 17),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: const TextStyle(color: AppTheme.gray, height: 1.35, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoresCard extends StatelessWidget {
  final List<String> tiendas;

  const _StoresCard({required this.tiendas});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tiendas cercanas', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 12),
          ...tiendas.map(
            (tienda) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(Icons.storefront_outlined, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(tienda, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
