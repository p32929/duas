# Duas

A collection of duas I try to regularly recite. This is a web application built with Flutter that displays Islamic supplications with their translations and sources.

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

### Changing Theme
Edit `lib/main.dart` and modify the `ThemeData` in the `MaterialApp` widget.

### Changing Fonts
Edit `lib/widgets/dua_item.dart` and modify the `GoogleFonts` widget.

### Updating App Title
Edit `web/index.html` and change the `<title>` tag.

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