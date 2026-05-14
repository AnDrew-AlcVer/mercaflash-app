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

enum SpecialPage { category, recipe }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final SupabaseService _service = SupabaseService();

  int _selectedIndex = 0;
  bool _cargando = true;
  bool _sesionIniciada = false;
  String _nombreUsuario = 'Jordi';

  SpecialPage? _specialPage;
  String? _categoriaSeleccionada;
  Receta? _recetaSeleccionada;

  List<Producto> _productos = [];
  List<Producto> _productosFlash = [];
  List<Receta> _recetas = [];
  List<CategoriaMercadona> _categorias = [];

  final Map<String, int> _carrito = {};

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final productos = await _service.obtenerProductos();
      final productosFlash = await _service.obtenerProductosProximosACaducar();
      final recetas = await _service.obtenerRecetasSugeridas();
      final categorias = await _service.obtenerCategorias();

      if (!mounted) return;

      setState(() {
        _productos = productos;
        _productosFlash = productosFlash;
        _recetas = recetas;
        _categorias = categorias;
        _cargando = false;
      });
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
    });
  }

  void _irAHome() => _cambiarPantalla(0);

  void _irACategorias() => _cambiarPantalla(1);

  void _irAFlash() => _cambiarPantalla(2);

  void _irACarrito() => _cambiarPantalla(3);

  void _abrirCategoria(String categoria) {
    if (categoria == 'Próximos a caducar') {
      _irAFlash();
      return;
    }

    setState(() {
      _specialPage = SpecialPage.category;
      _categoriaSeleccionada = categoria;
      _recetaSeleccionada = null;
    });
  }

  void _abrirReceta(Receta receta) {
    setState(() {
      _specialPage = SpecialPage.recipe;
      _recetaSeleccionada = receta;
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
    _mostrarSnack('${producto.nombre} añadido al carrito');
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

    _mostrarSnack('${productos.length} productos añadidos al carrito');
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

  void _iniciarSesion(String nombre) {
    setState(() {
      _sesionIniciada = true;
      _nombreUsuario = nombre.trim().isEmpty ? 'Jordi' : nombre.trim();
    });
    _mostrarSnack('Sesión iniciada correctamente');
  }

  void _cerrarSesion() {
    setState(() {
      _sesionIniciada = false;
      _nombreUsuario = 'Jordi';
    });
    _mostrarSnack('Sesión cerrada');
  }

  void _mostrarSnack(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.green,
          duration: const Duration(milliseconds: 1200),
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
          onOpenCart: _irACarrito,
          onOpenCategories: _irACategorias,
        ),
        CategoriasPage(
          categorias: _categorias,
          productos: _productos,
          carrito: _carrito,
          onOpenCategory: (categoria) => _abrirCategoria(categoria.nombre),
          onAdd: _sumarProducto,
          onRemove: _restarProducto,
        ),
        FlashPage(
          productos: _productosFlash,
          recetas: _recetas,
          carrito: _carrito,
          onAdd: _sumarProducto,
          onRemove: _restarProducto,
          onOpenRecipe: _abrirReceta,
        ),
        CarritoPage(
          productos: _productos,
          carrito: _carrito,
          total: _totalCarrito,
          onAdd: _sumarProducto,
          onRemove: _restarProducto,
          onClear: _vaciarCarrito,
          onContinueShopping: _irAHome,
        ),
        CuentaPage(
          sesionIniciada: _sesionIniciada,
          nombreUsuario: _nombreUsuario,
          onLogin: _iniciarSesion,
          onLogout: _cerrarSesion,
        ),
      ],
    );
  }
}
