# MacRadio

<p align="center">
  <a href="#русский">🇷🇺 Русский</a>
  &nbsp;&nbsp;|&nbsp;&nbsp;
  <a href="#english">🇬🇧 English</a>
</p>

---

<a id="русский"></a>

# 🇷🇺 Русский

MacRadio — минималистичный нативный радиоплеер для macOS с основным управлением через Menu Bar.

## Возможности

* Воспроизведение интернет-радиостанций через `AVPlayer`.
* Управление воспроизведением из Menu Bar.
* Play / Pause, Previous / Next.
* Громкость и Mute.
* Недавние станции.
* Избранные станции.
* Пользовательские станции с локальным хранением.
* Отображение ICY metadata, когда станция действительно передаёт информацию о текущем треке.
* Artwork для текущего трека, когда изображение найдено.
* Автоматическая пауза при блокировке экрана и переходе системы в sleep.
* Восстановление воспроизведения после wake.
* Состояния плеера: `connecting`, `buffering`, `reconnecting`, `playing`, `paused`, `failed`, `stopped`.
* Автоматическое переподключение при проблемах с потоком.
* `MPNowPlayingInfoCenter`.
* Media keys.
* Notification Center.
* Системные команды Play / Pause / Previous / Next.

## ICY Metadata

MacRadio использует ICY metadata для получения информации о текущем треке.

Важно: наличие заголовка `icy-metaint` ещё не означает, что станция передаёт название текущей композиции.

Некоторые станции объявляют поддержку ICY metadata, но передают пустой `StreamTitle` или оставляют metadata-блоки пустыми.

В таком случае:

* поток продолжает нормально воспроизводиться;
* ICY reader работает штатно;
* исполнитель и название композиции не отображаются, потому что источник не передаёт эти данные.

Например, поток `rusradio128.mp3` сообщает `icy-metaint`, но возвращает пустой `StreamTitle`. Это ограничение конкретного радиопотока, а не ошибка MacRadio.

## Пользовательские станции

Пользовательские станции хранятся локально в:

`~/Library/Application Support/MacRadio/stations.json`

Файл можно открыть из Settings → Stations → Open Stations File.

## Восстановление плеера

Если поток временно перестал отвечать, MacRadio отслеживает buffering/stall и выполняет автоматическое переподключение.

После достижения лимита попыток состояние плеера переходит в `failed`, после чего можно выполнить повторную попытку вручную.

При блокировке экрана или переходе системы в sleep воспроизведение приостанавливается. После wake MacRadio создаёт новый `AVPlayer` и восстанавливает поток текущей станции.

## Архитектура

Проект построен на SwiftUI и AVFoundation.

Основные части:

* `RadioPlayer` — воспроизведение и состояние плеера.
* `ICYMetadataReader` — чтение ICY metadata из потока.
* `MetadataService` — разбор track metadata и поиск artwork.
* `StationManager` — выбор станций, recent и favorites.
* `StationLoader` — загрузка bundled и user stations.
* `AppSettings` — сохранение настроек через `UserDefaults`.
* `AppState` — центральная композиция зависимостей приложения.
* `AppDelegate` — Menu Bar item, popover и системные события.

## Разработка

Проект предназначен для нативной разработки под macOS с использованием Xcode, SwiftUI и AVFoundation.

Перед изменением существующего поведения желательно сначала проверить соответствующий lifecycle и состояние плеера. Для networking и ICY metadata важно учитывать особенности конкретных радиопотоков.

---

<a id="english"></a>

# 🇬🇧 English

MacRadio is a minimal native macOS radio player focused on a Menu Bar workflow.

## Features

* Internet radio playback using `AVPlayer`.
* Menu Bar based playback control.
* Play / Pause, Previous / Next.
* Volume and Mute controls.
* Recent stations.
* Favorite stations.
* User stations with local storage.
* ICY metadata display when the station actually provides current track information.
* Artwork for the current track when artwork can be found.
* Automatic pause on screen lock and system sleep.
* Playback recovery after wake.
* Player states: `connecting`, `buffering`, `reconnecting`, `playing`, `paused`, `failed`, and `stopped`.
* Automatic reconnect when the stream fails.
* `MPNowPlayingInfoCenter`.
* Media keys.
* Notification Center.
* System Play / Pause / Previous / Next commands.

## ICY Metadata

MacRadio uses ICY metadata to obtain current track information.

Important: the presence of the `icy-metaint` header does not guarantee that a station provides the current track title.

Some stations advertise ICY metadata support but send an empty `StreamTitle` or otherwise provide empty metadata blocks.

In that case:

* the audio stream can continue playing normally;
* the ICY reader is working correctly;
* artist and track information are not displayed because the stream does not provide them.

For example, the `rusradio128.mp3` stream provides `icy-metaint` but returns an empty `StreamTitle`. This is a limitation of the radio stream, not a MacRadio error.

## User Stations

User stations are stored locally in:

`~/Library/Application Support/MacRadio/stations.json`

The file can be opened from Settings → Stations → Open Stations File.

## Player Recovery

When a stream becomes unavailable, MacRadio detects buffering/stalls and performs automatic reconnect attempts.

After the retry limit is reached, the player enters the `failed` state and can be retried manually.

When the screen is locked or the system goes to sleep, playback is paused. After wake, MacRadio creates a new `AVPlayer` and restores the current station stream.

## Architecture

The project is built with SwiftUI and AVFoundation.

Main components:

* `RadioPlayer` — playback and player state.
* `ICYMetadataReader` — reads ICY metadata from the stream.
* `MetadataService` — parses track metadata and searches for artwork.
* `StationManager` — station selection, recent stations, and favorites.
* `StationLoader` — loads bundled and user stations.
* `AppSettings` — persists settings using `UserDefaults`.
* `AppState` — central application dependency composition.
* `AppDelegate` — Menu Bar item, popover, and system events.

## Development

The project targets native macOS development using Xcode, SwiftUI, and AVFoundation.

Before changing existing behavior, verify the relevant player lifecycle and state transitions. For networking and ICY metadata, keep stream-specific behavior in mind.
