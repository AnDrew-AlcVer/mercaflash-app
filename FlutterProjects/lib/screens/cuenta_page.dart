import 'package:flutter/material.dart';

import '../models/producto_model.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

typedef AuthSubmitCallback = Future<String?> Function({
  required String nombre,
  required String email,
  required String password,
  required bool registrar,
  required List<int> alergenosIds,
});

typedef SaveAllergensCallback = Future<String?> Function(List<int> alergenosIds);

class CuentaPage extends StatefulWidget {
  final bool sesionIniciada;
  final String nombreUsuario;
  final String emailUsuario;
  final List<Alergeno> alergenosDisponibles;
  final List<Alergeno> alergenosUsuario;
  final AuthSubmitCallback onAuth;
  final SaveAllergensCallback onSaveAlergenos;
  final VoidCallback onLogout;

  const CuentaPage({
    super.key,
    required this.sesionIniciada,
    required this.nombreUsuario,
    required this.emailUsuario,
    required this.alergenosDisponibles,
    required this.alergenosUsuario,
    required this.onAuth,
    required this.onSaveAlergenos,
    required this.onLogout,
  });

  @override
  State<CuentaPage> createState() => _CuentaPageState();
}

class _CuentaPageState extends State<CuentaPage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _registro = false;
  bool _cargando = false;
  late Set<int> _alergenosSeleccionados;

  @override
  void initState() {
    super.initState();
    _alergenosSeleccionados = widget.alergenosUsuario.map((a) => a.id).toSet();
  }

  @override
  void didUpdateWidget(covariant CuentaPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final idsAnteriores = oldWidget.alergenosUsuario.map((a) => a.id).toSet();
    final idsNuevos = widget.alergenosUsuario.map((a) => a.id).toSet();
    if (idsAnteriores.length != idsNuevos.length ||
        !idsAnteriores.containsAll(idsNuevos)) {
      _alergenosSeleccionados = idsNuevos;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _emailValido(String email) {
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    return regex.hasMatch(email.trim());
  }

  Future<void> _enviarFormulario() async {
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
      return;
    }

    _passwordController.clear();
  }

  Future<void> _guardarAlergenos() async {
    if (!widget.sesionIniciada) {
      _mostrarMensaje('Inicia sesión para guardar tus alérgenos');
      return;
    }

    setState(() => _cargando = true);
    final error = await widget.onSaveAlergenos(_alergenosSeleccionados.toList());

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
    if (widget.sesionIniciada) {
      return _buildCuentaIniciada();
    }

    return _buildLoginRegistro();
  }

  Widget _buildCuentaIniciada() {
    return Column(
      children: [
        SimpleHeader(title: 'Hola, ${widget.nombreUsuario}'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.greenLight,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.verified_user_outlined, color: AppTheme.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.emailUsuario.isEmpty
                            ? 'Sesión iniciada correctamente.'
                            : 'Sesión iniciada con ${widget.emailUsuario}.',
                        style: const TextStyle(
                          color: AppTheme.green,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _AllergenAccountCard(
                alergenosDisponibles: widget.alergenosDisponibles,
                selectedIds: _alergenosSeleccionados,
                cargando: _cargando,
                onToggle: _toggleAlergeno,
                onSave: _guardarAlergenos,
              ),
              const SizedBox(height: 20),
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

  Widget _buildLoginRegistro() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
      children: [
        Text(
          _registro ? 'Crear cuenta' : 'Iniciar sesión',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          _registro
              ? 'Regístrate y marca tus alérgenos para recibir avisos personalizados.'
              : 'Accede para ver tus pedidos, direcciones, carrito guardado y avisos de alérgenos.',
          style: const TextStyle(color: AppTheme.gray, height: 1.35),
        ),
        const SizedBox(height: 24),
        if (_registro) LoginField(controller: _nombreController, label: 'Nombre'),
        LoginField(
          controller: _emailController,
          label: 'Correo electrónico',
          keyboardType: TextInputType.emailAddress,
        ),
        LoginField(
          controller: _passwordController,
          label: 'Contraseña',
          obscure: true,
        ),
        if (_registro) ...[
          const SizedBox(height: 6),
          _AllergenRegisterBox(
            alergenosDisponibles: widget.alergenosDisponibles,
            selectedIds: _alergenosSeleccionados,
            onToggle: _toggleAlergeno,
          ),
        ],
        const SizedBox(height: 12),
        AnimatedTap(
          onTap: _cargando ? null : _enviarFormulario,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: _cargando ? AppTheme.gray : AppTheme.green,
              borderRadius: BorderRadius.circular(26),
            ),
            alignment: Alignment.center,
            child: Text(
              _cargando
                  ? 'Cargando...'
                  : _registro
                      ? 'Crear cuenta'
                      : 'Iniciar sesión',
              style: const TextStyle(
                color: AppTheme.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _cargando
              ? null
              : () => setState(() {
                    _registro = !_registro;
                    _passwordController.clear();
                  }),
          child: Text(
            _registro
                ? 'Ya tengo cuenta, iniciar sesión'
                : 'No tengo cuenta, registrarme',
            style: const TextStyle(
              color: AppTheme.green,
              fontWeight: FontWeight.w900,
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
            'Importante: la app no bloquea productos. Si un producto o receta coincide con tus alérgenos, verás un aviso claro y aun así podrás añadirlo al carrito.',
            style: TextStyle(
              color: AppTheme.green,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _AllergenAccountCard extends StatelessWidget {
  final List<Alergeno> alergenosDisponibles;
  final Set<int> selectedIds;
  final bool cargando;
  final void Function(Alergeno alergeno, bool selected) onToggle;
  final VoidCallback onSave;

  const _AllergenAccountCard({
    required this.alergenosDisponibles,
    required this.selectedIds,
    required this.cargando,
    required this.onToggle,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x10000000), blurRadius: 12, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mis alérgenos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            selectedIds.isEmpty
                ? 'No tienes alérgenos guardados. Marca los que necesites para recibir avisos en productos y recetas.'
                : 'Tienes ${selectedIds.length} alérgeno(s) guardados. Puedes cambiarlos cuando quieras.',
            style: const TextStyle(color: AppTheme.gray, height: 1.35),
          ),
          const SizedBox(height: 12),
          AllergenSelector(
            alergenos: alergenosDisponibles,
            selectedIds: selectedIds,
            onChanged: onToggle,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: cargando ? null : onSave,
              icon: const Icon(Icons.save_outlined),
              label: Text(cargando ? 'Guardando...' : 'Guardar alérgenos'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllergenRegisterBox extends StatelessWidget {
  final List<Alergeno> alergenosDisponibles;
  final Set<int> selectedIds;
  final void Function(Alergeno alergeno, bool selected) onToggle;

  const _AllergenRegisterBox({
    required this.alergenosDisponibles,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Marca los que quieras guardar al crear la cuenta.',
            style: TextStyle(color: AppTheme.gray, fontSize: 13, height: 1.3),
          ),
          const SizedBox(height: 10),
          AllergenSelector(
            alergenos: alergenosDisponibles,
            selectedIds: selectedIds,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}
