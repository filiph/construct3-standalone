const { app, BrowserWindow, session } = require('electron');

const INITIAL_URL = 'https://www.umimematiku.cz/';

function isAllowedUrl(url) {
  try {
    // Create URL object to validate format
    const urlObj = new URL(url);
    
    // Define allowed domains as regular expressions
    const allowRegexes = [
      /umimeto\.org/,
      /umimecesky\.cz/,
      /umimeanglicky\.cz/,
      /umimenemecky\.cz/,
      /umimematiku\.cz/,
      /umimefakta\.cz/,
      /umimeinformatiku\.cz/,
      // Catch-all for future "umimeto" properties
      /umime\w+\.cz/,
      /googleapis\.com/,
      /fonts\.gstatic\.com/,
      /googletagmanager\.com/,
      /play\.google\.com/,
    ];
    
    // Check if the hostname matches any of our regex patterns
    return allowRegexes.some(regex => regex.test(urlObj.hostname));
  } catch (e) {
    // URL is not valid format
    return false;
  }
}

function isAllowedEmbed(url) {
  return true;
}

//
// ------------ IMPLEMENTATION -----------------
//

function createWindow() {
  // Create the browser window.
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: false, // Disable Node integration for security
      contextIsolation: true  // Enable context isolation for security
    }
  });

  // Load the website
  win.loadURL(INITIAL_URL);

  // Open the DevTools (optional)
  // win.webContents.openDevTools();

  // Intercept and filter network requests
  const filter = {
    urls: ['*://*/*']
  };

  session.defaultSession.webRequest.onBeforeRequest(filter, (details, callback) => {
    const { url } = details;
    if (isAllowedEmbed(url)) {
      callback({ cancel: false });
    } else {
      callback({ cancel: true });
    }
  });

  // Prevent navigation to other domains
  win.webContents.on('will-navigate', (event, url) => {
    if (!isAllowedUrl(url)) {
      event.preventDefault();
    }
  });

  win.webContents.on('new-window', (event, url) => {
    if (!isAllowedUrl(url)) {
      event.preventDefault();
    }
  });
}

// This method will be called when Electron has finished initialization.
app.whenReady().then(createWindow);

// Quit when all windows are closed.
app.on('window-all-closed', () => {
  // On macOS it is common for applications to stay open until the user explicitly quits.
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  // On macOS it is common to re-create a window when the dock icon is clicked and there are no other windows open.
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});
