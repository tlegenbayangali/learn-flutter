# Фаза 6 — Публикация в Google Play и App Store

---

## Задача 6.1 — Иконка и сплэш-экран

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
  flutter_native_splash: ^2.4.0
```

```yaml
# pubspec.yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"  # 1024x1024 PNG
  adaptive_icon_background: "#0D0D1A"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"

flutter_native_splash:
  color: "#0D0D1A"
  image: assets/splash.png
  android: true
  ios: true
```

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

## Задача 6.2 — Версионирование

```yaml
# pubspec.yaml
version: 1.0.0+1
# формат: major.minor.patch+buildNumber
# buildNumber увеличивайте при каждой публикации
```

```bash
# Автоматически при сборке:
flutter build appbundle --build-number=$(date +%Y%m%d%H)
```

---

## Задача 6.3 — Android (Google Play)

### Подпись приложения

```bash
# Создайте keystore (один раз, храните в безопасном месте)
keytool -genkey -v \
  -keystore ~/weather_vibe_keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias weather_vibe

# ВАЖНО: сделайте резервную копию .jks файла
# Потеря keystore = невозможность обновлять приложение
```

```
# android/key.properties (добавьте в .gitignore!)
storePassword=ваш_пароль
keyPassword=ваш_пароль
keyAlias=weather_vibe
storeFile=/Users/you/weather_vibe_keystore.jks
```

```groovy
// android/app/build.gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

### Сборка AAB

```bash
flutter build appbundle --release
# Файл: build/app/outputs/bundle/release/app-release.aab
```

### Google Play Console

1. Создайте аккаунт разработчика ($25 единоразово)
2. Создайте приложение
3. Заполните: описание (RU + EN), скриншоты (2 телефона + 1 планшет), иконку
4. Загрузите AAB в **Internal Testing** сначала
5. Протестируйте на 5-10 пользователях
6. После → Open Testing → Production

---

## Задача 6.4 — iOS (App Store) — если есть Mac

```bash
flutter build ipa --release
```

1. Зарегистрируйтесь в Apple Developer Program ($99/год)
2. Создайте App ID, Provisioning Profile в developer.apple.com
3. В Xcode: выберите Team, настройте Bundle ID
4. Загрузите через Transporter или Xcode → Archive

---

## Задача 6.5 — CI/CD с GitHub Actions

```yaml
# .github/workflows/build_and_deploy.yml
name: Build & Deploy to Play Store

on:
  push:
    tags:
      - 'v*'  # запускать при тегах v1.0.0, v1.1.0 ...

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test

      - name: Decode keystore
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/keystore.jks

      - name: Create key.properties
        run: |
          echo "storePassword=${{ secrets.KEYSTORE_PASSWORD }}" > android/key.properties
          echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
          echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
          echo "storeFile=keystore.jks" >> android/key.properties

      - name: Build AAB
        run: flutter build appbundle --release

      - name: Deploy to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.SERVICE_ACCOUNT_JSON }}
          packageName: com.yourname.weathervibe
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal

# Секреты в GitHub → Settings → Secrets:
# KEYSTORE_BASE64: base64 -i keystore.jks | pbcopy
# KEYSTORE_PASSWORD, KEY_PASSWORD, KEY_ALIAS
# SERVICE_ACCOUNT_JSON: создайте в Google Cloud Console
```

---

## Задача 6.6 — Firebase Crashlytics

```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_crashlytics: ^4.1.3
  firebase_analytics: ^11.3.3
```

```dart
// main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Перехватывайте все необработанные ошибки:
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await dotenv.load(fileName: '.env');
  runApp(const ProviderScope(child: App()));
}
```

---

## Задача 6.7 — Shorebird (OTA обновления)

```bash
# Установите Shorebird CLI
curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/shorebird/main/install.sh -sSf | bash

shorebird init
shorebird release android  # первый релиз

# Патчи без публикации в Play Store:
shorebird patch android
```

**Когда использовать:**
- Исправление критического бага без прохождения ревью
- Обновление конфигов и текстов
- Нельзя менять нативный код

---

## Чеклист Фазы 6

- [ ] Иконка и сплэш-экран настроены
- [ ] Keystore создан и сохранён в безопасном месте
- [ ] Приложение собирается в release AAB
- [ ] .env и key.properties в .gitignore
- [ ] Опубликовано в Internal Testing в Play Store
- [ ] GitHub Actions автоматически деплоит при теге
- [ ] Firebase Crashlytics подключён
- [ ] Первый реальный пользователь установил приложение
