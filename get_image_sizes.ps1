Add-Type -AssemblyName System.Drawing
$img1 = New-Object System.Drawing.Bitmap("frontend\public\icon-wind-hawt-hybride.jpg")
$img2 = New-Object System.Drawing.Bitmap("frontend\public\icon-pv-hybride.jpg")
Write-Output "wind-hawt: $($img1.Width)x$($img1.Height)"
Write-Output "pv-hybrid: $($img2.Width)x$($img2.Height)"
$img1.Dispose()
$img2.Dispose()

