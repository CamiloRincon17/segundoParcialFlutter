# segundoParcialFlutter

Aplicación Flutter para el segundo parcial académico.

## Características

- **Autenticación con Token Seguro**: Generación y almacenamiento de JWT utilizando exclusivamente `FlutterSecureStorage` bajo la clave `token`.
- **Persistencia de Sesión**:
  - Al recargar la página (F5) con el token guardado en el navegador, se mantiene la sesión en la pantalla de inicio.
  - Al eliminar manualmente el token en DevTools y recargar, redirige automáticamente a la pantalla de Login.
- **Catálogo de Productos**: Consumo de API (DummyJSON) con scroll infinito y paginación de 10 en 10.
- **Efectos de Carga**: Placeholders tipo esqueleto (`Skeletonizer`) mientras se descargan los datos.
- **Navegación Modular**: Arquitectura limpia con cada pantalla en su propio archivo (`HomeScreen`, `CreateProductScreen`, `ProfileScreen`, `AboutScreen`, `LoginScreen`).
- **Tema Oscuro y Claro**: Alternador reactivo de tema con Riverpod.
