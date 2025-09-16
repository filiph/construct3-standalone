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

[![No Maintenance Intended](http://unmaintained.tech/badge.svg)](http://unmaintained.tech/)

**Full disclosure:**
Absolutely no warranty, no support, no documentation, no time to even explain this project.
I'm making this open source on the off chance that it's useful for someone else out there,
but if you hit a snag, I'm afraid you're on your own.

## Using the Dart Tool

This project includes a Dart command-line tool that 
automates the process of creating an Electron app from a TOML configuration file.

1. Make sure you have [Dart](https://dart.dev/get-dart) installed.
2. Create or modify a TOML configuration file (see `construct3.toml` for an example). 
3. Run the tool:

```bash
dart run bin/kids_standalone_website.dart --input path/to/your.toml
```

By default, the tool will:

- Create a new Electron project in `dist/electron_app/`
- Use the template in `electron_app_template/`

You can customize these paths using command-line options:

```bash
dart run bin/kids_standalone_website.dart --help
```

After the tool is finished, it tells you how to test and build the app.
Something like the following:

```
Recommended next steps:
  cd dist/electron_app
  npm install
  npm start    # To run the application
  npm run build    # To build the application
```


### The Manual Way

Make a copy of the project in `electron_app_template/` and `cd` into it.

To install dependencies, run `npm install`.

Edit the template:

- Edit the `index.js` file to your liking.
- Edit the `package.json` file to your liking.
- Change `build/icon.ico` to your liking.

Run `npm start` in the root of the project to test the app out,
and `npm run build` to build it.
