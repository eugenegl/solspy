# Настройка Universal Links для SolSpy

## Что реализовано

✅ **Universal Links сервис** - `UniversalLinkService.swift`
✅ **Обработка входящих ссылок** - в `SolSpyApp.swift`
✅ **Навигация из Universal Links** - в `NavigationCoordinator.swift`
✅ **Обновленные ViewModels** - используют новый сервис для генерации ссылок

## Что нужно настроить

### 1. Xcode проект

1. Откройте проект в Xcode
2. Выберите target "SolSpy"
3. Перейдите в **Signing & Capabilities**
4. Добавьте capability **Associated Domains**
5. Добавьте домен: `applinks:solspy.app`

### 2. URL Schemes (для fallback)

1. В том же разделе **Signing & Capabilities**
2. Добавьте capability **URL Types**
3. Добавьте URL Scheme: `solspy`
4. Identifier: `com.yourcompany.SolSpy.urlscheme`

### 3. Домен и сервер

1. Загрузите файл `apple-app-site-association` (без расширения) на домен `solspy.app`
2. Файл должен быть доступен по адресу: `https://solspy.app/.well-known/apple-app-site-association`
3. Файл должен отдаваться с `Content-Type: application/json`

### 4. Обновите конфигурацию

В файле `apple-app-site-association.json`:
- Замените `TEAM_ID` на ваш реальный Team ID
- Замените `com.yourcompany.SolSpy` на ваш реальный Bundle Identifier

В файле `UniversalLinkService.swift`:
- Замените `appStoreId = "123456789"` на реальный ID вашего приложения в App Store
- Измените `isUniversalLinksEnabled = false` на `true` чтобы показать кнопки

## Как работает

### Сценарий 1: Приложение установлено
1. Пользователь нажимает на ссылку типа `https://solspy.app/wallet/ADDRESS`
2. iOS проверяет `apple-app-site-association` 
3. Если приложение установлено, открывается приложение
4. Вызывается `onOpenURL` в `SolSpyApp.swift`
5. Происходит навигация к нужному экрану

### Сценарий 2: Приложение не установлено
1. Пользователь нажимает на ссылку `https://solspy.app/wallet/ADDRESS`
2. iOS открывает ссылку в Safari
3. На сайте можно показать fallback с кнопкой "Скачать приложение"
4. Кнопка ведет на App Store

### Сценарий 3: Deep Links (fallback)
1. Если Universal Links не работают, используются схемы `solspy://`
2. Приложение может обработать их через тот же `onOpenURL`

## Структура ссылок

- **Кошельки**: `https://solspy.app/wallet/{address}`
- **Токены**: `https://solspy.app/token/{address}`  
- **Транзакции**: `https://solspy.app/tx/{signature}`

## Кнопки в приложении

### Кнопка "Поделиться" 
Генерирует Universal Link и показывает системный sheet для шаринга

### Кнопка "Копировать"
Копирует Universal Link в буфер обмена

## Тестирование

1. **Локальное тестирование**: Используйте симулятор Safari для открытия ссылок
2. **Реальное устройство**: Отправьте ссылку в Сообщения или заметки и нажмите на неё
3. **Без приложения**: Удалите приложение и проверьте, что ссылка открывается в браузере

## Альтернативные варианты доменов

Если домен `solspy.app` недоступен, можно использовать:
- GitHub Pages: `https://username.github.io/solspy`
- Firebase Hosting: `https://project.web.app`
- Netlify: `https://app-name.netlify.app`

Главное - файл `apple-app-site-association` должен быть доступен по HTTPS. 