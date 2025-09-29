# MatrixJP (fast) — batches each frame into ONE console write
# Run: powershell -ExecutionPolicy Bypass -File .\matrixjp_fast.ps1
# Quit: Ctrl+C

try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}

# Build half-width Katakana (safe: no literal JP in file)
$cp = @()
$cp += (0xFF67..0xFF6F)  # small ｧｨｩｪｫｯｬｭｮ
$cp += 0xFF70            # ｰ
$cp += (0xFF71..0xFF9D)  # ｱ..ﾝ
$CHARSET = -join ($cp | ForEach-Object { [char]$_ })

$ESC = [char]27; $CSI = "$ESC["
$HIDE = "${CSI}?25l"; $SHOW = "${CSI}?25h"
$CLR  = "${CSI}2J";   $HOME = "${CSI}H"
$GREEN = "${CSI}32m"; $GREEN_BRIGHT = "${CSI}92m"; $DIM = "${CSI}2m"; $RST = "${CSI}0m"

# Tunables
$delayMs = 10          # lower = faster
$tailLen = 8           # trail length

$raw = $Host.UI.RawUI
$size = $raw.WindowSize
$W = [Math]::Max(4, $size.Width)
$H = [Math]::Max(4, $size.Height)

# One drop per column (skip col 0 to avoid left edge weirdness)
$drops  = New-Object int[] $W
$speeds = New-Object int[] $W
$r = [Random]::new()
for ($x=1; $x -lt $W; $x++) {
  $drops[$x]  = -$r.Next(0, $H)
  $speeds[$x] = @(1,1,1,2)[$r.Next(0,4)]
}

# Pre-alloc a StringBuilder with a rough capacity to minimize reallocs
$cap = [int]([Math]::Max(100000, $W * $H * 6))
$sb  = [System.Text.StringBuilder]::new($cap)

# Hide cursor + clear once
[Console]::Write($HIDE + $CLR)

try {
  while ($true) {
    # Handle resize
    $size = $raw.WindowSize
    $W = [Math]::Max(4, $size.Width)
    $H = [Math]::Max(4, $size.Height)

    $sb.Clear() | Out-Null
    [void]$sb.Append($HOME)  # top-left each frame

    # Draw all columns into one big string
    for ($x=1; $x -lt $W; $x++) {
      $y = $drops[$x]

      # Head (bright)
      if ($y -ge 1 -and $y -le $H) {
        $ch = $CHARSET[$r.Next(0, $CHARSET.Length)]
        [void]$sb.AppendFormat("{0}{1};{2}H{3}{4}{5}", $CSI, $y, $x, $GREEN_BRIGHT, $ch, $RST)
      }

      # Tail (dim)
      for ($i=1; $i -le $tailLen; $i++) {
        $yy = $y - $i
        if ($yy -lt 1 -or $yy -gt $H) { continue }
        $ch = $CHARSET[$r.Next(0, $CHARSET.Length)]
        # Slight fade using DIM; cheap and fast
        [void]$sb.AppendFormat("{0}{1};{2}H{3}{4}{5}{6}", $CSI, $yy, $x, $GREEN, $DIM, $ch, $RST)
      }

      # Clear behind tail (write a space)
      $clearY = $y - $tailLen
      if ($clearY -ge 1 -and $clearY -le $H) {
        [void]$sb.AppendFormat("{0}{1};{2}H ", $CSI, $clearY, $x)
      }

      # Advance
      $drops[$x] += $speeds[$x]
      if ($drops[$x] - $tailLen -gt $H) {
        $drops[$x]  = -$r.Next(0, [Math]::Max(2, [int]($H/2)))
        $speeds[$x] = @(1,1,2)[$r.Next(0,3)]
      }
    }

    # Write the whole frame at once
    [Console]::Write($sb.ToString())
    Start-Sleep -Milliseconds $delayMs
  }
}
finally {
  [Console]::Write($SHOW + $RST)
}
