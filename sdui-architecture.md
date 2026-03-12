# SDUI SDK Implementation Architecture

Berikut adalah arsitektur diagram (*Plant*) dari implementasi Server-Driven UI (SDUI) SDK yang Anda deskripsikan, menggunakan Kotlin Multiplatform (KMM) sebagai fondasinya.

```mermaid
graph TD
    %% Base Layer / Core Logic
    sublayer_kmm[Shared KMM Ktor/Kotlin]
    
    %% Output from KMM
    sublayer_kmm -- Compile to JVM --> android_kmm[KMM Android .aar / .jar]
    sublayer_kmm -- Compile to Native --> ios_kmm[KMM iOS Shared.xcframework]
    sublayer_kmm -- Compile to JS/Wasm --> web_kmm[KMM JS / Wasm]

    %% Native Renderers
    android_kmm --> android_compose[Android Compose UI Renderer]
    ios_kmm --> ios_swiftui[iOS SwiftUI UI Renderer]
    
    %% Native Artifacts for further distribution
    android_compose -- Build & Bundle --> artifact_aar[Android Compose .aar]
    ios_swiftui -- Archive & Extract --> artifact_xcframework[iOS SwiftUI SDUI.xcframework]

    %% Web Native
    web_kmm -.-> react_web[React Web UI]

    %% React Native TurboModule Integration
    artifact_aar --> rn_android[React Native Android TurboModule]
    artifact_xcframework --> rn_ios[React Native iOS TurboModule]

    %% Final Applications (located in /apps)
    rn_android --> rn_app((React Native App<br><i>/apps/rn-sample</i>))
    rn_ios --> rn_app
    react_web --> web_app((Web App<br><i>/apps/web-sample</i>))
```

## Komponen Utama
1. **Shared KMM (Core Parser & Networking):** Menyediakan lapisan logika bersama. Komponen ini mengambil data JSON dari server dan menerapkannya ke dalam model objek (*data classes*) yang dapat dibaca di semua platform pengenal SDUI.
2. **Android Compose (`android-compose`):** Menggunakan Jetpack Compose (Native Android) untuk me-render objek KMM menjadi View nyata (Button, Text, dll). Dibungkus atau digabung sebagai *standalone artifact* berekstensi `.aar`.
3. **iOS SwiftUI (`ios-swiftui`):** Mengadopsi SwiftUI (Native iOS) untuk me-render elemen sesuai dari KMM `Shared.xcframework` ke komponen Apple UI. Digabung ke format *binary package* `.xcframework`.
4. **React Web:** Memanfaatkan *compilation* KMM ke Javascript / WebAssembly untuk bisa me-render DOM Web, disambung langsung dengan komponen UI dari ReactJS.
5. **React Native TurboModule (`react-native-sdui`):** 
    - Tanpa "*Remapping*", implementasi *Bridge*-nya (Fabric Module) hanya perlu meneruskan props `json` (string utuh) dari ranah Javascript/Typescript ke lapis Native.
    - Sisi Android-nya memanggil *dependency* `.aar` Compose dan memetakan langsung render Compose ke root Native RN.
    - Sisi iOS-nya memanggil *dependency* `.xcframework` SwiftUI / *Shared Swift source* dan menampilkannya memakai `UIHostingController`.
6. **Sample / Demo Apps (`/apps`):** Direktori utama tempat aplikasi integrasi siap pakai berada (contoh: proyek end-user React Native atau React Web konvensional). Aplikasi ini merupakan titik masuk di mana SDK SDUI di-inisialisasi.
