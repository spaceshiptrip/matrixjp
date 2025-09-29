# MatrixJP.ps1 — Japanese Matrix rain (Windows, no dependencies)
# Run:  powershell -ExecutionPolicy Bypass -File .\matrixjp.ps1
# Quit: Ctrl+C

# Prefer UTF-8 output when possible
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}

# Build half-width Katakana programmatically to avoid encoding issues
# Main half-width Katakana: U+FF71..U+FF9D, plus small kana U+FF67..U+FF6F and the long mark U+FF70
$codepoints = @()
$codepoints += (0xFF67..0xFF6F)  # small ｧｨｩｪｫｯｬｭｮ
$codepoints += 0xFF70            # ｰ
$codepoints += (0xFF71..0xFF9D)  # ｱ..ﾝ
$Charset = -join ($codepoints | ForEach-Object { [char]$_ })

# ANSI helpers
$ESC   = [char]27
$CSI   = "$ESC["
$GREEN_BRIGHT = "${CSI}92m"
$GREEN_DIM    = "${CSI}32;2m"
$RESET        = "${CSI}0m"
$HIDE_CURSOR  = "${CSI}?25l"
$SHOW_CURSOR  = "${CSI}?25h"

# Settings
$delayMs = 30      # lower = faster
$tailLen = 12      # trail length

$raw  = $Host.UI.RawUI
$size = $raw.WindowSize
$width  = [Math]::Max(2, $size.Width)
$height = [Math]::Max(2, $size.Height)

# One drop per column
$drops  = New-Object int[] $width
$speeds = New-Object int[] $width
$rnd = [Random]::new()

for ($x=0; $x -lt $width; $x++) {
  $drops[$x]  = -$rnd.Next(0, $height)         # start above screen
  $speeds[$x] = @(1,1,1,2)[$rnd.Next(0,4)]     # mostly slow
}

function GotoXY([int]$row, [int]$col) {
  return "$CSI$($row);$($col)H"
}
function DrawChar([int]$row, [int]$col, [string]$ch, [string]$style) {
  if ($row -ge 1 -and $row -le $height -and $col -ge 1 -and $col -le $width) {
    Write-Host ("{0}{1}{2}{3}" -f (GotoXY $row $col), $style, $ch, $RESET) -NoNewline
  }
}

# Hide cursor + clear screen
Write-Host $HIDE_CURSOR -NoNewline
Write-Host ("{0}2J" -f $CSI) -NoNewline

try {
  while ($true) {
    # Handle window resize
    $size = $raw.WindowSize
    $width  = [Math]::Max(2, $size.Width)
    $height = [Math]::Max(2, $size.Height)

    for ($x = 1; $x -lt $width; $x++) {
      $y = $drops[$x]

      # Head (bright)
      if ($y -ge 1 -and $y -le $height) {
        $ch = $Charset[$rnd.Next(0, $Charset.Length)]
        DrawChar $y $x $ch $GREEN_BRIGHT
      }

      # Tail (dim)
      for ($i=1; $i -le $tailLen; $i++) {
        $yy = $y - $i
        if ($yy -ge 1 -and $yy -le $height) {
          $ch = $Charset[$rnd.Next(0, $Charset.Length)]
          DrawChar $yy $x $ch $GREEN_DIM
        }
      }

      # Clear behind tail
      $clearY = $y - $tailLen
      if ($clearY -ge 1 -and $clearY -le $height) {
        Write-Host ("{0} " -f (GotoXY $clearY $x)) -NoNewline
      }

      # Advance + recycle
      $drops[$x] += $speeds[$x]
      if ($drops[$x] - $tailLen -gt $height) {
        $drops[$x]  = -$rnd.Next(0, [Math]::Max(2, [int]($height/2)))
        $speeds[$x] = @(1,1,2)[$rnd.Next(0,3)]
      }
    }

    Start-Sleep -Milliseconds $delayMs
  }
}
finally {
  Write-Host $SHOW_CURSOR -NoNewline
  Write-Host $RESET
}
