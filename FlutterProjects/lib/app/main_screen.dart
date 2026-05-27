import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/producto_model.dart';
import '../screens/carrito_page.dart';
import '../screens/categorias_page.dart';
import '../screens/cuenta_page.dart';
import '../screens/detalle_receta_page.dart';
import '../screens/flash_page.dart';
import '../screens/home_page.dart';
import '../screens/productos_categoria_page.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class MainScreen extends StatefulWidget {
  final bool sesionInicialIniciada;
  final String nombreUsuarioInicial;
  final String emailUsuarioInicial;
  final List<Alergeno> alergenosUsuarioIniciales;
  final int selectedIndexInicial;

  const MainScreen({
    super.key,
    this.sesionInicialIniciada = false,
    this.nombreUsuarioInicial = 'Invitado',
    this.emailUsuarioInicial = '',
    this.alergenosUsuarioIniciales = const [],
    this.selectedIndexInicial = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final SupabaseService _service = SupabaseService();

  int _selectedIndex = 0;
  bool _cargando = true;
  int _scrollRecetasTrigger = 0;

  late bool _sesionIniciada;
  late String _nombreUsuario;
  late String _emailUsuario;
  
  String _codigoPostalGlobal = '00000';

  SpecialPage? _specialPage;
  String? _categoriaSeleccionada;
  Receta? _recetaSeleccionada;

  List<Producto> _productos = [];
  List<Receta> _recetas = [];
  List<CategoriaMercadona> _categorias = [];
  List<Alergeno> _alergenosDisponibles = alergenosComunes;
  List<Alergeno> _alergenosUsuario = const [];

  final Map<String, int> _carrito = {};

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndexInicial;
    _sesionIniciada = widget.sesionInicialIniciada;
    _nombreUsuario = widget.nombreUsuarioInicial;
    _emailUsuario = widget.emailUsuarioInicial;
    _alergenosUsuario = widget.alergenosUsuarioIniciales;
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String cpLocal = prefs.getString('mi_codigo_postal_real') ?? '00000';

      final usuario = await _service.obtenerUsuarioActual();
      final alergenosDisponibles = await _service.obtenerAlergenosDisponibles();
      final productos = await _service.obtenerProductos();
      final recetas = await _service.obtenerRecetasSugeridas();
      final categorias = await _service.obtenerCategorias();

      if (!mounted) return;

      setState(() {
        if (usuario != null) {
          _sesionIniciada = true;
          _nombreUsuario = usuario.nombre;
          _emailUsuario = usuario.email;
          _alergenosUsuario = usuario.alergenos;
          _codigoPostalGlobal = usuario.codigoPostal.isNotEmpty ? usuario.codigoPostal : cpLocal;
        } else {
          _sesionIniciada = false;
          _nombreUsuario = 'Invitado';
          _emailUsuario = '';
          _alergenosUsuario = const [];
          _codigoPostalGlobal = cpLocal;
        }

        _alergenosDisponibles = alergenosDisponibles;
        _productos = productos;
        _recetas = recetas;
        _categorias = categorias;
        _cargando = false;
      });
    } catch (e, stacktrace) {
      if (!mounted) return;
      setState(() => _cargando = false);
    }
  }

  int get _totalUnidadesCarrito => _carrito.values.fold(0, (total, cantidad) => total + cantidad);

  double get _totalCarrito {
    double total = 0;
    for (final entry in _carrito.entries) {
      final producto = _productoPorId(entry.key);
      if (producto != null) total += producto.precio * entry.value;
    }
    return total;
  }

  Producto? _productoPorId(String id) {
    for (final producto in _productos) {
      if (producto.id == id) return producto;
    }
    return null;
  }

  void _cambiarPantalla(int index) {
    setState(() {
      _selectedIndex = index;
      _specialPage = null;
      _categoriaSeleccionada = null;
      _recetaSeleccionada = null;
    });
  }

  void _irAHome() => _cambiarPantalla(0);
  void _irACategorias() => _cambiarPantalla(1);
  void _irAFlash() => _cambiarPantalla(2);
  void _irAFlashYScrollRecetas() { setState(() { _scrollRecetasTrigger++; }); _cambiarPantalla(2); }
  void _irACarrito() => _cambiarPantalla(3);
  void _irACuenta() => _cambiarPantalla(4);

  void _abrirReceta(Receta receta) => setState(() { _specialPage = SpecialPage.recipe; _recetaSeleccionada = receta; });
  void _abrirCategoriaEspecifica(String nombre) => setState(() { _specialPage = SpecialPage.category; _categoriaSeleccionada = nombre; });
  void _volver() => setState(() { _specialPage = null; _categoriaSeleccionada = null; _recetaSeleccionada = null; });

  void _sumarProducto(Producto producto) {
    setState(() => _carrito.update(producto.id, (c) => c + 1, ifAbsent: () => 1));
    _mostrarSnack(producto.tieneAlertaAlergenos ? 'Aviso: ${producto.nombre} contiene ${producto.alertaAlergenosTexto}. Añadido.' : '${producto.nombre} añadido al carrito');
  }

  void _sumarProductos(List<Producto> productos) {
    if (productos.isEmpty) return;
    setState(() { for (final p in productos) _carrito.update(p.id, (c) => c + 1, ifAbsent: () => 1); });
    _mostrarSnack('${productos.length} productos añadidos');
  }

  void _restarProducto(Producto producto) {
    setState(() {
      final cantidadActual = _carrito[producto.id] ?? 0;
      if (cantidadActual <= 1) _carrito.remove(producto.id);
      else _carrito[producto.id] = cantidadActual - 1;
    });
  }

  void _vaciarCarrito() => setState(_carrito.clear);

  Future<String?> _autenticarUsuario({
    required String nombre,
    required String email,
    required String password,
    required bool registrar,
    required List<int> alergenosIds,
  }) async {
    try {
      registrar
          ? await _service.registrarUsuario(nombre: nombre, email: email, password: password, alergenosIds: alergenosIds)
          : await _service.iniciarSesion(email: email, password: password);

      await _cargarDatos(); 
      _mostrarSnack(registrar ? 'Cuenta creada con éxito' : 'Sesión iniciada con éxito');
      return null;
    } catch (e) {
      return _service.mensajeErrorAuth(e);
    }
  }

  Future<String?> _guardarAlergenos(List<int> alergenosIds) async {
    try {
      await _service.guardarAlergenosUsuario(alergenosIds);
      await _cargarDatos();
      _mostrarSnack('Alérgenos guardados');
      return null;
    } catch (e) {
      return _service.mensajeErrorAuth(e);
    }
  }

  Future<void> _cerrarSesion() async {
    try { await _service.cerrarSesion(); } catch (_) {}
    await _cargarDatos();
    _mostrarSnack('Sesión cerrada');
  }

  void _mostrarSnack(String texto, {Color backgroundColor = AppTheme.green}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto), behavior: SnackBarBehavior.floating, backgroundColor: backgroundColor));
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.green)));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: AppTheme.green.withOpacity(0.15),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: AppTheme.green, fontWeight: FontWeight.bold, fontSize: 12);
            }
            return const TextStyle(color: AppTheme.gray, fontWeight: FontWeight.w600, fontSize: 12);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppTheme.green, size: 26);
            }
            return const IconThemeData(color: AppTheme.gray, size: 26);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _cambiarPantalla,
          elevation: 0, 
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded), 
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'Categorías',
            ),
            NavigationDestination(
              icon: Icon(Icons.bolt_outlined), 
              selectedIcon: Icon(Icons.bolt_rounded),
              label: 'MercaFlash',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              selectedIcon: Icon(Icons.shopping_cart_rounded),
              label: 'Lista',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Cuenta',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_specialPage == SpecialPage.recipe && _recetaSeleccionada != null) {
      return DetalleRecetaPage(receta: _recetaSeleccionada!, productos: _productos, carrito: _carrito, onBack: _volver, onAddProducts: _sumarProductos);
    }
    if (_specialPage == SpecialPage.category && _categoriaSeleccionada != null) {
      return ProductosCategoriaPage(
        categoria: _categoriaSeleccionada!, productos: _productos.where((p) => p.categoria == _categoriaSeleccionada).toList(),
        carrito: _carrito, onAdd: _sumarProducto, onRemove: _restarProducto, onBack: _volver,
      );
    }

    return IndexedStack(
      index: _selectedIndex,
      children: [
        HomePage(
          productos: _productos, 
          recetas: _recetas, // <-- AÑADIDO: Pasamos las recetas al HomePage
          carrito: _carrito, 
          totalUnidades: _totalUnidadesCarrito,
          onAdd: _sumarProducto, 
          onRemove: _restarProducto, 
          onOpenFlash: _irAFlash,
          onOpenFlashRecipes: _irAFlashYScrollRecetas, 
          onOpenCart: _irACarrito,
          onOpenCategories: _irACategorias, 
          onOpenCategory: _abrirCategoriaEspecifica,
        ),
        CategoriasPage(categorias: _categorias, productos: _productos, carrito: _carrito, onAdd: _sumarProducto, onRemove: _restarProducto),
        FlashPage(
          productos: _productos, recetas: _recetas, carrito: _carrito,
          onAdd: _sumarProducto, onRemove: _restarProducto, onOpenRecipe: _abrirReceta,
          scrollTrigger: _scrollRecetasTrigger, 
        ),
        CarritoPage(
          productos: _productos, carrito: _carrito, total: _totalCarrito, sesionIniciada: _sesionIniciada,
          onAdd: _sumarProducto, onRemove: _restarProducto, onClear: _vaciarCarrito, onContinueShopping: _irAHome,
          onRequireLogin: () { _mostrarSnack('Inicia sesión para tramitar'); _irACuenta(); },
          onGoToProducts: _irACategorias,
        ),
        CuentaPage(
          sesionIniciada: _sesionIniciada, nombreUsuario: _nombreUsuario, emailUsuario: _emailUsuario,
          codigoPostal: _codigoPostalGlobal, 
          alergenosDisponibles: _alergenosDisponibles, alergenosUsuario: _alergenosUsuario,
          onAuth: _autenticarUsuario, onSaveAlergenos: _guardarAlergenos, onLogout: _cerrarSesion,
        ),
      ],
    );
  }
}

enum SpecialPage { category, recipe }