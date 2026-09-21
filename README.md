# Duas

A collection of duas I try to regularly recite. This is a web application built with Flutter that displays Islamic supplications with their translations and sources.

**Live:** https://p32929.github.io/duas/

## Features

- Clean, modern interface
- Arabic text with proper font support
- Translations and sources
- Light/dark theme with selectable accent colors
- Adjustable Arabic and translation font sizes
- **Configurable data source** — change the JSON URL from in-app Settings, no code edits required
- Responsive design
- Easy to customize and deploy

## Quick Start

### Prerequisites

1. Install Flutter:
   - Download Flutter SDK from [flutter.dev](https://flutter.dev/docs/get-started/install)
   - Add Flutter to your PATH
   - Run `flutter doctor` to verify installation

2. Install Node.js and npm:
   - Download from [nodejs.org](https://nodejs.org/)
   - Verify installation:
     ```bash
     node --version
     npm --version
     ```

3. Install Git:
   - Download from [git-scm.com](https://git-scm.com/downloads)
   - Verify installation:
     ```bash
     git --version
     ```

### Installation

1. Fork this repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/duas.git
   cd duas
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   npm install
   ```

### Running Locally

```bash
flutter run -d chrome
```

## Adding Your Own Duas

1. Create a JSON file with your duas following this structure:
   ```json
   [
     {
       "arabic": "Arabic text of the dua",
       "source": "Source/reference of the dua",
       "meaning": "Translation/meaning of the dua"
     }
   ]
   ```

2. Host your JSON file using one of these CORS-friendly options:
   - Option 1: npoint.io (recommended)
     1. Go to [npoint.io](https://www.npoint.io)
     2. Create a new JSON document
     3. Copy the provided URL

3. Point the app at your JSON — two ways:

   - **From the app (recommended, no code):** open **Settings** (the palette icon in the top bar), scroll to **Data source**, paste your JSON URL, and tap **Save**. The app clears its cache and reloads from the new URL. Tap **Default** anytime to restore the built-in source. Your choice is saved on the device.

   - **Change the built-in default (optional):** open `lib/utils/apis.dart` and replace `defaultDataUrl` with your JSON URL. This becomes the source used out of the box (and by the **Default** button).

## Customization

Most day-to-day options are available in the app itself — open **Settings** (the palette icon in the top bar):

- **Theme** — Light, Dark, or System
- **Accent color** — pick from the preset swatches
- **Arabic font** — choose from the bundled Arabic fonts
- **Font sizes** — adjust Arabic and translation text sizes independently
- **Data source** — change the JSON URL the duas load from (see [Adding Your Own Duas](#adding-your-own-duas))

These preferences are saved on the device.

### Changing Defaults (code)

- **Default theme / accent** — edit the defaults in `lib/theme/app_theme.dart`.
- **Available fonts** — edit `lib/theme/app_fonts.dart`.
- **Default data source** — edit `defaultDataUrl` in `lib/utils/apis.dart`.
- **App title** — edit the `<title>` tag in `web/index.html`.

## Deployment

### GitHub Pages Deployment

1. Update `package.json`:
   - Change the repository URL to your fork
   - Update the base href in the predeploy script if needed

2. Deploy:
   ```bash
   npm run deploy
   ```

3. Your app will be available at: `https://[your-username].github.io/duas/`

### Custom Domain Deployment

1. Build the app:
   ```bash
   flutter build web
   ```

2. Deploy the contents of the `build/web` directory to your hosting service

## Troubleshooting

### Common Issues

1. **CORS Issues**:
   - Ensure your JSON hosting service allows CORS
   - Use a CORS proxy if needed

2. **Build Issues**:
   - Clear build cache:
     ```bash
     flutter clean
     flutter pub get
     ```

3. **Deployment Issues**:
   - Check GitHub Pages settings
   - Verify repository name matches package.json
   - Check base href configuration

## Support

If you encounter any issues:
1. Check the [Flutter documentation](https://flutter.dev/docs)
2. Open an issue in the repository
3. Check the troubleshooting section above

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are warmly welcomed and greatly appreciated! Whether it's a bug fix, new feature, or improvement, your input helps make this project better for everyone.

Before submitting a pull request, please:

1. Create an issue describing the feature or bug fix you'd like to work on
2. Wait for discussion and approval to ensure alignment with project goals
3. Fork the repository and create your feature branch
4. Submit your pull request with a clear description of changes

This approach helps avoid duplicate efforts and ensures smooth collaboration. Thank you for considering contributing!

## Share

Sharing this repository with your friends is just one click away from here

[![facebook](https://user-images.githubusercontent.com/6418354/179013321-ac1d1452-0689-493f-9066-940cf2302b6e.png)](https://www.facebook.com/sharer/sharer.php?u=https://github.com/p32929/duas/)
[![twitter](https://user-images.githubusercontent.com/6418354/179013351-7d8d6d1c-4ce2-46ab-bef8-4c4765a1b888.png)](https://twitter.com/intent/tweet?url=https://github.com/p32929/duas/)
[![tumblr](https://user-images.githubusercontent.com/6418354/179013343-3111f55a-3b90-40c7-8487-9777348672b0.png)](https://www.tumblr.com/share?v=3&u=https://github.com/p32929/duas/)
[![pocket](https://user-images.githubusercontent.com/6418354/179013334-b095c45f-becf-49f4-9ee1-5a731a9b1f85.png)](https://getpocket.com/save?url=https://github.com/p32929/duas/)
[![pinterest](https://user-images.githubusercontent.com/6418354/179013331-44cd9206-11b1-4b65-becb-5863b61c828f.png)](https://pinterest.com/pin/create/button/?url=https://github.com/p32929/duas/)
[![reddit](https://user-images.githubusercontent.com/6418354/179013338-7416ae3f-73ba-4522-86e1-1374d7082d22.png)](https://www.reddit.com/submit?url=https://github.com/p32929/duas/)
[![linkedin](https://user-images.githubusercontent.com/6418354/179013327-ca7b7102-1da8-4b1c-858f-1a6e5f21bd70.png)](https://www.linkedin.com/shareArticle?mini=true&url=https://github.com/p32929/duas/)
[![whatsapp](https://user-images.githubusercontent.com/6418354/179013353-f477fa0b-3e6f-4138-a357-c9991b23ff88.png)](https://api.whatsapp.com/send?text=https://github.com/p32929/duas/)

<!-- hire-block -->

---

## 💼 Need this customised — or need it yesterday?

I take fixed-price Flutter work on my own projects. No hourly billing, no surprise scope:

| | |
|---|---|
| **Drop-in integration** — I wire this into your codebase and hand you a PR that builds | **$45** · 3 days |
| **Priority bug fix or small feature** — jumps ahead of the free issue queue | **$95** · 72 hours |
| **Custom build** — branded, packaged and deployed, source yours | **$130** · 7 days |
| **A full app from scratch** | **from $350** · quoted first |

All prices and how to buy → **[p32929.github.io/hire](https://p32929.github.io/hire/)**  
Or buy through [Fiverr](https://www.fiverr.com/fayazbinsalam) (escrow, ID-verified, 5.0★) — safest for a first job.

Scoping and quotes are free: [open an issue](https://github.com/p32929/hire/issues/new) and describe the job.

### Commercial use of this repo

This repo has **no license file**, which in copyright law means *all rights reserved*.
Personal use, learning and open-source forks: go ahead, just link back. Shipping it inside a
commercial or closed-source product needs a license — **$50** for one product, **$150**
company-wide and perpetual ([details](https://p32929.github.io/hire/)).
Rather not pay? [Ask in an issue](https://github.com/p32929/hire/issues/new) — I may just MIT it.
