Asatiza logo and app icons

ios/app-icon-1024.png            App Store / Xcode icon (square, no transparency; iOS rounds the corners)
android/app-icon-1024.png        Legacy Android launcher icon source
android/adaptive-foreground-1024.png  Adaptive icon foreground (transparent); background colour #0F5E4C
play-store/play-store-icon-512.png    Google Play listing icon (512x512, 32-bit PNG; Play rounds the corners)
logo/                            Logo, white logo (for green/dark backgrounds) and mark, as SVG and PNG

Flutter: add flutter_launcher_icons to dev_dependencies and this to pubspec.yaml, then run
  dart run flutter_launcher_icons

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app-icon-1024.png"
  adaptive_icon_background: "#0F5E4C"
  adaptive_icon_foreground: "assets/icon/adaptive-foreground-1024.png"
  remove_alpha_ios: true

Colours: emerald #0F5E4C, deep emerald #0B4A3C (wordmark), gold #C8962E, white #FFFFFF.
Wordmark typeface: Fraunces SemiBold (converted to outlines, no font needed).
