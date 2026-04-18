---
name: nc:android-kotlin
description: "Native Android development with Kotlin + Jetpack Compose. Use when building Android-only apps, deep platform integration, Play Store submission, or Compose/XML architecture."
license: MIT
argument-hint: "[compose|architecture|jetpack|deploy]"
---

# Android (Kotlin)

## Jetpack Compose vs XML views

Compose (2026 default): declarative, less boilerplate, hot reload.  
XML views: legacy apps, specific fragments.

## Compose basics

```kotlin
@Composable
fun CounterScreen() {
    var count by remember { mutableStateOf(0) }
    Column {
        Text(text = "$count", style = MaterialTheme.typography.headlineLarge)
        Button(onClick = { count++ }) {
            Text("Increment")
        }
    }
}
```

## State management

- `remember { mutableStateOf(...) }` — local state
- `rememberSaveable` — survives config change (rotation)
- ViewModel + StateFlow — shared across navigation

```kotlin
class CounterViewModel : ViewModel() {
    private val _count = MutableStateFlow(0)
    val count: StateFlow<Int> = _count.asStateFlow()

    fun increment() { _count.value++ }
}

@Composable
fun Screen(vm: CounterViewModel = viewModel()) {
    val count by vm.count.collectAsState()
    // ...
}
```

## Navigation

```kotlin
NavHost(navController, startDestination = "home") {
    composable("home") { HomeScreen() }
    composable("details/{id}") { backStack ->
        DetailsScreen(id = backStack.arguments?.getString("id"))
    }
}
```

Or **Navigation 3** (type-safe, 2026):

```kotlin
@Serializable data class HomeRoute
@Serializable data class DetailsRoute(val id: String)

NavHost(navController, startDestination = HomeRoute) {
    composable<HomeRoute> { HomeScreen() }
    composable<DetailsRoute> { backStack ->
        val route: DetailsRoute = backStack.toRoute()
        DetailsScreen(id = route.id)
    }
}
```

## Networking

- **Retrofit** + **OkHttp** — REST standard
- **Ktor Client** — Kotlin-native alternative
- **kotlinx.serialization** — JSON (Moshi/Gson older)

```kotlin
interface ApiService {
    @GET("users/{id}")
    suspend fun getUser(@Path("id") id: Int): User
}

val api = Retrofit.Builder()
    .baseUrl("https://api.example.com/")
    .addConverterFactory(Json.asConverterFactory("application/json".toMediaType()))
    .build()
    .create(ApiService::class.java)
```

## Persistence

| Option | When |
|---|---|
| DataStore (Preferences) | Settings, flags |
| DataStore (Proto) | Typed structured data |
| Room | Relational, complex queries (SQLite wrapper) |
| EncryptedSharedPreferences | Secrets, tokens |

Room example:

```kotlin
@Entity
data class User(@PrimaryKey val id: Int, val email: String)

@Dao
interface UserDao {
    @Query("SELECT * FROM user WHERE id = :id")
    suspend fun getById(id: Int): User?

    @Insert
    suspend fun insert(user: User)
}
```

## Coroutines

- `suspend fun` — async without callbacks
- `viewModelScope` — auto-cancels on ViewModel clear
- `lifecycleScope` — ties to activity/fragment lifecycle
- `Dispatchers.IO` for network/disk; `Dispatchers.Main` for UI

## Hilt (DI)

```kotlin
@HiltAndroidApp
class App : Application()

@AndroidEntryPoint
class MyActivity : ComponentActivity() {
    @Inject lateinit var api: ApiService
}
```

## Play Store submission

1. Android Studio → Build → Generate Signed Bundle/APK
2. Google Play Console → create app → upload bundle
3. Internal testing → closed testing → production
4. Review 1-3 days

## Anti-patterns

- Blocking main thread with network (use coroutines)
- Using `findViewById` in Compose (use `remember` instead)
- No ProGuard/R8 rules (release build crashes)
- Memory leaks from Activity references in singletons
- Ignoring `onConfigurationChanged` (rotation wipes state)

## Integration

- `nc-auth-patterns` — EncryptedSharedPreferences for tokens
- `nc-api-contracts` — OpenAPI → Kotlin client
- `nc-observability` — Firebase Crashlytics, Sentry Android
