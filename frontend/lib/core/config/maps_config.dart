/// Key de Google Maps usada para geocodificar direcciones (convertir
/// texto -> coordenadas) vía la API HTTP de Google.
///
/// IMPORTANTE: esta key es independiente de la que pusiste en
/// `web/index.html` (esa carga el mapa visual). Puedes usar la MISMA
/// key para ambas, pero en Google Cloud Console debes habilitar:
///   - Maps JavaScript API   (para ver el mapa)
///   - Geocoding API         (para buscar direcciones por texto)
///
/// Reemplaza el valor de abajo por tu key real.
class MapsConfig {
  static const String apiKey = 'TU_GOOGLE_MAPS_API_KEY';
}
