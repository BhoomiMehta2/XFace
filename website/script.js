// Spectrum Landing Page JavaScript

// Theme Configurations
const themes = {
    sakura: {
        name: "Sakura",
        json: `{
  "name": "Sakura",
  "type": "dark",
  "colors": {
    "editor.background": "#1f1125",
    "editor.foreground": "#f0cfe8",
    "editorCursor.foreground": "#ff85c2",
    "editor.selectionBackground": "#a0446066",
    "editor.lineHighlightBackground": "#2a1530"
  },
  "tokenColors": [
    {
      "name": "Keywords",
      "scope": ["keyword", "storage"],
      "settings": { "foreground": "#ff85c2" }
    },
    {
      "name": "Strings",
      "scope": ["string"],
      "settings": { "foreground": "#ffafd7" }
    },
    {
      "name": "Comments",
      "scope": ["comment"],
      "settings": { "foreground": "#7a4f6d" }
    }
  ]
}`,
        colors: {
            bg: "#1f1125",
            fg: "#f0cfe8",
            kw: "#ff85c2",
            typ: "#e8a0d0",
            str: "#ffafd7",
            func: "#f987c5",
            var: "#f0cfe8",
            comment: "#7a4f6d",
            selection: "rgba(160, 68, 96, 0.4)",
            cursor: "#ff85c2"
        }
    },
    dracula: {
        name: "Dracula",
        json: `{
  "name": "Dracula",
  "type": "dark",
  "colors": {
    "editor.background": "#282a36",
    "editor.foreground": "#f8f8f2",
    "editorCursor.foreground": "#f8f8f0",
    "editor.selectionBackground": "#44475a55",
    "editor.lineHighlightBackground": "#44475a"
  },
  "tokenColors": [
    {
      "name": "Keywords",
      "scope": ["keyword", "storage"],
      "settings": { "foreground": "#ff79c6" }
    },
    {
      "name": "Strings",
      "scope": ["string"],
      "settings": { "foreground": "#f1fa8c" }
    },
    {
      "name": "Comments",
      "scope": ["comment"],
      "settings": { "foreground": "#6272a4" }
    }
  ]
}`,
        colors: {
            bg: "#282a36",
            fg: "#f8f8f2",
            kw: "#ff79c6",
            typ: "#8be9fd",
            str: "#f1fa8c",
            func: "#50fa7b",
            var: "#f8f8f2",
            comment: "#6272a4",
            selection: "rgba(68, 71, 90, 0.5)",
            cursor: "#f8f8f0"
        }
    },
    tokyonight: {
        name: "Tokyo Night",
        json: `{
  "name": "Tokyo Night",
  "type": "dark",
  "colors": {
    "editor.background": "#1a1b26",
    "editor.foreground": "#a9b1d6",
    "editorCursor.foreground": "#c0caf5",
    "editor.selectionBackground": "#33467566",
    "editor.lineHighlightBackground": "#1f2335"
  },
  "tokenColors": [
    {
      "name": "Keywords",
      "scope": ["keyword", "storage"],
      "settings": { "foreground": "#bb9af7" }
    },
    {
      "name": "Strings",
      "scope": ["string"],
      "settings": { "foreground": "#9ece6a" }
    },
    {
      "name": "Comments",
      "scope": ["comment"],
      "settings": { "foreground": "#565f89" }
    }
  ]
}`,
        colors: {
            bg: "#1a1b26",
            fg: "#a9b1d6",
            kw: "#bb9af7",
            typ: "#2ac3de",
            str: "#9ece6a",
            func: "#7aa2f7",
            var: "#c0caf5",
            comment: "#565f89",
            selection: "rgba(51, 70, 117, 0.4)",
            cursor: "#c0caf5"
        }
    },
    catppuccin: {
        name: "Catppuccin Macchiato",
        json: `{
  "name": "Catppuccin Macchiato",
  "type": "dark",
  "colors": {
    "editor.background": "#24273a",
    "editor.foreground": "#cad3f5",
    "editorCursor.foreground": "#f4dbd6",
    "editor.selectionBackground": "#5b607866",
    "editor.lineHighlightBackground": "#363a4f"
  },
  "tokenColors": [
    {
      "name": "Keywords",
      "scope": ["keyword", "storage"],
      "settings": { "foreground": "#c6a0f6" }
    },
    {
      "name": "Strings",
      "scope": ["string"],
      "settings": { "foreground": "#a6da95" }
    },
    {
      "name": "Comments",
      "scope": ["comment"],
      "settings": { "foreground": "#8087a2" }
    }
  ]
}`,
        colors: {
            bg: "#24273a",
            fg: "#cad3f5",
            kw: "#c6a0f6",
            typ: "#f5a97f",
            str: "#a6da95",
            func: "#8aadf4",
            var: "#cad3f5",
            comment: "#8087a2",
            selection: "rgba(91, 96, 120, 0.4)",
            cursor: "#f4dbd6"
        }
    }
};

document.addEventListener("DOMContentLoaded", () => {
    const jsonBlock = document.getElementById("json-code-block");
    const tabBtns = document.querySelectorAll(".tab-btn");
    const simulatorSection = document.getElementById("xcode-preview-pane");
    const simInstallBtn = document.getElementById("sim-install-btn");
    const dividerArrow = document.querySelector(".pulse-line");

    // Load initial Sakura theme
    updateThemeDisplay("sakura");

    // Interactive simulator tabs
    tabBtns.forEach(btn => {
        btn.addEventListener("click", () => {
            tabBtns.forEach(b => b.classList.remove("active"));
            btn.classList.add("active");
            const themeKey = btn.getAttribute("data-theme");
            updateThemeDisplay(themeKey);
        });
    });

    function updateThemeDisplay(themeKey) {
        const selectedTheme = themes[themeKey];
        if (!selectedTheme) return;

        // 1. Update JSON block content
        jsonBlock.textContent = selectedTheme.json;

        // 2. Set Xcode preview styles via CSS variables
        const root = document.documentElement;
        root.style.setProperty("--code-bg", selectedTheme.colors.bg);
        root.style.setProperty("--code-fg", selectedTheme.colors.fg);
        root.style.setProperty("--code-kw", selectedTheme.colors.kw);
        root.style.setProperty("--code-typ", selectedTheme.colors.typ);
        root.style.setProperty("--code-str", selectedTheme.colors.str);
        root.style.setProperty("--code-func", selectedTheme.colors.func);
        root.style.setProperty("--code-var", selectedTheme.colors.var);
        root.style.setProperty("--code-comment", selectedTheme.colors.comment);
        root.style.setProperty("--code-selection", selectedTheme.colors.selection);
        root.style.setProperty("--code-cursor", selectedTheme.colors.cursor);
    }

    // Simulate Install Click
    simInstallBtn.addEventListener("click", () => {
        if (simInstallBtn.disabled) return;

        // Disable button & animate arrow
        simInstallBtn.disabled = true;
        simInstallBtn.textContent = "Converting...";
        
        // Triggers CSS transition arrow flow
        const arrowCircle = document.querySelector(".arrow-circle");
        arrowCircle.style.transform = "scale(1.2)";
        arrowCircle.style.background = "#10b981"; // Success green

        setTimeout(() => {
            simInstallBtn.textContent = "Installed to Xcode! ✓";
            simInstallBtn.style.background = "#10b981";
            simInstallBtn.style.borderColor = "#10b981";
            arrowCircle.style.transform = "scale(1)";

            // Reset after 3.5s
            setTimeout(() => {
                simInstallBtn.disabled = false;
                simInstallBtn.textContent = "Simulate Install";
                simInstallBtn.style.background = "";
                simInstallBtn.style.borderColor = "";
                arrowCircle.style.background = "";
            }, 3000);
        }, 1200);
    });

    // Gatekeeper Tab Control
    const gkTabBtns = document.querySelectorAll(".gk-tab-btn");
    const gkPanes = document.querySelectorAll(".gk-pane");

    gkTabBtns.forEach(btn => {
        btn.addEventListener("click", () => {
            gkTabBtns.forEach(b => b.classList.remove("active"));
            gkPanes.forEach(p => p.classList.remove("active"));

            btn.classList.add("active");
            const tabId = btn.getAttribute("data-tab");
            const targetPane = document.getElementById(`gk-${tabId}`);
            if (targetPane) {
                targetPane.classList.add("active");
            }
        });
    });

    // Copy Command Button
    const copyCmdBtn = document.getElementById("copy-cmd-btn");
    const cmdToCopy = document.getElementById("cmd-to-copy");

    function copyTextToClipboard(text) {
        if (navigator.clipboard && window.isSecureContext) {
            return navigator.clipboard.writeText(text);
        } else {
            return new Promise((resolve, reject) => {
                const textArea = document.createElement("textarea");
                textArea.value = text;
                textArea.style.position = "fixed";
                textArea.style.left = "-999999px";
                textArea.style.top = "-999999px";
                document.body.appendChild(textArea);
                textArea.focus();
                textArea.select();
                try {
                    const successful = document.execCommand('copy');
                    document.body.removeChild(textArea);
                    if (successful) {
                        resolve();
                    } else {
                        reject(new Error("execCommand copy failed"));
                    }
                } catch (err) {
                    document.body.removeChild(textArea);
                    reject(err);
                }
            });
        }
    }

    if (copyCmdBtn && cmdToCopy) {
        copyCmdBtn.addEventListener("click", () => {
            const commandText = cmdToCopy.textContent.trim();
            copyTextToClipboard(commandText).then(() => {
                copyCmdBtn.textContent = "Command Copied! ✓";
                copyCmdBtn.classList.add("copied");

                setTimeout(() => {
                    copyCmdBtn.textContent = "Copy Command";
                    copyCmdBtn.classList.remove("copied");
                }, 2500);
            }).catch(err => {
                console.error("Failed to copy command:", err);
                copyCmdBtn.textContent = "Command Copied! ✓";
                copyCmdBtn.classList.add("copied");
                setTimeout(() => {
                    copyCmdBtn.textContent = "Copy Command";
                    copyCmdBtn.classList.remove("copied");
                }, 2500);
            });
        });
    }
});
