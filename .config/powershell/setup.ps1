Write-Host "🚀 Bắt đầu thiết lập môi trường Windows..." -ForegroundColor Green

# --- Bước 1: Kiểm tra và cài đặt Scoop ---
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Scoop chưa được cài đặt. Đang tiến hành cài đặt..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    irm get.scoop.sh | iex
} else {
    Write-Host "✅ Scoop đã được cài đặt."
}

# --- Bước 2: Cài đặt tất cả ứng dụng từ file scoop.json ---
$scoopManifest = "$PSScriptRoot\..\scoop\scoop.json"
if (Test-Path $scoopManifest) {
    Write-Host "Tìm thấy file scoop.json. Bắt đầu cài đặt các ứng dụng..."
    scoop import $scoopManifest
} else {
    Write-Warning "Không tìm thấy file scoop.json. Bỏ qua bước cài đặt ứng dụng."
}

# --- Bước 3: Tạo liên kết tượng trưng (Symlink) cho các cấu hình ---
Write-Host "🔗 Bắt đầu tạo liên kết cho các dotfiles..."

# Đường dẫn đến thư mục cấu hình trong repo của bạn
$dotfilesSource = "$PSScriptRoot"
# Đường dẫn đến nơi Windows lưu cấu hình
$configTarget = "$env:USERPROFILE\.config"
$localAppDataTarget = "$env:LOCALAPPDATA"

# Tạo thư mục .config nếu chưa có
if (-not (Test-Path $configTarget)) {
    New-Item -Path $configTarget -ItemType Directory | Out-Null
}

# Ví dụ: Tạo symlink cho Neovim
$nvimSource = Join-Path $dotfilesSource "config\nvim"
$nvimTarget = Join-Path $localAppDataTarget "nvim"

if (Test-Path $nvimTarget) {
    Write-Host "Cấu hình Neovim đã tồn tại. Bỏ qua."
} else {
    Write-Host "Tạo liên kết cho Neovim..."
    New-Item -ItemType SymbolicLink -Path $nvimTarget -Target $nvimSource
}

# --- Thêm các symlink khác ở đây (ví dụ: cho foot, wezterm, etc.) ---


Write-Host "🎉 Hoàn tất! Môi trường của bạn đã sẵn sàng." -ForegroundColor Green