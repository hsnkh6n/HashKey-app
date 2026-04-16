 # HashKey Apps

HashKey Apps is a small Apple-platform project that generates HMAC-SHA256 hashes from plain text and a secret key.

It includes:

- an iPhone app in `HashKeyApp.xcodeproj`
- a macOS app for Apple Silicon / MacBook in `HashKeyMac.xcodeproj`

Both apps use the same core logic and offer two result modes:

- `Full Hash`: the full HMAC-SHA256 value in lowercase hexadecimal
- `Password Hash`: the first 16 hexadecimal characters of the full hash, formatted as `XXXX-XXXX-XXXX-XXXX`

This design makes it easy to verify the full result with online tools while still offering a shorter readable version.

## Features

- HMAC-SHA256 hashing using Apple `CryptoKit`
- Plain text input + secret key input
- Full website-compatible hash output
- Short grouped password-style hash output
- Copy to clipboard
- Light and dark mode friendly UI
- Settings screen with a simple algorithm structure explanation
- Direct verification link to Devglan:
  [HMAC SHA256 Online Tool](https://www.devglan.com/online-tools/hmac-sha256-online)
- Shared visual identity with the custom `H` app logo

## How It Works

The apps use this flow:

1. Read the plain text input
2. Read the secret key input
3. Convert both to UTF-8 bytes
4. Generate an `HMAC-SHA256` digest
5. Convert the digest to a hexadecimal string
6. Show either:
   - the full 64-character hex hash
   - or the first 16 hex characters grouped into 4-character blocks

Example:

- Full Hash: `b92dd95f745a6b9febd91d35e17beba253a977f28425f7cc87fc0efb4871d3fc`
- Password Hash: `b92d-d95f-745a-6b9f`

## Project Structure

```text
.
├── HashKeyApp.xcodeproj
├── HashKeyApp
│   ├── ContentView.swift
│   ├── HashKeyAppApp.swift
│   ├── HashPasswordGenerator.swift
│   └── Assets.xcassets
├── HashKeyMac.xcodeproj
├── HashKeyMac
│   ├── HashKeyMacApp.swift
│   ├── MacContentView.swift
│   ├── HashPasswordGenerator.swift
│   └── Assets.xcassets
└── README.md
```

## Requirements

- macOS with Xcode installed
- For iPhone app development: Xcode with iOS Simulator or a real iPhone
- For Mac app development: Xcode on Apple Silicon or Intel Mac running a supported macOS version

## Run The iPhone App

1. Open `HashKeyApp.xcodeproj` in Xcode.
2. Select an iPhone simulator or connected iPhone.
3. Press Run.

## Run The Mac App

1. Open `HashKeyMac.xcodeproj` in Xcode.
2. Select the `HashKeyMac` macOS target.
3. Press Run.

## Verify Against An Online Tool

To confirm the full hash matches an online result:

1. Open the Devglan tool:
   [https://www.devglan.com/online-tools/hmac-sha256-online](https://www.devglan.com/online-tools/hmac-sha256-online)
2. Enter the same plain text.
3. Enter the same secret key.
4. Choose `SHA-256`.
5. Choose `Hex` output.
6. Compare the website result with the app's `Full Hash`.

Important:

- the app trims leading and trailing spaces/newlines from the plain text before hashing
- the secret key is used as UTF-8 plain text
- the `Password Hash` is not a different algorithm, only a shortened display of the full hex result

