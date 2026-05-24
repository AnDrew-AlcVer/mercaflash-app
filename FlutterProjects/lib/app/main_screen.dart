import 'package:flutter/material.dart';

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
import '../widgets/cart_widgets.dart';

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
  bool _avisoAlergenosMostrado = false;
  
  bool _debeHacerScrollARecetas = false;

  late bool _sesionIniciada;
  late String _nombreUsuario;
  late String _emailUsuario;

  SpecialPage? _specialPage;
  String? _categoriaSeleccionada;
  Receta? _recetaSeleccionada;

  List<Producto> _productos = [];
  List<Producto> _productosFlash = [];
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
      final usuario = await _service.obtenerUsuarioActual();
      final alergenosDisponibles = await _service.obtenerAlergenosDisponibles();
      final productos = await _service.obtenerProductos();
      final productosFlash = productos.where((producto) => producto.esFlash).toList();
      final recetas = await _service.obtenerRecetasSugeridas();
      final categorias = await _service.obtenerCategorias();

      if (!mounted) return;

      setState(() {
        if (usuario != null) {
          _sesionIniciada = true;
          _nombreUsuario = usuario.nombre;
          _emailUsuario = usuario.email;
          _alergenosUsuario = usuario.alergenos;
        } else if (!_sesionIniciada) {
          _nombreUsuario = 'Invitado';
          _emailUsuario = '';
          _alergenosUsuario = const [];
        }

        _alergenosDisponibles = alergenosDisponibles;
        _productos = productos;
        _productosFlash = productosFlash;
        _recetas = recetas;
        _categorias = categorias;
        _cargando = false;
      });

      _pedirAlergenosSiHaceFalta();
    } catch (e, stacktrace) {
      debugPrint('Error cargando datos: $e');
      debugPrintStack(stackTrace: stacktrace);
      if (!mounted) return;
      setState(() => _cargando = false);
    }
  }

  int get _totalUnidadesCarrito {
    return _carrito.values.fold(0, (total, cantidad) => total + cantidad);
  }

  double get _totalCarrito {
    double total = 0;
    for (final entry in _carrito.entries) {
      final producto = _productoPorId(entry.key);
      if (producto != null) {
        total += producto.precio * entry.value;
      }
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
      
      // Reseteamos el scroll si no estamos activándolo a propósito
      if (index != 2) {
         _debeHacerScrollARecetas = false;
      }
    });
  }

  void _irAHome() => _cambiarPantalla(0);

  void _irACategorias() => _cambiarPantalla(1);

  void _irAFlash() {
    setState(() {
      _debeHacerScrollARecetas = false; 
    });
    _cambiarPantalla(2);
  }

  void _irAFlashYScrollRecetas() {
    setState(() {
      _debeHacerScrollARecetas = true;
    });
    _cambiarPantalla(2);
  }

  void _irACarrito() => _cambiarPantalla(3);

  void _irACuenta() => _cambiarPantalla(4);

  void _abrirReceta(Receta receta) {
    setState(() {
      _specialPage = SpecialPage.recipe;
      _recetaSeleccionada = receta;
    });
  }
  
  // NUEVA FUNCIÓN: Abrir una categoría específica por su nombre desde cualquier sitio
  void _abrirCategoriaEspecifica(String nombreCategoria) {
    setState(() {
      _specialPage = SpecialPage.category;
      _categoriaSeleccionada = nombreCategoria;
    });
  }

  void _volver() {
    setState(() {
      _specialPage = null;
      _categoriaSeleccionada = null;
      _recetaSeleccionada = null;
    });
  }

  void _sumarProducto(Producto producto) {
    setState(() {
      _carrito.update(
        producto.id,
        (cantidad) => cantidad + 1,
        ifAbsent: () => 1,
      );
    });

    if (producto.tieneAlertaAlergenos) {
      _mostrarSnack(
        'Aviso: ${producto.nombre} contiene ${producto.alertaAlergenosTexto}. Lo hemos añadido igualmente.',
        backgroundColor: AppTheme.orange,
        duracion: const Duration(milliseconds: 2200),
      );
    } else {
      _mostrarSnack('${producto.nombre} añadido al carrito');
    }
  }

  void _sumarProductos(List<Producto> productos) {
    if (productos.isEmpty) {
      _mostrarSnack('Selecciona al menos un producto');
      return;
    }

    setState(() {
      for (final producto in productos) {
        _carrito.update(
          producto.id,
          (cantidad) => cantidad + 1,
          ifAbsent: () => 1,
        );
      }
    });

    final productosConAviso = productos.where((p) => p.tieneAlertaAlergenos).toList();
    if (productosConAviso.isNotEmpty) {
      _mostrarSnack(
        'Añadidos. Revisa avisos de alérgenos en ${productosConAviso.length} producto(s).',
        backgroundColor: AppTheme.orange,
        duracion: const Duration(milliseconds: 2200),
      );
    } else {
      _mostrarSnack('${productos.length} productos añadidos al carrito');
    }
  }

  void _restarProducto(Producto producto) {
    setState(() {
      final cantidadActual = _carrito[producto.id] ?? 0;
      if (cantidadActual <= 1) {
        _carrito.remove(producto.id);
      } else {
        _carrito[producto.id] = cantidadActual - 1;
      }
    });
  }

  void _vaciarCarrito() {
    setState(_carrito.clear);
    _mostrarSnack('Carrito vaciado');
  }

  Future<String?> _autenticarUsuario({
    required String nombre,
    required String email,
    required String password,
    required bool registrar,
    required List<int> alergenosIds,
  }) async {
    try {
      setState(() => _cargando = true);

      final usuario = registrar
          ? await _service.registrarUsuario(
              nombre: nombre,
              email: email,
              password: password,
              alergenosIds: alergenosIds,
            )
          : await _service.iniciarSesion(
              email: email,
              password: password,
            );

      if (!mounted) return null;

      setState(() {
        _sesionIniciada = true;
        _nombreUsuario = usuario.nombre;
        _emailUsuario = usuario.email;
        _alergenosUsuario = usuario.alergenos;
        _selectedIndex = 4;
        _cargando = false;
      });

      await _cargarDatos();

      _mostrarSnack(
        registrar ? 'Cuenta creada correctamente' : 'Sesión iniciada correctamente',
      );
      _pedirAlergenosSiHaceFalta();
      return null;
    } catch (e) {
      if (mounted) setState(() => _cargando = false);
      return _service.mensajeErrorAuth(e);
    }
  }

  Future<String?> _guardarAlergenos(List<int> alergenosIds) async {
    try {
      await _service.guardarAlergenosUsuario(alergenosIds);
      final usuario = await _service.obtenerUsuarioActual();

      if (!mounted) return null;

      setState(() {
        _alergenosUsuario = usuario?.alergenos ?? const [];
        _avisoAlergenosMostrado = _alergenosUsuario.isNotEmpty;
      });

      await _cargarDatos();
      _mostrarSnack('Alérgenos guardados correctamente');
      return null;
    } catch (e) {
      return _service.mensajeErrorAuth(e);
    }
  }

  Future<void> _cerrarSesion() async {
    try {
      await _service.cerrarSesion();
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      _sesionIniciada = false;
      _nombreUsuario = 'Invitado';
      _emailUsuario = '';
      _alergenosUsuario = const [];
      _avisoAlergenosMostrado = false;
      _selectedIndex = 0;
    });

    await _cargarDatos();
    _mostrarSnack('Sesión cerrada');
  }

  void _pedirAlergenosSiHaceFalta() {
    if (!_sesionIniciada || _alergenosUsuario.isNotEmpty || _avisoAlergenosMostrado) return;

    _avisoAlergenosMostrado = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Configura tus alérgenos'),
            content: const Text(
              'Para avisarte en productos y recetas, indica tus alérgenos desde Mi cuenta. No bloquearemos productos: solo te avisaremos antes de comprarlos.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Ahora no'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _irACuenta();
                },
                child: const Text('Configurar'),
              ),
            ],
          );
        },
      );
    });
  }

  void _mostrarSnack(
    String texto, {
    Color backgroundColor = AppTheme.green,
    Duration duracion = const Duration(milliseconds: 1400),
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          behavior: SnackBarBehavior.floating,
          backgroundColor: backgroundColor,
          duration: duracion,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.green),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _cambiarPantalla,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Categorías',
          ),
          const NavigationDestination(
            icon: Icon(Icons.flash_on_outlined),
            selectedIcon: Icon(Icons.flash_on_rounded),
            label: 'Ofertas Flash',
          ),
          NavigationDestination(
            icon: CartNavIcon(count: _totalUnidadesCarrito, selected: false),
            selectedIcon: CartNavIcon(count: _totalUnidadesCarrito, selected: true),
            label: 'Lista',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Cuenta',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_specialPage == SpecialPage.recipe && _recetaSeleccionada != null) {
      return DetalleRecetaPage(
        receta: _recetaSeleccionada!,
        productos: _productos,
        carrito: _carrito,
        onBack: _volver,
        onAddProducts: _sumarProductos,
      );
    }

    if (_specialPage == SpecialPage.category && _categoriaSeleccionada != null) {
      return ProductosCategoriaPage(
        categoria: _categoriaSeleccionada!,
        productos: _productos
            .where((producto) => producto.categoria == _categoriaSeleccionada)
            .toList(),
        carrito: _carrito,
        onAdd: _sumarProducto,
        onRemove: _restarProducto,
        onBack: _volver,
      );
    }

    return IndexedStack(
      index: _selectedIndex,
      children: [
        HomePage(
          productos: _productos,
          carrito: _carrito,
          totalUnidades: _totalUnidadesCarrito,
          onAdd: _sumarProducto,
          onRemove: _restarProducto,
          onOpenFlash: _irAFlash,
          onOpenFlashRecipes: _irAFlashYScrollRecetas, 
          onOpenCart: _irACarrito,
          onOpenCategories: _irACategorias,
          // AQUÍ PASAMOS LA NUEVA FUNCIÓN PARA ABRIR LA CATEGORÍA
          onOpenCategory: _abrirCategoriaEspecifica,
        ),
        CategoriasPage(
          categorias: _categorias,
          productos: _productos,
          carrito: _carrito,
          onAdd: _sumarProducto,
          onRemove: _restarProducto,
        ),
        FlashPage(
          productos: _productos,
          recetas: _recetas,
          carrito: _carrito,
          onAdd: _sumarProducto,
          onRemove: _restarProducto,
          onOpenRecipe: _abrirReceta,
          scrollToRecipes: _debeHacerScrollARecetas,
        ),
        CarritoPage(
          productos: _productos,
          carrito: _carrito,
          total: _totalCarrito,
          sesionIniciada: _sesionIniciada,
          onAdd: _sumarProducto,
          onRemove: _restarProducto,
          onClear: _vaciarCarrito,
          onContinueShopping: _irAHome,
          onRequireLogin: () {
            _mostrarSnack('Para tramitar el pedido necesitas iniciar sesión');
            _irACuenta();
          },
        ),
        CuentaPage(
          sesionIniciada: _sesionIniciada,
          nombreUsuario: _nombreUsuario,
          emailUsuario: _emailUsuario,
          alergenosDisponibles: _alergenosDisponibles,
          alergenosUsuario: _alergenosUsuario,
          onAuth: _autenticarUsuario,
          onSaveAlergenos: _guardarAlergenos,
          onLogout: _cerrarSesion,
        ),
      ],
    );
  }
}

enum SpecialPage { category, recipe }