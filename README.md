# QuantumBuy

[![Flutter](https://github.com/Shivani-Radhakrishnan/QuantumBuy--Inclusive-shopping-Platform/actions/workflows/flutter.yml/badge.svg?branch=main)](https://github.com/Shivani-Radhakrishnan/QuantumBuy--Inclusive-shopping-Platform/actions/workflows/flutter.yml)

**An accessible shopping app for people with disabilities, built with Flutter.**

QuantumBuy explores what online shopping looks like when accessibility comes first: voice
ordering with spoken confirmation, high-contrast and large-text modes, image descriptions,
simplified product text, and help identifying product colours for people with colour blindness.
It runs on Android, iOS and the web from one Flutter codebase.

<p align="center">
  <img src="docs/demo.gif" width="300" alt="Demo: browsing categories, adding a laptop to the cart, the product page naming its main colours, ordering two headphones by voice command, the cart total, then turning on high contrast, voice control, alt text and simplified text">
</p>

<p align="center">
  <img src="docs/screenshots/1-home.png" width="18%" alt="Home screen with Categories, Cart and Voice Order buttons">
  <img src="docs/screenshots/3-products.png" width="18%" alt="Electronics product list with prices, descriptions and add/remove buttons">
  <img src="docs/screenshots/4-product-detail.png" width="18%" alt="Laptop product page with its main colours labelled on the photo">
  <img src="docs/screenshots/6-voice-order.png" width="18%" alt="Voice order screen confirming 'Added 2 Headphones to your cart'">
  <img src="docs/screenshots/8-high-contrast.png" width="18%" alt="Home screen in high-contrast mode with the voice-control microphone button">
</p>

## Features

- **Voice ordering.** Tap the microphone and say what you want: "order two laptops",
  "add rice cooker", "buy a smart watch", "open groceries", "show my cart". Any product or
  category in the catalogue is recognised, case-insensitively and tolerant of small recognition
  errors and plurals. The app confirms each action out loud. Commands can also be typed, and the
  screen explains what to do if microphone permission is refused.
- **Accessibility settings that apply app-wide** and are saved between launches: dark theme,
  large text, text scaling, high contrast, spoken product details, alt text for images, a voice
  control shortcut and simplified text. See [Accessibility](#accessibility).
- **Visual-impairment survey.** From Settings, pick the description that fits you (low vision,
  colour blindness, complete blindness and more) and the recommended settings are switched on.
- **Colour help.** Each product page names the photo's main colours ("white 48%, grey 12%") and
  marks where they appear, for shoppers with colour blindness. The page's read-aloud button
  speaks the name, price, description and colours.
- **Shopping.** Five categories and 100 products, product pages, a cart with per-item
  quantities and totals, and a checkout with validated delivery address and payment details
  (UPI id, card number with Luhn check, expiry, CVV, or bank). Placing an order shows a
  confirmation and empties the cart.
- **Accounts.** Local sign-up and login, a profile with phone number, delivery address and photo,
  and log out.

## Accessibility

| Setting | What it does | Where |
| --- | --- | --- |
| Dark theme | Dark colour scheme throughout. | `lib/theme/app_theme.dart` |
| Large text | Every text style, including buttons, is 20% larger. | `lib/theme/app_theme.dart` |
| Text scaling | Multiplies the device's own text size by 1.3. | `AppTextScaling` in `lib/theme/app_theme.dart` |
| High contrast | Black-on-white (or yellow-on-black in dark mode) colour scheme with 2dp outlines; the home photo background is replaced by a plain surface. | `lib/theme/app_theme.dart` |
| Accessibility features | Reads the product name, price and description aloud when a product opens, and announces cart changes and placed orders. | `lib/screens/product_detail_screen.dart`, `lib/widgets/quantity_stepper.dart` |
| Alt text for images | Product photos get a detailed screen-reader description (name and description) and the description is shown under the photo. Photos always have at least a "Photo of …" label. | `lib/widgets/product_image.dart` |
| Voice control | A microphone button on the home, category, product list and product screens opens voice ordering. | `lib/widgets/voice_shortcut_button.dart` |
| Simplified text | Product descriptions are cut to their plain first clause ("High-performance laptop."). | `lib/services/text_simplifier.dart` |

Settings are stored with `shared_preferences` (`lib/models/settings_model.dart`).

Beyond the settings: icon-only buttons have spoken labels (for example "Add Laptop to cart",
"Remove one Laptop"), tap targets are at least 48x48dp, headings are marked as headers, and
status messages (login errors, voice results, order confirmation) are announced as live regions.

**Tests that cover it**

- `test/widget/accessibility_guidelines_test.dart` runs Flutter's `androidTapTargetGuideline`,
  `iOSTapTargetGuideline`, `labeledTapTargetGuideline` and `textContrastGuideline` on all twelve
  screens, plus high contrast + dark mode and large + scaled text.
- `test/widget/settings_effects_test.dart` checks each setting changes the app: the theme,
  the text scale, image labels and captions, shortened descriptions, what is spoken, and the
  microphone shortcut.
- `test/settings_model_test.dart` checks the settings are saved and restored, and the survey
  recommendations.
- `test/voice_command_test.dart` and `test/widget/voice_order_test.dart` cover the voice
  command parser and the voice order screen.

## Getting started

Needs [Flutter](https://docs.flutter.dev/get-started/install) 3.24 or later.

```bash
flutter pub get
flutter run            # on a connected phone, an emulator, or: flutter run -d chrome
flutter analyze
flutter test
```

CI runs `flutter analyze`, `flutter test` and a web build on every push and pull request
(`.github/workflows/flutter.yml`).

## Architecture

```
lib/
  main.dart, app.dart          entry point; providers, theme and routes
  routes.dart                  route names
  data/product_catalog.dart    ProductRepository: the single source of product data
  models/                      CartModel, Order, Product, SettingsModel, UserModel (Provider ChangeNotifiers)
  services/
    speaker.dart               text-to-speech (flutter_tts) behind a Speaker interface
    speech_service.dart        speech recognition (speech_to_text) behind a SpeechService interface
    voice_command.dart         pure-Dart voice command parser
    colour_analysis.dart       finds and names an image's main colours
    text_simplifier.dart       simplified product descriptions
  screens/                     one file per screen
  widgets/                     ProductImage, ProductDescription, QuantityStepper, VoiceShortcutButton
  theme/app_theme.dart         theme built from the display settings
  utils/validators.dart        form validation (email, phone, UPI, card, expiry, CVV)
test/                          unit tests; test/widget/ for widget and accessibility tests
tool/render_frames_test.dart   renders the README screenshots from the real app
```

State lives in Provider `ChangeNotifier` models. Speech recognition and text-to-speech are
injected through interfaces, so the widget tests drive voice commands and check what is spoken
without a microphone or speech engine.

## Security

Accounts are local to the device. Passwords are never stored: the app keeps only a salted
PBKDF2-HMAC-SHA256 hash (10,000 iterations), compared in constant time. Data saved by older
versions, which stored the password in plain text, is converted and the plain text deleted on
first launch (`lib/models/user_model.dart`, tested in `test/user_model_test.dart`).

Checkout is a demo: no payment is processed, and payment details are only validated on the
device, never stored or sent anywhere.

## Why

Accessibility research by Fable found that many disabled shoppers regularly give up on purchases
because of accessibility barriers, and many will switch to a more accessible store even when it
isn't the cheapest. QuantumBuy is a prototype of a store designed around those needs from the start.

## License

[MIT](LICENSE)
