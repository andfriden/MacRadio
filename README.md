# MacRadio

**Минималистичный радиоплеер для macOS, работающий прямо из Menu Bar.**

**🇷🇺 Русский** · [🇬🇧 English](#english)

---

## 🇷🇺 Русский

MacRadio — нативный радиоплеер для macOS, созданный для прослушивания интернет-радио без отдельного большого окна.

Основное взаимодействие происходит через компактный Menu Bar Player с быстрым доступом к воспроизведению, громкости, информации о треке и радиостанциям.

### Возможности

* Нативный Menu Bar Player для macOS
* Play / Pause
* Переключение предыдущей / следующей станции
* Управление громкостью и Mute
* Библиотека радиостанций
* Недавно использованные станции
* Добавление пользовательских радиостанций
* Необязательный логотип станции
* Artwork станции и текущего трека
* Поддержка ICY Metadata
* Автоматическое восстановление после сна, пробуждения и временных проблем с потоком
* Минималистичный интерфейс в стиле macOS
* Универсальная сборка для macOS

### ICY Metadata

MacRadio поддерживает ICY Metadata для совместимых радиопотоков.

Когда поток предоставляет корректные метаданные, плеер может отображать:

* исполнителя;
* название трека;
* информацию о потоке.

Доступность и корректность метаданных зависят от радиостанции и её streaming-сервера.

Не все станции предоставляют ICY Metadata. Некоторые потоки передают неполные данные или обновляют их некорректно. В таких случаях MacRadio продолжает воспроизведение, но информация об исполнителе или текущем треке может отсутствовать или отображаться некорректно.

### Пользовательские станции

MacRadio позволяет добавлять собственные радиостанции.

Обязательные поля:

* Название станции
* URL потока

Логотип станции является необязательным.

Это позволяет использовать радиопотоки, которых нет во встроенной библиотеке MacRadio.

### Требования

* macOS
* Xcode 26.5 или новее для разработки
* Swift / SwiftUI
* AVFoundation

### Установка

Скачайте последнюю версию MacRadio и откройте DMG.

Перетащите **MacRadio** в папку Applications.

MacRadio работает как Menu Bar приложение и не отображается как обычное приложение в Dock.

### Сборка из исходного кода

Клонируйте репозиторий:

```bash
git clone https://github.com/andfriden/MacRadio.git
cd MacRadio
```

Откройте проект в Xcode:

```bash
open MacRadio.xcodeproj
```

Выберите схему **MacRadio** и соберите проект.

### Структура проекта

Проект построен на SwiftUI и AVFoundation и разделён на несколько основных компонентов:

* `Models` — радиостанции и состояние плеера
* `Services` — состояние приложения, metadata, artwork и загрузка станций
* `Storage` — сохранение настроек приложения
* `Audio` — воспроизведение радио и восстановление соединения
* `Views` — интерфейс Menu Bar и работа со станциями

Большое окно в стиле Apple Music остаётся изолированным от основного Menu Bar интерфейса и не является частью основного рабочего сценария MacRadio.

### Текущие ограничения

* ICY Metadata доступен не для всех радиопотоков.
* Некоторые станции передают неполные или некорректные метаданные.
* Доступность логотипов и artwork зависит от источника данных.
* Пользовательские станции требуют корректный и совместимый URL потока.
* Поведение некоторых потоков может зависеть от сервера радиостанции и сетевых условий.

### Roadmap

MacRadio активно развивается.

Планируемые улучшения:

* дальнейшее улучшение управления станциями;
* редактирование и удаление пользовательских станций;
* улучшение поиска metadata и artwork;
* интеграция с media keys macOS;
* интеграция с Notification Center и Now Playing;
* дальнейшие улучшения плеера и восстановления воспроизведения.

### Лицензия

Проект находится в активной разработке.

Информация о лицензии будет добавлена перед первым публичным релизом.

---

<a id="english"></a>

## 🇬🇧 English

MacRadio is a native radio player for macOS, designed to let you listen to internet radio without keeping a large player window open.

The main interaction happens through a compact Menu Bar Player with quick access to playback, volume, track information, and stations.

**[🇷🇺 Русский](#macradio)** · **🇬🇧 English**

### Features

* Native macOS Menu Bar Player
* Play / Pause
* Previous / Next station
* Volume and Mute controls
* Station library
* Recent stations
* User-added radio stations
* Optional station artwork
* Station and track artwork
* ICY Metadata support
* Automatic recovery after sleep, wake, and temporary stream interruptions
* Minimal macOS-native interface
* Universal macOS build

### ICY Metadata

MacRadio supports ICY Metadata from compatible radio streams.

When available, the player can display:

* Artist
* Track title
* Stream information

Metadata availability and accuracy depend on the radio station and its streaming server.

Not every station provides ICY Metadata. Some streams provide incomplete information or update metadata incorrectly. In these cases, MacRadio continues playback normally, but artist or track information may be missing or inaccurate.

### User Stations

MacRadio allows you to add your own radio stations.

Required fields:

* Station name
* Stream URL

A station logo is optional.

This makes it possible to use radio streams that are not included in the built-in MacRadio station library.

### Requirements

* macOS
* Xcode 26.5 or later for development
* Swift / SwiftUI
* AVFoundation

### Installation

Download the latest MacRadio release and open the DMG.

Drag **MacRadio** to the Applications folder.

MacRadio runs as a Menu Bar application and does not appear as a regular application in the Dock.

### Building from Source

Clone the repository:

```bash
git clone https://github.com/andfriden/MacRadio.git
cd MacRadio
```

Open the project in Xcode:

```bash
open MacRadio.xcodeproj
```

Select the **MacRadio** scheme and build the project.

### Project Structure

The project is built with SwiftUI and AVFoundation and follows a modular structure:

* `Models` — radio stations and player state
* `Services` — application state, metadata, artwork, and station loading
* `Storage` — persistent application settings
* `Audio` — radio playback and recovery
* `Views` — Menu Bar and station interface

The large Apple Music-style player window remains isolated from the main Menu Bar experience and is not part of the core MacRadio workflow.

### Current Limitations

* ICY Metadata is not available from every radio stream.
* Some stations provide incomplete or inaccurate metadata.
* Station logos and artwork depend on available data sources.
* User stations require a valid and compatible stream URL.
* Some streams may behave differently depending on their server or network conditions.

### Roadmap

MacRadio is actively developed.

Planned improvements include:

* Further improvements to station management
* Editing and deleting user stations
* Enhanced metadata and artwork handling
* macOS media key integration
* Notification Center and Now Playing integration
* Additional player and playback improvements

### License

This project is currently under development.

License information will be added before the first public release.

