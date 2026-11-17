# 🛒 MercaFlash — Reducción del Desperdicio Alimentario en Retail (Mercadona)

Propuesta de innovación tecnológica e ingeniería de software desarrollada en **Flutter** y **Supabase (PostgreSQL)** para el ecosistema móvil de **Mercadona**, orientada a combatir el desperdicio alimentario y dar respuesta a la *Ley 1/2025 de prevención de las pérdidas y el desperdicio alimentario*.

![Prototipo Visual de MercaFlash](Guía%20de%20estilos/Imagen_prototipo.jpeg)

**Equipo:** EMG (Efficiency Management Group) — Gestión de Proyectos Informáticos (EPSA - UPV)  
**Product Owner:** Andrés Alcaraz Verdú

---

## 📋 Resumen Ejecutivo y Problemática

En el sector *retail*, los supermercados desechan entre un **2% y un 5%** del total de alimentos disponibles, concentrándose principalmente en productos frescos. Aunque Mercadona dona más de 20.000 toneladas anuales y aplica descuentos del 50% en tienda mediante etiquetas amarillas físicas para productos próximos a caducar, existe una **brecha de visibilidad digital**: el cliente ("el jefe") no puede conocer estas ofertas antes de acudir físicamente al establecimiento.

**MercaFlash** digitaliza este proceso bajo un modelo *win-win*:
1. **Visibilidad Anticipada por Código Postal:** Permite consultar diariamente el stock rebajado por caducidad inminente en el supermercado local del usuario.
2. **Motor de Recetas de Aprovechamiento:** Cruza en tiempo real los artículos en liquidación con un catálogo de recetas sugeridas para incentivar la compra y evitar el desperdicio en el hogar.
3. **Seguridad Alimentaria Personalizada:** Filtra y advierte visualmente sobre alérgenos e intolerancias configurados en el perfil del cliente.

---

## 📊 Estudio de Mercado y Validación (188 Usuarios)

Previo al desarrollo, el equipo realizó una investigación cuantitativa y cualitativa sobre una muestra de **188 consumidores**:
* **Foco del desperdicio:** Los productos frescos y perecederos constituyen la categoría con mayor índice de pérdida en los hogares.
* **Intención de compra:** Alta predisposición a adquirir productos próximos a su fecha de consumo cuando van acompañados de un descuento claro y visibilidad previa.
* **Valor añadido:** Amplia aceptación del motor de recetas integradas y las alertas de ofertas como facilitadores directos de la compra.

---

## 🎨 Mejoras UX/UI respecto a la App Oficial

En lugar de crear una plataforma aislada, se refactorizó la experiencia de la aplicación oficial de Mercadona siguiendo una **Guía de Estilos corporativa propia** (`Guía de estilos/Guías_de_estilo_mercadona.pdf`):
* **De lista pasiva a Carrito de Compra con Gamificación del Ahorro:** Sustitución de la lista de tachado básica por un carrito transaccional (`carrito_page.dart`) con generación de ticket modal y cálculo en tiempo real del *ahorro global* y *ahorro de la selección actual*.
* **Buscador Contextual:** Reubicación de la herramienta de búsqueda dentro del flujo de categorías (`categorias_page.dart`, `buscar_page.dart`) para evitar redirecciones abruptas desde la pantalla de inicio.
* **Alertas Dinámicas de Alérgenos (`AllergenSelector`):** Inyección automática de avisos visuales en las tarjetas de producto (`product_cards.dart`) cuando un artículo contiene algún alérgeno registrado por el usuario (gluten, lácteos, frutos secos, huevo, pescado, etc.).

---

## 🏗️ Arquitectura del Sistema y Modelo de Datos

El proyecto implementa una arquitectura **Cliente-Servidor Serverless (BaaS)** comunicada mediante API REST sobre HTTPS:

### Frontend Móvil (`FlutterProjects/lib/`)
* **`app/`:** Inicialización global y contenedor de navegación (`mercadona_app.dart`, `main_screen.dart`).
* **`screens/`:** 10 vistas modulares (`flash_page.dart`, `detalle_receta_page.dart`, `home_page.dart`, `categorias_page.dart`, `productos_categoria_page.dart`, `buscar_page.dart`, `carrito_page.dart`, `cuenta_page.dart`, `postal_code_page.dart`, `welcome_page.dart`) con preservación de estado de scroll (`PageStorageKey`), barajado dinámico (`dart:math`) y persistencia local (`SharedPreferences`).
* **`services/`:** Cliente de comunicación asíncrona con Supabase (`supabase_service.dart`).
* **`models/`, `theme/` & `widgets/`:** Modelos tipados (`producto_model.dart`), tema corporativo (`app_theme.dart`) y componentes reutilizables (`product_cards.dart`, `cart_widgets.dart`, `ui_components.dart`).

### Backend y Esquema Relacional (`Supabase` / `PostgreSQL`)
El modelo relacional se compone de **5 entidades maestras** y **3 tablas intermedias** para resolver relaciones $N:M$, apoyado en **Supabase Storage** para el servicio estático de imágenes:
* **Tablas Principales:**
  * `usuarios`: UUID, datos personales, contacto y código postal de tienda asignada.
  * `productos`: Nombre, imagen, `precio_original`, `precio_oferta`, `fecha_caducidad`, flag booleano `mostrar_oferta` y clave foránea `categoria_id` ($1:N$).
  * `categorias`: Organización del catálogo con identificadores visuales.
  * `recetas`: Título, dificultad (validada mediante restricción `CHECK`), `tiempo_minutos`, instrucciones de preparación e imagen.
  * `alergias`: Catálogo maestro de alérgenos e iconografía asociada.
* **Tablas Intermedias ($N:M$):**
  * `usuarios_alergias`: Vincula el perfil del cliente con sus intolerancias.
  * `productos_alergias`: Asocia cada artículo del catálogo con los alérgenos que contiene.
  * `recetas_productos`: Conecta cada receta con sus ingredientes requeridos, incluyendo atributos propios de cantidad exacta y alias.

---

## 🔄 Metodología Ágil (Scrum)

El desarrollo se organizó en **6 Sprints iterativos** gestionados en **Jira** (`Guía Scrums/`):
* **Sprint 0:** Ideación y selección del enfoque de ofertas por caducidad + recetas de aprovechamiento.
* **Sprint 1:** Diseño y análisis estadístico del estudio de mercado (188 respuestas en `Encuesta/`).
* **Sprint 2 y 3:** Desarrollo del núcleo en Flutter, modelado relacional en PostgreSQL e integración de autenticación y filtrado por categorías.
* **Sprint 4:** Aplicación rigurosa de la Guía de Estilos de Mercadona, estandarización de la base de datos y preparación de la defensa.
* **Sprint 5:** Control de calidad (QA), *bug fixing* y cierre del producto.

---

## 📂 Estructura del Repositorio

```text
mercaflash-app/
├── FlutterProjects/       # Código fuente multiplataforma en Flutter (Android, iOS, Web, Desktop)
│   ├── lib/               # Arquitectura modular (app, models, screens, services, theme, widgets)
│   ├── assets/            # Fuentes (Roboto/RV), iconos de 24 categorías y 7 alérgenos
│   └── pubspec.yaml       # Dependencias y declaración de recursos
├── Guía de estilos/       # Manual de identidad visual corporativa (PDF), prototipos y recursos UI
├── Recetas/               # Dossier funcional con las 20 recetas de aprovechamiento (PDF)
├── Guía Scrums/           # Entregables de seguimiento de Sprints (Sprint 1 a Sprint Final)
├── Encuesta/              # Dataset CSV y análisis del estudio de mercado (188 encuestados)
└── README.md              # Documentación técnica y memoria del proyecto