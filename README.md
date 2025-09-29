# MatrixJP – Japanese Matrix Rain in Terminal

MatrixJP is a lightweight Python script that creates a **Matrix-style “digital rain” effect** in your terminal using Japanese characters (half-width or full-width Katakana).

## ✨ Features
- Runs directly in any terminal with Python 3.  
- Uses **Katakana characters** (half-width by default, optional full-width).  
- Adjustable speed and tail length.  
- Quits cleanly with `q` or `Esc`.  
- Works on macOS (M1/M2), Linux, and other Unix-like systems with UTF-8 terminals.

---

## 🚀 Installation
Clone or copy this script into your workspace:

```bash
git clone https://github.com/spaceshiptrip/matrixjp.git
cd matrixjp
````

No external dependencies are required beyond Python 3.

---

## ▶️ Usage

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

## 🛠️ Tips

* For best results, set your terminal font to a CJK-capable monospaced font, e.g. **Noto Sans Mono CJK JP**.
* Make sure your terminal is set to **UTF-8 encoding**.
* To adjust the effect:

  * Change `time.sleep(0.03)` inside the script → controls speed.
  * Change the `tail` variable → controls trail length.

---

## 📸 Demo

*(screenshot placeholder — insert your terminal screenshot here)*

---

## 📜 License

MIT License — feel free to modify and share.


