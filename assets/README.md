# Assets Directory

This directory contains all static assets for the Tourlicity app.

## Directory Structure

```
assets/
├── images/          # App images and graphics
│   ├── app_icon.png     # Main app icon (required)
│   ├── splash_logo.png  # Splash screen logo (required)
│   └── ...
├── icons/           # UI icons and symbols
│   ├── home.png
│   ├── tours.png
│   ├── profile.png
│   └── ...
└── fonts/           # Custom fonts
    ├── Roboto-Regular.ttf
    ├── Roboto-Bold.ttf
    └── ...
```

## Asset Requirements

### Images
- **app_icon.png**: 1024x1024px, PNG format, app store icon
- **splash_logo.png**: 512x512px, PNG format, splash screen logo
- All images should be optimized for mobile devices
- Use appropriate compression to minimize bundle size

### Icons
- **Format**: PNG with transparency
- **Sizes**: Multiple sizes (24px, 32px, 48px) for different screen densities
- **Style**: Consistent with Material Design guidelines
- **Color**: Support both light and dark themes

### Fonts
- **Roboto-Regular.ttf**: Primary font for body text
- **Roboto-Bold.ttf**: Bold variant for headings and emphasis
- **License**: Ensure proper licensing for commercial use
- **Format**: TrueType (.ttf) or OpenType (.otf)

## Asset Optimization

### Image Optimization
- Use PNG for images with transparency
- Use JPEG for photographs without transparency
- Compress images to reduce file size
- Provide multiple densities (@1x, @2x, @3x) when needed

### Icon Optimization
- Use vector icons when possible (SVG)
- Provide raster fallbacks for complex icons
- Ensure icons are legible at small sizes
- Test icons on different backgrounds

### Font Optimization
- Include only necessary font weights and styles
- Use font subsetting to reduce file size
- Test font rendering across different platforms

## Usage in Code

### Images
```dart
Image.asset(AppAssets.appIcon)
Image.asset(AppAssets.splashLogo)
```

### Icons
```dart
Image.asset(AppAssets.homeIcon)
Image.asset(AppAssets.toursIcon)
```

### Fonts
```dart
TextStyle(
  fontFamily: 'Roboto',
  fontWeight: FontWeight.normal,
)
```

## Asset Guidelines

### Naming Convention
- Use lowercase with underscores: `app_icon.png`
- Be descriptive: `tour_placeholder.png`
- Include size in name if multiple sizes: `logo_small.png`

### File Organization
- Group related assets in subdirectories
- Keep directory structure flat when possible
- Use consistent naming across similar assets

### Quality Standards
- High resolution for crisp display on all devices
- Consistent visual style across all assets
- Proper licensing and attribution
- Regular review and updates

## Production Checklist

### Before Release
- [ ] All required assets present
- [ ] Assets optimized for size
- [ ] Multiple densities provided where needed
- [ ] Assets tested on different devices
- [ ] Licensing verified for all assets
- [ ] Asset references updated in code
- [ ] No unused assets in bundle

### Asset Validation
- [ ] App icon displays correctly in all contexts
- [ ] Splash screen logo loads quickly
- [ ] Icons are legible at all sizes
- [ ] Fonts render correctly on all platforms
- [ ] No broken asset references
- [ ] Bundle size within acceptable limits

---

**Note**: This directory should contain the actual asset files before building for production. The current structure shows the expected organization and naming conventions.