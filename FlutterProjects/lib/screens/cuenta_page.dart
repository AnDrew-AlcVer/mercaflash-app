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
  final String codigoPostal;
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
    required this.codigoPostal,
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
  bool _alergenosExpandidos = false;
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
    if (idsAnteriores.length != idsNuevos.length || !idsAnteriores.containsAll(idsNuevos)) {
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

  String _capitalizar(String texto) {
    if (texto.trim().isEmpty) return '';
    final limpio = texto.trim();
    return limpio[0].toUpperCase() + limpio.substring(1).toLowerCase();
  }

  bool _emailValido(String email) {
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    return regex.hasMatch(email.trim());
  }

  Future<void> _enviarFormulario() async {
    final nombre = _nombreController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_registro && nombre.isEmpty) { _mostrarMensaje('Introduce tu nombre'); return; }
    if (email.isEmpty || password.isEmpty) { _mostrarMensaje('Completa correo y contraseña'); return; }
    if (!_emailValido(email)) { _mostrarMensaje('Introduce un correo electrónico válido'); return; }
    if (password.length < 6) { _mostrarMensaje('La contraseña debe tener al menos 6 caracteres'); return; }

    setState(() => _cargando = true);

    final error = await widget.onAuth(
      nombre: nombre, email: email, password: password, registrar: _registro, alergenosIds: _alergenosSeleccionados.toList(),
    );

    if (!mounted) return;
    setState(() => _cargando = false);

    if (error != null) {
      final msj = error.toLowerCase();
      if (!_registro) {
        if (msj.contains('user not found') || msj.contains('no existe')) _mostrarMensaje('No tienes cuenta, prueba a crear una ahora.');
        else if (msj.contains('incorrectos') || msj.contains('invalid login credentials')) _mostrarMensaje('La contraseña y el usuario no son correctos.');
        else _mostrarMensaje(error);
      } else {
        _mostrarMensaje(error);
      }
      return;
    }
    _passwordController.clear();
  }

  Future<void> _guardarAlergenos() async {
    if (!widget.sesionIniciada) { _mostrarMensaje('Inicia sesión para guardar tus alérgenos'); return; }
    setState(() => _cargando = true);
    final error = await widget.onSaveAlergenos(_alergenosSeleccionados.toList());
    if (!mounted) return;
    setState(() => _cargando = false);
    if (error != null) _mostrarMensaje(error);
    else setState(() => _alergenosExpandidos = false);
  }

  void _toggleAlergeno(Alergeno alergeno, bool selected) {
    setState(() {
      if (selected) _alergenosSeleccionados.add(alergeno.id);
      else _alergenosSeleccionados.remove(alergeno.id);
    });
  }

  void _mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(texto, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating, backgroundColor: AppTheme.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16), duration: const Duration(seconds: 3),
      ));
  }

  Widget _buildPildoraCodigoPostal() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.greenLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.green.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_shipping_outlined, color: AppTheme.green, size: 22),
          const SizedBox(width: 8),
          Text(
            'Entrega en ${widget.codigoPostal}',
            style: const TextStyle(fontSize: 15, color: AppTheme.green, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SimpleHeader(title: 'Cuenta'),
        Expanded(child: widget.sesionIniciada ? _buildCuentaIniciada() : _buildLoginRegistro()),
      ],
    );
  }

  Widget _buildCuentaIniciada() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      children: [
        Text(
          'Hola, ${_capitalizar(widget.nombreUsuario)}',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.black, letterSpacing: -0.5),
        ),
        const SizedBox(height: 16),
        
        Row(children: [_buildPildoraCodigoPostal()]),
        
        const SizedBox(height: 32),
        _buildAlergenosExpandible(),

        const AccountRow(icon: Icons.receipt_long_outlined, title: 'Mis pedidos'),
        const AccountRow(icon: Icons.person_outline_rounded, title: 'Datos personales'),
        const AccountRow(icon: Icons.location_on_outlined, title: 'Direcciones'),
        const AccountRow(icon: Icons.credit_card_rounded, title: 'Métodos de pago'),
        const AccountRow(icon: Icons.help_outline_rounded, title: 'Ayuda'),
        const AccountRow(icon: Icons.privacy_tip_outlined, title: 'Privacidad y datos'),
        
        const SizedBox(height: 24),
        
        AnimatedTap(
          onTap: widget.onLogout,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(color: AppTheme.red.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: AppTheme.red),
                SizedBox(width: 10),
                Text('Cerrar sesión', style: TextStyle(color: AppTheme.red, fontWeight: FontWeight.w800, fontSize: 16)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlergenosExpandible() {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _alergenosExpandidos = !_alergenosExpandidos),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                const Icon(Icons.health_and_safety_outlined, color: AppTheme.black),
                const SizedBox(width: 14),
                const Expanded(child: Text('Mis alérgenos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.black))),
                Icon(_alergenosExpandidos ? Icons.keyboard_arrow_up_rounded : Icons.chevron_right_rounded, color: AppTheme.gray),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _alergenosExpandidos
              ? Padding(
                  padding: const EdgeInsets.only(left: 38, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _alergenosSeleccionados.isEmpty
                            ? 'No tienes alérgenos guardados. Marca los que necesites para recibir avisos.'
                            : 'Tienes ${_alergenosSeleccionados.length} alérgeno(s) guardados.',
                        style: const TextStyle(color: AppTheme.gray, height: 1.35),
                      ),
                      const SizedBox(height: 16),
                      AllergenSelector(alergenos: widget.alergenosDisponibles, selectedIds: _alergenosSeleccionados, onChanged: _toggleAlergeno),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity, height: 44,
                        child: OutlinedButton.icon(
                          onPressed: _cargando ? null : _guardarAlergenos,
                          icon: const Icon(Icons.save_outlined),
                          label: Text(_cargando ? 'Guardando...' : 'Guardar alérgenos'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.green, side: const BorderSide(color: AppTheme.green),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _buildLoginRegistro() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _registro ? 'Crear cuenta' : 'Iniciar sesión',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        Row(children: [_buildPildoraCodigoPostal()]),
        
        const SizedBox(height: 20),
        Text(
          _registro
              ? 'Regístrate y marca tus alérgenos para recibir avisos personalizados.'
              : 'Accede para ver tus pedidos, direcciones, carrito guardado y avisos de alérgenos.',
          style: const TextStyle(color: AppTheme.gray, height: 1.35),
        ),
        const SizedBox(height: 24),
        
        if (_registro) LoginField(controller: _nombreController, label: 'Nombre'),
        LoginField(controller: _emailController, label: 'Correo electrónico', keyboardType: TextInputType.emailAddress),
        LoginField(controller: _passwordController, label: 'Contraseña', obscure: true),
        if (_registro) ...[
          const SizedBox(height: 6),
          _AllergenRegisterBox(alergenosDisponibles: widget.alergenosDisponibles, selectedIds: _alergenosSeleccionados, onToggle: _toggleAlergeno),
        ],
        const SizedBox(height: 12),
        
        AnimatedTap(
          onTap: _cargando ? null : _enviarFormulario,
          child: Container(
            height: 52,
            decoration: BoxDecoration(color: _cargando ? AppTheme.gray : AppTheme.green, borderRadius: BorderRadius.circular(26)),
            alignment: Alignment.center,
            child: Text(
              _cargando ? 'Procesando...' : _registro ? 'Crear cuenta' : 'Iniciar sesión',
              style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _cargando ? null : () => setState(() { _registro = !_registro; _passwordController.clear(); }),
          child: Text(
            _registro ? 'Ya tengo cuenta, iniciar sesión' : 'Crea una cuenta',
            style: const TextStyle(color: AppTheme.green, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.greenLight, borderRadius: BorderRadius.circular(18)),
          child: const Text(
            'Importante: En el modo invitado, la aplicación no oculta productos con alérgenos, verás un aviso y aún así podrás añadirlo al carrito.',
            style: TextStyle(color: AppTheme.green, height: 1.35, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _AllergenRegisterBox extends StatelessWidget {
  final List<Alergeno> alergenosDisponibles;
  final Set<int> selectedIds;
  final void Function(Alergeno alergeno, bool selected) onToggle;

  const _AllergenRegisterBox({
    required this.alergenosDisponibles, required this.selectedIds, required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Alérgenos de tu perfil', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          const Text('Marca los que quieras guardar al crear la cuenta.', style: TextStyle(color: AppTheme.gray, fontSize: 13, height: 1.3)),
          const SizedBox(height: 10),
          AllergenSelector(alergenos: alergenosDisponibles, selectedIds: selectedIds, onChanged: onToggle),
        ],
      ),
    );
  }
}

class AllergenSelector extends StatelessWidget {
  final List<Alergeno> alergenos;
  final Set<int> selectedIds;
  final Function(Alergeno, bool) onChanged;

  const AllergenSelector({
    super.key, required this.alergenos, required this.selectedIds, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0, runSpacing: 10.0,
      children: alergenos.map((alergeno) {
        final isSelected = selectedIds.contains(alergeno.id);
        Widget iconoAlergeno;
        
        if (alergeno.imagen == null || alergeno.imagen!.trim().isEmpty) {
          iconoAlergeno = const Icon(Icons.warning_amber_rounded, size: 18, color: Colors.orange);
        } else if (alergeno.imagen!.startsWith('http')) {
          iconoAlergeno = Image.network(alergeno.imagen!, width: 20, height: 20, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 18, color: Colors.red));
        } else if (alergeno.imagen!.startsWith('assets/')) {
          iconoAlergeno = Image.asset(alergeno.imagen!, width: 20, height: 20, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 18, color: Colors.red));
        } else {
          iconoAlergeno = Text(alergeno.imagen!, style: const TextStyle(fontSize: 16));
        }

        return InkWell(
          onTap: () => onChanged(alergeno, !isSelected),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.red.withOpacity(0.08) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? AppTheme.red.withOpacity(0.6) : Colors.grey.shade300, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                iconoAlergeno, const SizedBox(width: 8), 
                Text(alergeno.nombre, style: TextStyle(color: isSelected ? AppTheme.red : AppTheme.black, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}