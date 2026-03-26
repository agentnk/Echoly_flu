// App State
let isPlaying = false;
let fontSize = 26;
let currentLineIndex = 0;
let defaultText = `Welcome to Echoly -
Web Teleprompter

This is a sample speech to demonstrate the app.

Press the Play button to begin.

Then press Return or Enter to advance through your script.

You can adjust the font size using the A- and A+ buttons.`;

let scriptLines = defaultText.split('\n');

// Init Icons
lucide.createIcons();

// DOM Elements
const contentContainer = document.getElementById('prompter-content');
const prompterContainer = document.getElementById('prompter-container');
const playBtn = document.getElementById('play-pause');
const playIcon = document.getElementById('play-icon');
const fontInc = document.getElementById('font-increase');
const fontDec = document.getElementById('font-decrease');
const fontSizeDisplay = document.getElementById('font-size-display');
const themeToggle = document.getElementById('theme-toggle');
const statusDot = document.getElementById('status-dot');
const statusText = document.getElementById('status-text');
const pagination = document.getElementById('pagination');
const fileInput = document.getElementById('file-input');
const openFileBtn = document.getElementById('open-file');
const fileNameDisplay = document.getElementById('file-name');

// Render Text
function renderText() {
  contentContainer.innerHTML = '';
  document.documentElement.style.setProperty('--current-font-size', `${fontSize}px`);
  
  scriptLines.forEach((line, index) => {
    const div = document.createElement('div');
    div.className = 'line';
    if (index === 0 || index === 1) {
      // Treat first couple of lines as title optionally (based on Mockup)
      div.classList.add('title');
    }
    div.innerText = line || '\u00A0'; // Non-breaking space for empty lines
    div.id = `line-${index}`;
    contentContainer.appendChild(div);
  });
  updateActiveLine();
}

function updateActiveLine() {
  const lines = document.querySelectorAll('.line');
  lines.forEach((line, index) => {
    // Dynamic resizing via JS logic
    line.style.fontSize = line.classList.contains('title') ? `${fontSize * 1.5}px` : `${fontSize}px`;
    if (index === currentLineIndex) {
      line.classList.add('active');
    } else {
      line.classList.remove('active');
    }
  });
  
  pagination.innerText = `${currentLineIndex + 1} / ${scriptLines.length || 1}`;
}

// Scrolling Logic
let scrollInterval;
function togglePlay() {
  isPlaying = !isPlaying;
  
  if (isPlaying) {
    playIcon.setAttribute('data-lucide', 'pause');
    statusDot.classList.add('playing');
    statusText.innerText = 'PLAYING';
    
    // Auto-scroll loop mechanics
    scrollInterval = setInterval(() => {
      prompterContainer.scrollTop += 1.5; // Controls reading speed
    }, 50);
  } else {
    playIcon.setAttribute('data-lucide', 'play');
    statusDot.classList.remove('playing');
    statusText.innerText = 'PAUSED';
    clearInterval(scrollInterval);
  }
  lucide.createIcons();
}

// Track active line based on scroll
prompterContainer.addEventListener('scroll', () => {
  const lines = document.querySelectorAll('.line');
  // Visual midpoint where eyes are
  const viewCenter = prompterContainer.scrollTop + (window.innerHeight * 0.45);
  
  let closestIndex = 0;
  let minDistance = Infinity;
  
  lines.forEach((line, idx) => {
    const distance = Math.abs((line.offsetTop + line.offsetHeight / 2) - viewCenter);
    if (distance < minDistance) {
      minDistance = distance;
      closestIndex = idx;
    }
  });

  if (closestIndex !== currentLineIndex) {
    currentLineIndex = closestIndex;
    updateActiveLine();
  }
});

// Font Controls
fontInc.addEventListener('click', () => {
  if (fontSize < 100) {
    fontSize += 2;
    fontSizeDisplay.innerText = `${fontSize}pt`;
    updateActiveLine();
  }
});

fontDec.addEventListener('click', () => {
  if (fontSize > 12) {
    fontSize -= 2;
    fontSizeDisplay.innerText = `${fontSize}pt`;
    updateActiveLine();
  }
});

// Event Listeners
playBtn.addEventListener('click', togglePlay);

themeToggle.addEventListener('click', () => {
  document.body.classList.toggle('dark');
  const isDark = document.body.classList.contains('dark');
  themeToggle.innerHTML = `<i data-lucide="${isDark ? 'sun' : 'moon'}"></i>`;
  lucide.createIcons();
});

// File Loader for local txt
openFileBtn.addEventListener('click', () => fileInput.click());
fileInput.addEventListener('change', (e) => {
  const file = e.target.files[0];
  if (!file) return;
  
  fileNameDisplay.innerText = file.name;
  const reader = new FileReader();
  reader.onload = function(e) {
    scriptLines = e.target.result.split('\n');
    currentLineIndex = 0;
    if(isPlaying) togglePlay(); 
    prompterContainer.scrollTop = 0;
    renderText();
  };
  reader.readAsText(file);
});

// Basic Keyboard Shortcuts
document.addEventListener('keydown', (e) => {
  if (e.code === 'Space' || e.code === 'Enter') {
    e.preventDefault();
    togglePlay();
  }
});

// Init
renderText();
