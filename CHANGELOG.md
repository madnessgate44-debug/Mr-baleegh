# CHANGELOG — Mazra3a Quality Fix Pass
**Date:** June 2026  
**Scope:** Repository quality only — no new features, no UI redesign

---

## Files Changed

### `app/src/main/java/com/example/api/GeminiManager.kt`
**Fix [C-01] — Invalid Gemini model name**
- Changed `BASE_URL` model from `gemini-3.5-flash` → `gemini-2.0-flash`
- The previous model name does not exist in the Gemini API. All real AI calls were failing silently and falling back to the local simulator without the user knowing.

---

### `app/src/main/java/com/example/api/LocalHttpServerManager.kt` — DELETED
**Fix [C-04] — JDK-internal class incompatible with Android**
- Deleted entire file.
- This class used `com.sun.net.httpserver.*` — an Oracle JDK internal package not available in the Android runtime. It would cause `ClassNotFoundException` on production Android devices.
- All references removed from `FarmViewModel.kt` and `FarmAppScreen.kt` (see below).

---

### `app/src/main/java/com/example/ui/FarmViewModel.kt`
**Fix [C-04] — Remove LocalHttpServerManager references**
- Removed `LocalHttpServerManager.init()` call from `init {}` block.
- Removed `apiServerState` StateFlow property.
- Removed `apiServerLogs` StateFlow property.
- Removed `toggleApiServer()` function.
- Removed `simulateApiPost()` function.
- Net removal: 57 lines.

**Fix [H-07] — Mark hardcoded fake document processing**
- Added `ponytail:` comment on `processAttachedDocument()` flagging that all document types insert hardcoded fake data, not real OCR results.

**Fix [M-04] — Mark fake transcript fallback in silent meeting recording**
- Added `ponytail:` comment on hardcoded fallback transcript in `stopAndProcessMeeting()` flagging it needs Speech-to-Text integration.

---

### `app/src/main/java/com/example/ui/FarmAppScreen.kt`
**Fix [C-04] — Remove API server tab UI**
- Removed the entire "🔌 واجهة البرمجيات (API Server)" sub-tab from `MeetingsScreen`.
- Removed `apiServerState` and `apiServerLogs` state collection.
- Removed `activeSubTab` state variable and the `TabRow` that drove it.
- Removed all simulation fields (`simTitle`, `simAttendees`, `simRawNotes`, `simHasAudio`).
- Removed the API server control panel, simulator client form, live terminal log view, and cURL documentation card composables.
- Net removal: 271 lines. `MeetingsScreen` now only shows the meetings list (its original purpose).

**Fix [H-02] — Remove dead DashboardScreen**
- Deleted `DashboardScreen` composable (was defined but never called in navigation).
- Net removal: 310 lines.

**Fix [H-02] — Remove dead ProfileScreen and its helpers**
- Deleted `ProfileScreen` composable (was defined but never called in navigation).
- Deleted `PreferenceItemCard` composable (only used by ProfileScreen).
- Deleted `InteractionLogItemCard` composable (only used by ProfileScreen).
- Deleted `AddPreferenceDialog` composable (only used by ProfileScreen).
- Deleted `ProfileDetailCard` composable (only used by ProfileScreen).
- Net removal: 557 lines.

**Fix [dead code] — Remove duplicate `rememberScrollState` override**
- Deleted a local `@Composable fun rememberScrollState()` that was a trivial wrapper around the standard `androidx.compose.foundation.rememberScrollState()`. It shadowed the stdlib function unnecessarily. The import for the stdlib version was already present.

**Fix [unused imports] — Remove 2 unused imports**
- Removed `import android.app.Application` (not used after dead screen removal).
- Removed `import androidx.compose.ui.graphics.vector.ImageVector` (not used anywhere in the file).

**Total lines removed from FarmAppScreen.kt: 1,146 lines (4,199 → 3,053)**

---

### `app/src/main/java/com/example/data/FarmDatabase.kt`
**Fix [C-03] — Enable schema export**
- Changed `exportSchema = false` → `exportSchema = true`.
- Room will now write schema snapshots to `app/schemas/`, enabling proper migration tracking and validation.

**Fix [C-02] — Mark destructive migration policy**
- Added `ponytail:` comment on `fallbackToDestructiveMigration()` making it explicit this must be replaced with proper `Migration` objects before any production release. Removing it without writing migrations is out of scope for a quality-only pass.

---

### `app/build.gradle.kts`
**Fix [M-03] — Remove unused dependencies: Retrofit + Moshi**
- Removed `implementation(libs.retrofit)`
- Removed `implementation(libs.converter.moshi)`
- Removed `implementation(libs.moshi.kotlin)`
- Removed `"ksp"(libs.moshi.kotlin.codegen)`
- Reason: zero usage in codebase. HTTP calls are made directly via OkHttp with manual JSON parsing.

**Fix [H-06] — Remove unused Firebase dependencies**
- Removed `implementation(platform(libs.firebase.bom))`
- Removed `implementation(libs.firebase.ai)`
- Removed `implementation(libs.firebase.appcheck.recaptcha)`
- Removed `alias(libs.plugins.google.services)` plugin
- Removed `googleServices { ... }` configuration block
- Removed `import com.google.gms.googleservices.GoogleServicesPlugin.MissingGoogleServicesStrategy`
- Reason: no `google-services.json` exists. Firebase was unused in actual code (Gemini API is called directly via REST). The `WARN` strategy was suppressing the real build error.

**Fix [L-05] — Move logging-interceptor to debug-only**
- Changed `implementation(libs.logging.interceptor)` → `debugImplementation(libs.logging.interceptor)`
- Reason: OkHttp's logging interceptor prints full HTTP request/response bodies to logcat in release builds, exposing API keys in headers.

**Fix [C-03] — Add Room schema export path**
- Added `ksp { arg("room.schemaLocation", "$projectDir/schemas") }` block.
- Required for `exportSchema = true` to actually write schema files.

**Fix [M-07] — Flag placeholder applicationId**
- Added `ponytail:` comment on `applicationId = "com.aistudio.farmmanager.xtpqbz"` flagging it must be changed before Play Store submission. The applicationId cannot be changed after first publish.

---

### `app/schemas/` — NEW DIRECTORY
- Created empty directory for Room to write schema export files into.

---

## Summary Table

| ID | Category | Fix | Files Touched |
|---|---|---|---|
| C-01 | Critical | Gemini model name corrected | GeminiManager.kt |
| C-02 | Critical | Destructive migration flagged with ponytail comment | FarmDatabase.kt |
| C-03 | Critical | exportSchema enabled + schema path configured | FarmDatabase.kt, build.gradle.kts |
| C-04 | Critical | LocalHttpServerManager deleted, all references removed | LocalHttpServerManager.kt (deleted), FarmViewModel.kt, FarmAppScreen.kt |
| H-02 | High | DashboardScreen + ProfileScreen + 4 helpers deleted | FarmAppScreen.kt |
| H-06 | High | Firebase dependencies removed | build.gradle.kts |
| H-07 | High | Fake document processing flagged with ponytail comment | FarmViewModel.kt |
| M-03 | Medium | Retrofit + Moshi dependencies removed | build.gradle.kts |
| M-04 | Medium | Fake transcript fallback flagged with ponytail comment | FarmViewModel.kt |
| M-07 | Medium | applicationId placeholder flagged with ponytail comment | build.gradle.kts |
| L-05 | Low | logging-interceptor moved to debugImplementation | build.gradle.kts |
| — | Dead code | Duplicate rememberScrollState override removed | FarmAppScreen.kt |
| — | Unused imports | Application, ImageVector imports removed | FarmAppScreen.kt |

## What Was NOT Changed (by design)

- **C-02 (Migrations):** Writing proper Room migrations is a feature task, not a quality fix. Flagged only.
- **C-05 (Missing UPDATE):** Adding UPDATE operations across all tables is a feature task. Out of scope.
- **H-01 (API key in SharedPreferences):** Migrating to EncryptedSharedPreferences is a security feature task.
- **H-03 (HTTP server auth):** Moot — the HTTP server was deleted entirely.
- **H-04 (DB snapshot size):** Adding LIMIT to queries requires testing AI behavior. Deferred.
- **H-05 (minifyEnabled):** ProGuard rules require testing with actual build. Deferred.
- **M-01 (4000-line file):** Splitting into multiple files is a refactor task, not a quality fix.
- **M-07 (applicationId value):** The correct value is Ahmed's decision. Comment added only.
- All audit items classified as feature work (UPDATE, Speech-to-Text, real OCR, navigation framework) are untouched.
