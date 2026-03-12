# Modula Web Sample

This is a React-based web application demonstrating the **Modula SDUI SDK** on the web platform. It consumes the core SDK logic from the shared KMM module.

## 🚀 How to Run

### 1. Build the Shared SDK
The web app depends on the shared logic being compiled to JavaScript. Run this from the **root** of the project:

```bash
# From the MODULA root folder
./gradlew :shared:jsBrowserDevelopmentLibraryDistribution
```

This will generate the required JS artifacts in `shared/build/dist/js/developmentLibrary/`.

### 2. Install Dependencies
Run this from the **root** or inside this folder (`apps/web-sample`):

```bash
npm install
```

### 3. Start the Development Server
Run this from within the **root** folder (using the workspace-wide script) or inside `apps/web-sample`:

```bash
# If using the root workspace scripts
npm run start

# OR manually inside this folder
npm run start
```

---

## 🏗️ Structure
- `src/main.tsx`: Entry point of the React app.
- `src/App.tsx`: Demonstration of using the `SDUIRenderer` and getting mock data from the SDK parser.

## 📋 Integration Note
This app uses a symbolic link or workspace reference to the `shared` module. Ensure the build step (Step 1) is performed every time you modify the Kotlin code in the `shared` module.
