import 'package:flutter/material.dart';

import 'models/producto_model.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://dpawbhtkvspqukvmewuk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRwYXdiaHRrdnNwcXVrdm1ld3VrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc1MDMzMTAsImV4cCI6MjA5MzA3OTMxMH0.iVeTff57W8OHPo9p8VwDwH9rRtlKeASpaUZu4Fj4yj4',
  );

  runApp(const MercadonaApp());
}

class MercadonaApp extends StatelessWidget {
  const MercadonaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mercadona',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
    );
  }
}

enum SpecialPage { flash, category, recipe }

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
      print('⏳ Iniciando carga desde Supabase...');
      final productos = await _service.obtenerProductos();
      print('✅ Productos cargados: ${productos.length}');
      
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
      print('❌ ERROR FATAL CARGANDO DATOS: $e');
      print(stacktrace);
      // Para que al menos la app quite el círculo de carga aunque falle
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

  void _abrirFlash() {
    setState(() {
      _specialPage = SpecialPage.flash;
      _categoriaSeleccionada = null;
      _recetaSeleccionada = null;
    });
  }

  void _abrirCategoria(String categoria) {
    if (categoria == 'Próximos a caducar') {
      _abrirFlash();
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
      if (_specialPage == SpecialPage.recipe) {
        _specialPage = SpecialPage.flash;
        _recetaSeleccionada = null;
      } else {
        _specialPage = null;
        _categoriaSeleccionada = null;
        _recetaSeleccionada = null;
      }
    });
  }

  void _sumarProducto(Producto producto) {
    setState(() {
      _carrito.update(producto.id, (cantidad) => cantidad + 1, ifAbsent: () => 1);
    });
    _mostrarSnack('${producto.nombre} añadido al carrito');
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
  }

  void _mostrarSnack(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.green,
          duration: const Duration(milliseconds: 1100),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

    Widget body;
    if (_specialPage == SpecialPage.recipe && _recetaSeleccionada != null) {
      body = DetalleRecetaPage(receta: _recetaSeleccionada!, onBack: _volver);
    } else if (_specialPage == SpecialPage.flash) {
      body = FlashPage(
        productos: _productosFlash,
        recetas: _recetas,
        carrito: _carrito,
        onAdd: _sumarProducto,
        onRemove: _restarProducto,
        onBack: _volver,
        onOpenRecipe: _abrirReceta,
      );
    } else if (_specialPage == SpecialPage.category && _categoriaSeleccionada != null) {
      body = ProductosCategoriaPage(
        categoria: _categoriaSeleccionada!,
        productos: _productos
            .where((producto) => producto.categoria == _categoriaSeleccionada)
            .toList(),
        carrito: _carrito,
        onAdd: _sumarProducto,
        onRemove: _restarProducto,
        onBack: _volver,
      );
    } else {
      body = IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(
            productos: _productos,
            carrito: _carrito,
            totalUnidades: _totalUnidadesCarrito,
            onAdd: _sumarProducto,
            onRemove: _restarProducto,
            onOpenFlash: _abrirFlash,
          ),
          CategoriasPage(
            categorias: _categorias,
            onOpenCategory: (categoria) => _abrirCategoria(categoria.nombre),
          ),
          BuscarPage(
            productos: _productos,
            carrito: _carrito,
            onAdd: _sumarProducto,
            onRemove: _restarProducto,
          ),
          CarritoPage(
            productos: _productos,
            carrito: _carrito,
            total: _totalCarrito,
            onAdd: _sumarProducto,
            onRemove: _restarProducto,
            onClear: _vaciarCarrito,
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

    return Scaffold(
      body: SafeArea(child: body),
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
            icon: Icon(Icons.search_rounded),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Buscar',
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
}

class HomePage extends StatelessWidget {
  final List<Producto> productos;
  final Map<String, int> carrito;
  final int totalUnidades;
  final ValueChanged<Producto> onAdd;
  final ValueChanged<Producto> onRemove;
  final VoidCallback onOpenFlash;

  const HomePage({
    super.key,
    required this.productos,
    required this.carrito,
    required this.totalUnidades,
    required this.onAdd,
    required this.onRemove,
    required this.onOpenFlash,
  });

  @override
  Widget build(BuildContext context) {
    final novedades = productos.where((producto) => producto.esNovedad).toList();
    final bajadas = productos.where((producto) => producto.esBajadaPrecio).toList();
    final solares = productos
        .where((producto) => producto.categoria == 'Cuidado facial y corporal')
        .toList();
    final flash = productos.where((producto) => producto.esFlash).toList();

    return Column(
      children: [
        AppTopBar(totalUnidades: totalUnidades),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 22),
            children: [
              DeliveryBanner(),
              PromoHeroCard(onTap: onOpenFlash),
              SectionTitle(title: 'Novedades', subtitle: 'Productos recién añadidos o mejorados'),
              ProductHorizontalList(
                productos: novedades,
                carrito: carrito,
                onAdd: onAdd,
                onRemove: onRemove,
              ),
              SectionTitle(title: 'Bajadas de precio'),
              ProductHorizontalList(
                productos: bajadas,
                carrito: carrito,
                onAdd: onAdd,
                onRemove: onRemove,
              ),
              FlashEntryCard(productos: flash, onTap: onOpenFlash),
              SectionTitle(title: 'El bronceado perfecto'),
              ProductHorizontalList(
                productos: solares,
                carrito: carrito,
                onAdd: onAdd,
                onRemove: onRemove,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CategoriasPage extends StatelessWidget {
  final List<CategoriaMercadona> categorias;
  final ValueChanged<CategoriaMercadona> onOpenCategory;

  const CategoriasPage({
    super.key,
    required this.categorias,
    required this.onOpenCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SimpleHeader(title: 'Categorías'),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            itemCount: categorias.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.border),
            itemBuilder: (context, index) {
              final categoria = categorias[index];
              final esFlash = categoria.id == 'flash';
              return AnimatedTap(
                onTap: () => onOpenCategory(categoria),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  color: AppTheme.white,
                  child: Row(
                    children: [
                      Text(categoria.emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          categoria.nombre,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: esFlash ? FontWeight.w900 : FontWeight.w600,
                            color: esFlash ? AppTheme.green : AppTheme.black,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppTheme.gray),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class BuscarPage extends StatefulWidget {
  final List<Producto> productos;
  final Map<String, int> carrito;
  final ValueChanged<Producto> onAdd;
  final ValueChanged<Producto> onRemove;

  const BuscarPage({
    super.key,
    required this.productos,
    required this.carrito,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<BuscarPage> createState() => _BuscarPageState();
}

class _BuscarPageState extends State<BuscarPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtrados = widget.productos.where((producto) {
      final texto = '${producto.nombre} ${producto.categoria}'.toLowerCase();
      return texto.contains(_query.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  autofocus: false,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Buscar productos',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: const Color(0xFFF1F1F1),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              if (_query.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => _query = ''),
                  child: const Text('Cancelar'),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const Text(
                'Descubrir',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              ...filtrados.map(
                (producto) => CompactProductTile(
                  producto: producto,
                  cantidad: widget.carrito[producto.id] ?? 0,
                  onAdd: () => widget.onAdd(producto),
                  onRemove: () => widget.onRemove(producto),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CarritoPage extends StatelessWidget {
  final List<Producto> productos;
  final Map<String, int> carrito;
  final double total;
  final ValueChanged<Producto> onAdd;
  final ValueChanged<Producto> onRemove;
  final VoidCallback onClear;

  const CarritoPage({
    super.key,
    required this.productos,
    required this.carrito,
    required this.total,
    required this.onAdd,
    required this.onRemove,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final productosCarrito = productos
        .where((producto) => carrito.containsKey(producto.id))
        .toList();

    return Column(
      children: [
        const SimpleHeader(title: 'Lista'),
        Expanded(
          child: productosCarrito.isEmpty
              ? EmptyState(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Tu carrito está vacío',
                  subtitle: 'Añade productos desde Inicio, Categorías, Buscar o Próximos a caducar.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  children: [
                    Row(
                      children: [
                        Text(
                          '${productosCarrito.length} productos',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: onClear,
                          child: const Text('Vaciar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...productosCarrito.map(
                      (producto) => CartItemTile(
                        producto: producto,
                        cantidad: carrito[producto.id] ?? 0,
                        onAdd: () => onAdd(producto),
                        onRemove: () => onRemove(producto),
                      ),
                    ),
                  ],
                ),
        ),
        if (productosCarrito.isNotEmpty)
          CheckoutBar(total: total),
      ],
    );
  }
}

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
                Text(
                  'Entrega en 46026',
                  style: TextStyle(
                    color: AppTheme.green,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 22),
                AccountRow(icon: Icons.receipt_long_outlined, title: 'Mis pedidos'),
                AccountRow(icon: Icons.person_outline_rounded, title: 'Datos personales'),
                AccountRow(icon: Icons.location_on_outlined, title: 'Direcciones'),
                AccountRow(icon: Icons.credit_card_rounded, title: 'Métodos de pago'),
                AccountRow(icon: Icons.help_outline_rounded, title: 'Ayuda'),
                AccountRow(icon: Icons.privacy_tip_outlined, title: 'Privacidad y datos'),
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

class FlashPage extends StatelessWidget {
  final List<Producto> productos;
  final List<Receta> recetas;
  final Map<String, int> carrito;
  final ValueChanged<Producto> onAdd;
  final ValueChanged<Producto> onRemove;
  final VoidCallback onBack;
  final ValueChanged<Receta> onOpenRecipe;

  const FlashPage({
    super.key,
    required this.productos,
    required this.recetas,
    required this.carrito,
    required this.onAdd,
    required this.onRemove,
    required this.onBack,
    required this.onOpenRecipe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SimpleHeader(title: 'Próximos a caducar', onBack: onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.greenLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Text('⚡', style: TextStyle(fontSize: 34)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Aprovecha productos con descuento antes de que caduquen y añádelos al carrito.',
                        style: TextStyle(
                          color: AppTheme.green,
                          fontWeight: FontWeight.w900,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SectionTitle.compact(title: 'Productos destacados'),
              ...productos.map(
                (producto) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ExpiryProductCard(
                    producto: producto,
                    cantidad: carrito[producto.id] ?? 0,
                    onAdd: () => onAdd(producto),
                    onRemove: () => onRemove(producto),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SectionTitle.compact(title: 'Recetas para aprovechar'),
              ...recetas.map(
                (receta) => RecipeCard(
                  receta: receta,
                  onTap: () => onOpenRecipe(receta),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProductosCategoriaPage extends StatelessWidget {
  final String categoria;
  final List<Producto> productos;
  final Map<String, int> carrito;
  final ValueChanged<Producto> onAdd;
  final ValueChanged<Producto> onRemove;
  final VoidCallback onBack;

  const ProductosCategoriaPage({
    super.key,
    required this.categoria,
    required this.productos,
    required this.carrito,
    required this.onAdd,
    required this.onRemove,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SimpleHeader(title: categoria, onBack: onBack),
        Expanded(
          child: productos.isEmpty
              ? const EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'No hay productos todavía',
                  subtitle: 'Esta categoría está preparada para cargarse desde la base de datos.',
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.61,
                  ),
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
                    return ProductGridCard(
                      producto: producto,
                      cantidad: carrito[producto.id] ?? 0,
                      onAdd: () => onAdd(producto),
                      onRemove: () => onRemove(producto),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class DetalleRecetaPage extends StatelessWidget {
  final Receta receta;
  final VoidCallback onBack;

  const DetalleRecetaPage({
    super.key,
    required this.receta,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SimpleHeader(title: 'Receta', onBack: onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            children: [
              Container(
                height: 170,
                decoration: BoxDecoration(
                  color: AppTheme.greenLight,
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Text(receta.emoji, style: const TextStyle(fontSize: 76)),
              ),
              const SizedBox(height: 18),
              Text(
                receta.titulo,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                receta.descripcion,
                style: const TextStyle(color: AppTheme.gray, height: 1.35),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  InfoChip(icon: Icons.schedule_rounded, label: '${receta.tiempoMinutos} min'),
                  InfoChip(icon: Icons.people_outline_rounded, label: '${receta.raciones} raciones'),
                  InfoChip(icon: Icons.local_fire_department_outlined, label: receta.dificultad),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Ingredientes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              ...receta.ingredientes.map((ingrediente) => IngredientRow(ingrediente: ingrediente)),
              const SizedBox(height: 22),
              const Text('Pasos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              ...receta.pasos.asMap().entries.map(
                    (entry) => StepRow(numero: entry.key + 1, texto: entry.value),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class AppTopBar extends StatelessWidget {
  final int totalUnidades;

  const AppTopBar({super.key, required this.totalUnidades});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: AppTheme.white,
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu_rounded, color: AppTheme.black),
          ),
          const Expanded(
            child: Text(
              'mercadona',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.green,
                fontWeight: FontWeight.w900,
                fontSize: 25,
                letterSpacing: -0.8,
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.shopping_cart_outlined, color: AppTheme.black),
              ),
              if (totalUnidades > 0)
                Positioned(
                  right: 5,
                  top: 5,
                  child: CartBubble(count: totalUnidades),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class SimpleHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const SimpleHeader({super.key, required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.green),
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class DeliveryBanner extends StatelessWidget {
  const DeliveryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      child: AnimatedTap(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Row(
            children: [
              Icon(Icons.location_on_outlined, color: AppTheme.green, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Añade tu dirección para conocer la próxima entrega disponible',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppTheme.gray),
            ],
          ),
        ),
      ),
    );
  }
}

class PromoHeroCard extends StatelessWidget {
  final VoidCallback onTap;

  const PromoHeroCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      child: AnimatedTap(
        onTap: onTap,
        child: Container(
          height: 154,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF009639), Color(0xFF0BBF61)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(color: Color(0x22009639), blurRadius: 18, offset: Offset(0, 8)),
            ],
          ),
          child: Stack(
            children: [
              const Positioned(
                right: 12,
                bottom: 8,
                child: Text('🥛🥬🍗', style: TextStyle(fontSize: 52)),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'Nuevo apartado',
                        style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Ahorra antes de que caduque',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const Spacer(),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ver productos próximos a caducar',
                          style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w900),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, color: AppTheme.white, size: 18),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool compact;

  const SectionTitle({super.key, required this.title, this.subtitle}) : compact = false;

  const SectionTitle.compact({super.key, required this.title})
      : subtitle = null,
        compact = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, compact ? 8 : 18, 18, compact ? 12 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, size: 22),
            ],
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(color: AppTheme.gray, fontSize: 13),
            ),
        ],
      ),
    );
  }
}

class ProductHorizontalList extends StatelessWidget {
  final List<Producto> productos;
  final Map<String, int> carrito;
  final ValueChanged<Producto> onAdd;
  final ValueChanged<Producto> onRemove;

  const ProductHorizontalList({
    super.key,
    required this.productos,
    required this.carrito,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 246,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: productos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final producto = productos[index];
          return SizedBox(
            width: 150,
            child: ProductGridCard(
              producto: producto,
              cantidad: carrito[producto.id] ?? 0,
              onAdd: () => onAdd(producto),
              onRemove: () => onRemove(producto),
            ),
          );
        },
      ),
    );
  }
}

class ProductGridCard extends StatelessWidget {
  final Producto producto;
  final int cantidad;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const ProductGridCard({
    super.key,
    required this.producto,
    required this.cantidad,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTap(
      onTap: onAdd,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Text(producto.emoji, style: const TextStyle(fontSize: 54)),
              ),
            ),
            Text(
              producto.nombre,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, height: 1.15),
            ),
            const SizedBox(height: 5),
            Text(
              producto.cantidad,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppTheme.gray),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (producto.precioAnterior != null) ...[
                  Text(
                    producto.precioAnteriorTexto,
                    style: const TextStyle(
                      color: AppTheme.gray,
                      decoration: TextDecoration.lineThrough,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  producto.precioTexto,
                  style: TextStyle(
                    color: producto.precioAnterior != null ? AppTheme.red : AppTheme.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            QuantityButton(cantidad: cantidad, onAdd: onAdd, onRemove: onRemove),
          ],
        ),
      ),
    );
  }
}

class CompactProductTile extends StatelessWidget {
  final Producto producto;
  final int cantidad;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const CompactProductTile({
    super.key,
    required this.producto,
    required this.cantidad,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(producto.emoji, style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, height: 1.15),
                ),
                const SizedBox(height: 3),
                Text(producto.precioTexto, style: const TextStyle(fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 112, child: QuantityButton(cantidad: cantidad, onAdd: onAdd, onRemove: onRemove)),
        ],
      ),
    );
  }
}

class QuantityButton extends StatelessWidget {
  final int cantidad;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const QuantityButton({
    super.key,
    required this.cantidad,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (cantidad == 0) {
      return AnimatedTap(
        onTap: onAdd,
        child: Container(
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.white,
            border: Border.all(color: AppTheme.greenDark),
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Añadir',
            style: TextStyle(color: AppTheme.greenDark, fontWeight: FontWeight.w900, fontSize: 13),
          ),
        ),
      );
    }

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.green,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 34, height: 32),
            icon: const Icon(Icons.remove_rounded, color: AppTheme.white, size: 18),
          ),
          Text(
            cantidad.toString(),
            style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w900),
          ),
          IconButton(
            onPressed: onAdd,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 34, height: 32),
            icon: const Icon(Icons.add_rounded, color: AppTheme.white, size: 18),
          ),
        ],
      ),
    );
  }
}

class FlashEntryCard extends StatelessWidget {
  final List<Producto> productos;
  final VoidCallback onTap;

  const FlashEntryCard({super.key, required this.productos, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 8),
      child: AnimatedTap(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.yellowLight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFFDF99)),
          ),
          child: Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Próximos a caducar',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${productos.length} productos con descuento y recetas sugeridas',
                      style: const TextStyle(color: AppTheme.gray, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.black),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpiryProductCard extends StatelessWidget {
  final Producto producto;
  final int cantidad;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const ExpiryProductCard({
    super.key,
    required this.producto,
    required this.cantidad,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = producto.caducaHoy
        ? AppTheme.red
        : producto.caducaPronto
            ? AppTheme.orange
            : AppTheme.green;

    return AnimatedTap(
      onTap: onAdd,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 14, offset: Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              height: 78,
              width: 82,
              decoration: BoxDecoration(
                color: AppTheme.greenLight,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(producto.emoji, style: const TextStyle(fontSize: 38)),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(producto.nombre, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(producto.cantidad, style: const TextStyle(color: AppTheme.gray, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (producto.precioAnterior != null) ...[
                        Text(
                          producto.precioAnteriorTexto,
                          style: const TextStyle(color: AppTheme.gray, decoration: TextDecoration.lineThrough, fontSize: 12),
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(producto.precioTexto, style: const TextStyle(color: AppTheme.red, fontWeight: FontWeight.w900)),
                      const SizedBox(width: 8),
                      Text(producto.caducidadTexto, style: TextStyle(color: badgeColor, fontWeight: FontWeight.w900, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(width: 104, child: QuantityButton(cantidad: cantidad, onAdd: onAdd, onRemove: onRemove)),
          ],
        ),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Receta receta;
  final VoidCallback onTap;

  const RecipeCard({super.key, required this.receta, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedTap(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 12, offset: Offset(0, 5))],
          ),
          child: Row(
            children: [
              Text(receta.emoji, style: const TextStyle(fontSize: 42)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(receta.titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(receta.etiqueta, style: const TextStyle(color: AppTheme.green, fontWeight: FontWeight.w800, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        InfoChip(icon: Icons.schedule_rounded, label: '${receta.tiempoMinutos} min'),
                        const SizedBox(width: 8),
                        InfoChip(icon: Icons.restaurant_rounded, label: receta.dificultad),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const InfoChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.gray),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppTheme.gray, fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class CartItemTile extends StatelessWidget {
  final Producto producto;
  final int cantidad;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.producto,
    required this.cantidad,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Text(producto.emoji, style: const TextStyle(fontSize: 34)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(producto.nombre, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text('${producto.precioTexto} / ud.', style: const TextStyle(color: AppTheme.gray, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 104, child: QuantityButton(cantidad: cantidad, onAdd: onAdd, onRemove: onRemove)),
        ],
      ),
    );
  }
}

class CheckoutBar extends StatelessWidget {
  final double total;

  const CheckoutBar({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    final totalTexto = '${total.toStringAsFixed(2).replaceAll('.', ',')} €';
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 18, offset: Offset(0, -6))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('Total', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
              const Spacer(),
              Text(totalTexto, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedTap(
            onTap: () {},
            child: Container(
              height: 52,
              decoration: BoxDecoration(color: AppTheme.green, borderRadius: BorderRadius.circular(26)),
              alignment: Alignment.center,
              child: const Text(
                'Tramitar pedido',
                style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AccountRow extends StatelessWidget {
  final IconData icon;
  final String title;

  const AccountRow({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return AnimatedTap(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.border)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.gray, size: 21),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.gray),
          ],
        ),
      ),
    );
  }
}

class LoginField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;

  const LoginField({
    super.key,
    required this.controller,
    required this.label,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppTheme.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.green, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class IngredientRow extends StatelessWidget {
  final IngredienteReceta ingrediente;

  const IngredientRow({super.key, required this.ingrediente});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            ingrediente.disponible ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: ingrediente.disponible ? AppTheme.green : AppTheme.gray,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              ingrediente.cantidad.isEmpty ? ingrediente.nombre : '${ingrediente.nombre} (${ingrediente.cantidad})',
              style: TextStyle(
                fontWeight: ingrediente.disponible ? FontWeight.w900 : FontWeight.w600,
                color: ingrediente.disponible ? AppTheme.green : AppTheme.black,
              ),
            ),
          ),
          if (ingrediente.caducidadTexto != null)
            Text(
              ingrediente.caducidadTexto!,
              style: const TextStyle(color: AppTheme.orange, fontWeight: FontWeight.w900, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

class StepRow extends StatelessWidget {
  final int numero;
  final String texto;

  const StepRow({super.key, required this.numero, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: AppTheme.greenLight,
            child: Text('$numero', style: const TextStyle(color: AppTheme.green, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(texto, style: const TextStyle(height: 1.35))),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 58, color: AppTheme.green),
            const SizedBox(height: 14),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.gray, height: 1.35)),
          ],
        ),
      ),
    );
  }
}

class CartNavIcon extends StatelessWidget {
  final int count;
  final bool selected;

  const CartNavIcon({super.key, required this.count, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(selected ? Icons.list_alt_rounded : Icons.list_alt_outlined),
        if (count > 0)
          Positioned(right: -8, top: -8, child: CartBubble(count: count)),
      ],
    );
  }
}

class CartBubble extends StatelessWidget {
  final int count;

  const CartBubble({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      constraints: const BoxConstraints(minWidth: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(color: AppTheme.red, borderRadius: BorderRadius.circular(9)),
      alignment: Alignment.center,
      child: Text(
        count > 9 ? '9+' : '$count',
        style: const TextStyle(color: AppTheme.white, fontSize: 10, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class AnimatedTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const AnimatedTap({super.key, required this.child, this.onTap});

  @override
  State<AnimatedTap> createState() => _AnimatedTapState();
}

class _AnimatedTapState extends State<AnimatedTap> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.82 : 1,
          duration: const Duration(milliseconds: 110),
          child: widget.child,
        ),
      ),
    );
  }
}
