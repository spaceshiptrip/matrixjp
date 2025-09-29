# MatrixJP – Japanese Matrix Rain in Terminal

MatrixJP is a lightweight script that creates a **Matrix-style “digital rain” effect** in your terminal using Japanese characters (half-width or full-width Katakana).

## ✨ Features
- Runs directly in any terminal with Python 3 (macOS/Linux).  
- Runs on Windows with a standalone PowerShell script.  
- Uses **Katakana characters** (half-width by default, optional full-width).  
- Adjustable speed and tail length.  
- Quits cleanly with `q` or `Esc` (Python) or `Ctrl+C` (PowerShell).  
- Works on macOS (M1/M2), Linux, Windows 10/11 terminals.

---

## 🚀 Installation

Clone or copy this repo:

```bash
git clone https://github.com/spaceshiptrip/matrixjp.git
cd matrixjp
````

No external dependencies are required beyond Python 3 (for macOS/Linux).
For Windows, just use the provided PowerShell script.

---

## ▶️ Usage (macOS/Linux)

Run with default half-width characters (best compatibility):

```bash
python3 matrixjp.py
```

Run with **full-width Japanese characters**:

```bash
python3 matrixjp.py --full
```

Quit at any time by pressing **q** or **Esc**.

---

## ▶️ Usage (Windows PowerShell)

Use the included `matrixjp.ps1` script:

```powershell
powershell -ExecutionPolicy Bypass -File .\matrixjp.ps1
```

Quit at any time with **Ctrl+C**.

> ⚡ Note: Works best in **Windows Terminal** with UTF-8 output enabled.

---

## 🛠️ Tips

* For best results, set your terminal font to a CJK-capable monospaced font, e.g. **Noto Sans Mono CJK JP**.
* Make sure your terminal is set to **UTF-8 encoding**.
* To adjust the effect (Python version):

  * Change `time.sleep(0.03)` inside the script → controls speed.
  * Change the `tail` variable → controls trail length.
* To adjust the effect (PowerShell version):

  * Change `$delayMs = 30` → controls speed.
  * Change `$tailLen = 12` → controls trail length.

---

## 📸 Demo

![MatrixJP Demo](pub/matrix-demo.png)

---

## 📜 License

MIT License — feel free to modify and share.

