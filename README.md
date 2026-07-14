# kilometer-check · iTire

App Flutter que resuelve la historia de usuario:

> *“Como encargado de flotilla, quiero ver el kilometraje actualizado a la fecha de un vehículo en particular.”*

La app consulta el kilometraje de la unidad **Buick Skylark Convertible** (ID `734455`) a través de la **API remota de Wialon**, lo presenta con una interfaz alineada a la identidad de iTire e informa si el kilometraje **aumentó** o **se mantuvo constante** entre consultas.

---

## 🚀 Instrucciones rápidas

Requiere **Flutter 3.41.2**.

```bash
flutter pub get
flutter run
```

Si usas [fvm](https://fvm.app) (el repo incluye `.fvmrc` apuntando a `3.41.2`):

```bash
fvm install        # solo la primera vez
fvm flutter pub get
fvm flutter run
```

> **Token de Wialon:** por tratarse de un ejercicio, el token de prueba del PDF
> está como *default* en `lib/core/constants/wialon_constants.dart`. Puede
> sobreescribirse sin tocar código con:
> `flutter run --dart-define=WIALON_TOKEN=<tu_token>`

### Correr los tests

```bash
fvm flutter test
```

---

## 🔌 Integración con Wialon (2 llamadas)

| # | Servicio | Propósito |
|---|----------|-----------|
| 1 | `token/login` | Intercambia el token por una sesión (`eid`) |
| 2 | `core/search_item` con `flags = 0x1 + 0x2000` (8193) | Devuelve la unidad con su contador de kilometraje `cnm` (km) |

- La **sesión se cachea** entre consultas; si Wialon reporta sesión inválida (`{"error": 1}`), el datasource se re-autentica una única vez y reintenta automáticamente.
- Todos los códigos de error de la API se traducen a mensajes amigables (`WialonApiException`), y los fallos de red/parseo tienen sus propias excepciones (`NetworkException`, `ParsingException`).

---

## 🏗️ Arquitectura

Clean Architecture por feature + gestión de estado con **Provider** (`ChangeNotifier`): los widgets leen y reaccionan al estado exclusivamente a través de `MileageProvider`.

```
lib/
├── main.dart                  # Composición de dependencias (DI) con provider
├── app/                       # Raíz de la app + Go Router (splash → home)
├── core/
│   ├── constants/             # Constantes de Wialon
│   ├── errors/                # Jerarquía sellada de AppException
│   ├── theme/                 # Paleta iTire, tema Material 3, curvas de animación
│   ├── utils/                 # Assets centralizados, tipografía, formatters
│   └── widgets/               # AppScaffold, AppText, AppImage, AppTextField,
│                              # AppButton, Gap, Spacing, Entrance (barrel: widgets.dart)
└── features/
    ├── splash/                # Splash animado (CustomPainter)
    └── mileage/
        ├── data/              # WialonRemoteDatasource, MileageModel, repo impl
        ├── domain/            # Entidad, contrato de repositorio, caso de uso
        └── presentation/      # MileageProvider + pantalla y widgets animados
```

**Flujo de dependencias:** `http.Client → WialonRemoteDatasource → MileageRepository → GetCurrentMileage → MileageProvider → UI`. Cada capa solo conoce el contrato de la anterior, lo que permite sustituirlas en pruebas (ver `test/`).

---

## ✨ UX / UI

- Tema oscuro con la paleta de iTire (azul `#005CA8`, amarillo `#ECB806`) y tipografías Red Hat Display / Inter / JetBrains Mono.
- **Splash** con llanta dibujada por fases (`CustomPainter`) y transición fade+scale hacia la pantalla principal (Go Router `CustomTransitionPage`).
- **Odómetro animado**: el valor "rueda" desde la lectura anterior hasta la nueva, con halo azul que pulsa al actualizar.
- **Leyenda de tendencia** (petición EXTRA): informa si el kilometraje aumentó (+Δ km) o se mantuvo constante.
- Indicador de carga en el botón (bloquea doble tap), feedback del estado de la llamada (hora de última actualización) y manejo de errores con mensajes accionables.
- Entradas escalonadas de contenido y micro-animaciones en botones e indicador "En vivo".

---

## ✅ Calidad

- `flutter analyze`: sin issues.
- `flutter test`: 20 pruebas (formatters, modelo, datasource con `MockClient` —incluye re-login por sesión expirada—, provider y widget test del botón).
