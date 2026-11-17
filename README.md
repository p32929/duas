# Duas

A free dua app that keeps the duas you recite in one calm place, finds new ones in trusted dua books, and shows their meaning in your own language. It runs in the browser and on Android, Windows, macOS, Linux and iPhone.

**Open it:** https://p32929.github.io/duas/ · **Download:** [latest release](https://github.com/p32929/duas/releases/latest)

Many of us keep duas scattered across screenshots, notes and old messages, and when we need a dua for something new we don't always know where to look, or whether the source is trusted. Duas keeps your list together, every dua with its source, and your duas stay on your device with no account.

## Features

1. **Your own dua list:** it starts with a ready-made set, and you can add your own with the Arabic, the meaning and the source.
2. **Search trusted books by topic:** type *anxiety*, *travelling* or *before sleeping*, and it searches **Hisn al-Muslim**, **Dua & Dhikr**, **DeenOne** and **Majmu' al-Adhkar** at once. Add the duas you want in one go, each with its source.
3. **The meaning in your language:** translate into over 60 languages. Translations made by AI are clearly marked.
4. **Easy to read and share:** eight Arabic fonts, adjustable text sizes, light, dark or system theme with accent colours, and copy or share any dua.
5. **Use your own list of duas:** point the app at any JSON file from Settings, with no code changes.
6. **Private:** your duas and settings stay on your device. No account.

## Install

1. **In the browser:** open https://p32929.github.io/duas/.
2. **On your device:** download the file for your system from the [latest release](https://github.com/p32929/duas/releases/latest): Android (arm64, armv7 for older phones, x86_64 for Chromebooks), Windows, macOS, Linux or the web build. The iPhone file is unsigned, so it is only for people who can sign and install it themselves.

## Use your own list of duas

1. Make a JSON file like this:
   ```json
   [
     {
       "arabic": "Arabic text of the dua",
       "source": "Source or reference of the dua",
       "meaning": "Translation or meaning of the dua"
     }
   ]
   ```
2. Host it somewhere that allows cross-site requests (CORS). [npoint.io](https://www.npoint.io) works well: create a JSON document and copy its URL.
3. In the app, open **Settings** (the palette icon in the top bar), go to **Data source**, paste the URL and tap **Save**. The app reloads from your list. Tap **Default** to go back to the built-in list.

To change the built-in list for everyone, set `defaultDataUrl` in `lib/utils/apis.dart`.

## Build it yourself

You need [Flutter](https://flutter.dev/docs/get-started/install) (check with `flutter doctor`) and [Node.js](https://nodejs.org/) for deploying.

1. Clone it and install:
   ```bash
   git clone https://github.com/p32929/duas.git
   cd duas
   flutter pub get
   npm install
   ```
2. Run it in Chrome: `flutter run -d chrome`
3. Change the defaults if you like: theme and accent in `lib/theme/app_theme.dart`, fonts in `lib/theme/app_fonts.dart`, the page title in `web/index.html`.
4. Publish to GitHub Pages: set your fork's URL in `package.json`, then run `npm run deploy`. It goes live at `https://<your-username>.github.io/duas/`. For any other host, run `flutter build web` and upload `build/web`.

Releases for every platform are built by GitHub Actions when a version tag like `v2.0.1` is pushed.

## If something goes wrong

1. **Your JSON doesn't load:** the host must allow CORS. Try npoint.io.
2. **The build fails:** run `flutter clean`, then `flutter pub get`.
3. **The deployed page is blank:** check the repository name in `package.json` matches your fork, and the `--base-href` in the `predeploy` script.

## License

MIT License.

## Contributing

Contributions are very welcome, thank you! Before you start on a pull request, please open an issue and tell me what you would like to add or change. That way we can agree on it first, and your time is not wasted on something that might not fit.

<p><a href="https://p32929.github.io/share/?repo=duas"><picture><source media="(prefers-color-scheme: dark)" srcset="https://p32929.github.io/readme/footer-share-dark.svg"><img src="https://p32929.github.io/readme/footer-share-light.svg" width="50%" align="top" alt="Share this project with your friends in one click"></picture></a><a href="https://p32929.github.io/support/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://p32929.github.io/readme/footer-support-dark.svg"><img src="https://p32929.github.io/readme/footer-support-light.svg" width="50%" align="top" alt="If you like my work and want to support me, feel free to support"></picture></a><br><a href="https://openstore.pfay.workers.dev/add"><picture><source media="(prefers-color-scheme: dark)" srcset="https://p32929.github.io/readme/footer-join-dark.svg"><img src="https://p32929.github.io/readme/footer-join-light.svg" width="100%" align="top" alt="Put your own apps on OpenStore: free, your listing lives in your own repo"></picture></a></p>
