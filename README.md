This is a tiny project that uses 
[Electron](https://www.electronjs.org/)
to wrap a website or web app
(such as [Construct 3](https://www.construct.net/en),
the game engine)
into a standalone application.

Why? This is so that the kid can use the web-based tool without me having to open up
the whole internet for them. 
I'm using a family safety tool that gives the kid only a limited amount of time for some apps,
namely the browser.
But I also want the kid to have unlimited time for creativity.
Thus, I need some websites to be standalone apps.

**Full disclosure:**
Absolutely no warranty, no support, no documentation, no time to even explain this project.
I'm making this open source on the off chance that it's useful for someone else out there,
but if you hit a snag, I'm afraid you're on your own.

## Development

### Using the Dart Tool (Recommended)

This project includes a Dart command-line tool that automates the process of creating an Electron app from a TOML configuration file.

1. Make sure you have Dart installed.
2. Create or modify a TOML configuration file (see `construct3.toml` for an example). The TOML file should include fields like `name`, `version`, `description`, `author`, and `initialUrl` to configure your app.
3. Run the tool:

```bash
dart run bin/kids_standalone_website.dart
```

By default, the tool will:
- Read from `construct3.toml`
- Create a new Electron project in `dist/electron_app/`
- Use the template in `electron_app/`

You can customize these paths using command-line options:

```bash
dart run bin/kids_standalone_website.dart --help
```

Available options:
- `-i, --input`: Path to the TOML configuration file (default: `construct3.toml`)
- `-o, --output`: Path to the output directory (default: `dist/electron_app`)
- `-t, --template`: Path to the template directory (default: `electron_app`)
- `-v, --verbose`: Show additional command output
- `--help`: Print usage information
- `--version`: Print the tool version

#### TOML Configuration

The TOML configuration file should include the following fields:

- `name`: The name of your Electron app
- `version`: The version of your app
- `description`: A description of your app
- `author`: The author of the app
- `initialUrl`: The initial URL that will be loaded when the app starts
- `[build]`: Build configuration section
  - `appId`: The application ID
- `[whitelist]`: URL whitelist configuration
  - `navigate`: List of allowed URLs (as regular expressions) that the user can navigate to
  - `embed`: List of URLs (as regular expressions) that the page can access

### The Manual Way

Go to `electron_app/`.

To install dependencies, run `npm install`.

Edit:

- Edit the `index.js` file to your liking.
- Change `build/icon.ico` to your liking.

Run `npm start` in the root of the project to test the app out.

## Build

In `electron_app`, run `npm run build` to build the app.

If you used the Dart tool to create your project, navigate to the output directory (default: `dist/electron_app`) and run:

```bash
npm install
npm start    # To test the app
npm run build # To build the app
```
