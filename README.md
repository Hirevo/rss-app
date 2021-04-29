<div align=center><h1>RSS App</h1></div>
<div align=center><strong>Subscribe to and read from RSS feeds, everywhere</strong></div>

About
-----

**API is deployed live at: <https://rss.polomack.eu>**  
**Frontend is deployed live at: <https://app.rss.polomack.eu>**

This is the development repository for **`RSS App`**, an application to subscribe and follow RSS feeds.

The app is composed of:

- An API server, written in [**Rust**](https://rust-lang.org), implementing all of the business logic for managing RSS feeds
- 3 clients:
  - An iOS application, written using [**SwiftUI**](https://developer.apple.com/xcode/swiftui/)
  - A macOS application, also using [**SwiftUI**](https://developer.apple.com/xcode/swiftui/)
  - A Web frontend, written using [**Svelte**](https://svelte.dev)

Both the API server and the Web frontend are continuously deployed from this repository using [**Heroku**](https://heroku.com).

You can find more information about each components in their respective folders:

- **`api/`**: the API server
- **`iOS/`**: the iOS application
- **`macOS/`**: the macOS application
- **`web/`**: the Web frontend
