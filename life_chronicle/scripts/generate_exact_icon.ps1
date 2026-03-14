Add-Type -AssemblyName System.Drawing

$size = 1024
$bmp = New-Object System.Drawing.Bitmap($size, $size)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# 绘制圆角背景 - 使用 #2BCDEE 颜色
$bgColor = [System.Drawing.Color]::FromArgb(43, 205, 238)
$bgBrush = New-Object System.Drawing.SolidBrush($bgColor)

# 绘制圆角矩形背景
$cornerRadius = 200
$bgRect = New-Object System.Drawing.Rectangle(0, 0, $size, $size)
$bgPath = New-Object System.Drawing.Drawing2D.GraphicsPath

# 左上角
$bgPath.AddArc(0, 0, $cornerRadius * 2, $cornerRadius * 2, 180, 90)
# 右上角
$bgPath.AddArc($size - $cornerRadius * 2, 0, $cornerRadius * 2, $cornerRadius * 2, 270, 90)
# 右下角
$bgPath.AddArc($size - $cornerRadius * 2, $size - $cornerRadius * 2, $cornerRadius *