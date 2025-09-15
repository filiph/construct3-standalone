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

### The manual way

Go to `electron_app/`.

To install dependencies, run `npm install`.

Edit:

- Edit the `index.js` file to your liking.
- Change `build/icon.ico` to your liking.

Run `npm start` in the root of the project to test the app out.

## Build

In `electron_app`, run `npm run build` to build the app.
