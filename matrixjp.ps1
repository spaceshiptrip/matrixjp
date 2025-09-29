<# 
MatrixJP (fast) — Japanese Matrix rain for Windows Terminal/PowerShell

Usage examples:
  # clear every frame (default), 10ms delay, medium tail
  powershell -ExecutionPolicy Bypass -File .\matrixjp_fast.ps1

  # clear every 5 frames (less flicker), faster, shorter tail
  powershell -ExecutionPolicy Bypass -File .\matrixjp_fast.ps1 -ClearEveryN 5 -DelayMs 5 -TailLen 6

  # never clear (fastest, may leave artifacts)
  powershell -ExecutionPolicy Bypass -File .\matrixjp_fast.ps1 -ClearEveryN 0

  # draw every other column (perf boost on huge terminals)
  powershell -ExecutionPolicy Bypass -File .\matrixjp_fast.ps1 -ColStep 2
#>

param(
  [int]$DelayMs    = 10,  # lower = faster
  [int]$TailLen    = 8,   # trail length
  [int]$ClearEveryN = 1,  # 1 = clear every frame (no artifacts), 0 = never, N = every Nth frame
  [int]$ColStep    = 1    # draw every Nth column (1 = all columns)
)

try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}

# Build half-width Katakana (no literal JP text in file; encoding-safe)
$cp = @()
$cp += (0xFF67..0xFF6F)  # ｧｨｩｪｫｯｬｭｮ
$cp += 0xFF70            # ｰ
$cp += (0xFF71..0xFF9D)  # ｱ..ﾝ
$CHARSET = -join ($cp | ForEach-Object {[char]$_})

# ANSI
$ESC = [char]27; $CSI = "$ESC["
$HIDE = "${CSI}?25l"; $SHOW = "${CSI}?25h"
$CLR  = "${CSI}2J";   $HOME = "${CSI}H"
$GREEN = "${CSI}32m"; $GREEN_BRIGHT = "${CSI}92m"; $DIM = "${CSI}2m"; $RST = "${CSI}0m"

# Terminal geometry
$raw  = $Host.UI.RawUI
$size = $raw.WindowSize
$W = [Math]::Max(4, $size.Width)
$H = [Math]::Max(4, $size.Height)

# Drops per column
$drops  = New-Object int[] $W
$speeds = New-Object int[] $W
$r = [Random]::new()
for ($x=1; $x -lt $W; $x++) {
  $drops[$x]  = -$r.Next(0, $H)
  $speeds[$x] = @(1,1,1,2)[$r.Next(0,4)]
}

# Frame buffer
$cap = [int]([Math]::Max(100000, $W * $H * 6))
$sb  = [System.Text.StringBuilder]::new($cap)

# Hide cursor + full clear once
[Console]::Write($HIDE + $CLR)

$frame = 0
try {
  while ($true) {
    # Resize handling
    $size = $raw.WindowSize
    $W = [Math]::Max(4, $size.Width)
    $H = [Math]::Max(4, $size.Height)

    $sb.Clear() | Out-Null

    # Clear policy
    if ($ClearEveryN -gt 0 -and ($frame % $ClearEveryN -eq 0)) {
      [void]$sb.Append($CLR)
    }
    [void]$sb.Append($HOME)

    # Draw all columns into one big string
    for ($x=1; $x -lt $W; $x += [Math]::Max(1,$ColStep)) {
      $y = $drops[$x]

      # Head (bright)
      if ($y -ge 1 -and $y -le $H) {
        $ch = $CHARSET[$r.Next(0, $CHARSET.Length)]
        [void]$sb.AppendFormat("{0}{1};{2}H{3}{4}{5}", $CSI, $y, $x, $GREEN_BRIGHT, $ch, $RST)
      }

      # Tail (dim)
      for ($i=1; $i -le $TailLen; $i++) {
        $yy = $y - $i
        if ($yy -lt 1 -or $yy -gt $H) { continue }
        $ch = $CHARSET[$r.Next(0, $CHARSET.Length)]
        [void]$sb.AppendFormat("{0}{1};{2}H{3}{4}{5}{6}", $CSI, $yy, $x, $GREEN, $DIM, $ch, $RST)
      }

      # Clear behind tail
      $clearY = $y - $TailLen
      if ($clearY -ge 1 -and $clearY -le $H) {
        [void]$sb.AppendFormat("{0}{1};{2}H ", $CSI, $clearY, $x)
      }

      # Advance/recycle
      $drops[$x] += $speeds[$x]
      if ($drops[$x] - $TailLen -gt $H) {
        $drops[$x]  = -$r.Next(0, [Math]::Max(2, [int]($H/2)))
        $speeds[$x] = @(1,1,2)[$r.Next(0,3)]
      }
    }

    # Emit frame
    [Console]::Write($sb.ToString())
    Start-Sleep -Milliseconds $DelayMs
    $frame++
  }
}
finally {
  [Console]::Write($SHOW + $RST)
}
