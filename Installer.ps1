# Dragon's Dogma 2 - DLSS 5 Neural Rendering Installer
# Method: OptiScaler DLSS-NR (game build 3.2.0.0)
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$Script:Root    = Split-Path -Parent $MyInvocation.MyCommand.Path
$Script:Payload = Join-Path $Script:Root 'payload'
$Script:Game    = ''
$Script:Lang    = if ((Get-Culture).Name -like 'ko*') { 'ko' } else { 'en' }
$Script:Entries = New-Object System.Collections.ArrayList
$Script:StateKey = 'state_initial'
$Script:StateArg = @()
$Script:StateCol = [System.Drawing.Color]::Black

# ---------------------------------------------------------------- strings
$Script:S = @{
  ko = @{
    title            = '드래곤즈 도그마 2 - DLSS 5 설치기'
    lang             = '언어'
    lblPath          = '게임 폴더'
    btnAuto          = '자동 탐지'
    btnBrowse        = '찾아보기'
    btnCheck         = '1. 검사'
    btnInstall       = '2. 설치'
    btnRestore       = '복원'
    dlgTitle         = 'DD2.exe 를 선택하세요'

    state_initial    = '[자동 탐지] -> [0. 파일 받기] -> [1. 검사] -> [2. 설치]'
    state_found      = '경로를 찾았습니다. [1. 검사] 를 누르세요'
    state_autoFail   = '자동 탐지 실패'
    state_needPath   = '게임 경로를 먼저 지정하세요'
    state_checkPass  = '검사 통과 - 설치할 수 있습니다'
    state_checkFail  = '검사 실패 - 로그를 확인하세요'
    state_running    = '게임을 먼저 종료하세요'
    state_installOk  = '설치 완료 - 게임에서 Insert 키를 누르세요'
    state_installBad = '설치했지만 검증에 실패했습니다'
    state_restoreOk  = '복원 완료'
    state_noBackup   = '백업이 없습니다'

    hdr1             = '드래곤즈 도그마 2 DLSS 5 설치기 - OptiScaler DLSS-NR 방식'
    hdr2             = '게임 3.2.0.0 / 드라이버 616.56 이상 / RTX 카드'
    blank            = ''
    autoFound        = '게임 자동 발견: {0}'
    gameFound        = '게임 발견: {0}'
    gameSet          = '게임 지정: {0}'
    autoFail         = '자동 탐지 실패 - [찾아보기] 로 DD2.exe 를 지정하세요'

    checkStart       = '--- 검사 시작 ---'
    checkEnd         = '--- 검사 끝 ---'
    noPath           = '[X] 게임 경로가 지정되지 않았습니다.'
    gameFolder       = '[O] 게임 폴더: {0}'
    verOk            = '[O] 게임 버전 {0}'
    verWarn          = '[!] 게임 버전 {0} - 이 설치기는 3.2.0.0 에서 검증됐습니다. 계속은 가능합니다.'
    gpuOk            = '[O] GPU: {0}'
    noGpu            = '[X] RTX GPU 를 찾지 못했습니다.'
    drvOk            = '[O] 드라이버 {0}'
    drvBad           = '[X] 드라이버 {0} - 616.56 이상이 필요합니다.'
    drvParse         = '[!] 드라이버 버전을 해석하지 못했습니다.'
    payMissing       = '[X] payload 누락: {0}'
    payDirMissing    = '[X] payload 누락: OptiScaler 폴더'
    iniWrong         = '[X] OptiScaler.ini 가 프로젝트 수정본이 아닙니다 (414 bytes 여야 합니다).'
    payOk            = '[O] payload 확인'
    conflict         = '[!] 충돌 파일 (설치 시 백업 후 제거): {0}'
    noConflict       = '[O] 충돌 파일 없음'

    gameRunning      = '[X] 게임이 실행 중입니다. 종료 후 다시 시도하세요.'
    backupHdr        = '--- 백업: {0}  (게임 폴더 밖) ---'
    backupItem       = '  백업 {0}'
    installHdr       = '--- 설치 ---'
    installItem      = '  {0}'
    iniSize          = '  OptiScaler.ini  {0} bytes'
    verifyHdr        = '--- 검증 ---'
    verifyOk         = '  [O] {0}'
    verifyBad        = '  [X] {0} 해시 불일치'
    backupPath       = '백업 위치: {0}'

    removeHdr        = '--- 제거 ---'
    removeItem       = '  삭제 {0}'
    restoreHdr       = '--- 복원: {0} ---'
    restoreItem      = '  {0}'
    noBackupFound    = '[X] 백업 폴더를 찾지 못했습니다.'
    noGamePath       = '[X] 게임 경로가 없습니다.'
    btnPrepare       = '0. 파일 받기'
    state_prepping   = '파일을 받는 중입니다. 잠시 기다리세요'
    state_prepOk     = '파일 준비 완료 - [1. 검사] 를 누르세요'
    state_prepFail   = '파일 받기 실패 - 로그를 확인하세요'
    state_needModel  = 'nvngx_dlssnr.dll 을 payload 폴더에 넣으세요'
    prepHdr          = '--- 파일 받기 ---'
    prepDl           = '  받는 중: {0}'
    prepDone         = '  완료: {0}  ({1} bytes)'
    prepFail         = '  [X] 실패: {0}'
    prepExtract      = '  압축 해제: {0}'
    prepSkip         = '  이미 있음: {0}'
    modelMissing     = '[X] nvngx_dlssnr.dll 이 payload 폴더에 없습니다.'
    modelHint        = '    이 파일은 NVIDIA 것이라 함께 배포하지 않습니다. 직접 구해서'
    modelHint2       = '    payload 폴더에 넣으세요. RTX 20~50 대응 310.8.SF 를 권장합니다.'
  }
  en = @{
    title            = "Dragon's Dogma 2 - DLSS 5 Installer"
    lang             = 'Language'
    lblPath          = 'Game folder'
    btnAuto          = 'Auto-detect'
    btnBrowse        = 'Browse'
    btnCheck         = '1. Check'
    btnInstall       = '2. Install'
    btnRestore       = 'Restore'
    dlgTitle         = 'Select DD2.exe'

    state_initial    = 'Press [Auto-detect] -> [0. Get files] -> [1. Check] -> [2. Install]'
    state_found      = 'Path found. Press [1. Check]'
    state_autoFail   = 'Auto-detect failed'
    state_needPath   = 'Set the game path first'
    state_checkPass  = 'Check passed - ready to install'
    state_checkFail  = 'Check failed - see the log'
    state_running    = 'Close the game first'
    state_installOk  = 'Installed - press Insert in game'
    state_installBad = 'Installed, but verification failed'
    state_restoreOk  = 'Restore complete'
    state_noBackup   = 'No backup found'

    hdr1             = "Dragon's Dogma 2 DLSS 5 installer - OptiScaler DLSS-NR method"
    hdr2             = 'Game 3.2.0.0 / driver 616.56 or newer / RTX card'
    blank            = ''
    autoFound        = 'Game found automatically: {0}'
    gameFound        = 'Game found: {0}'
    gameSet          = 'Game set: {0}'
    autoFail         = 'Auto-detect failed - use [Browse] to point at DD2.exe'

    checkStart       = '--- Check started ---'
    checkEnd         = '--- Check finished ---'
    noPath           = '[X] No game path has been set.'
    gameFolder       = '[O] Game folder: {0}'
    verOk            = '[O] Game version {0}'
    verWarn          = '[!] Game version {0} - this installer was verified on 3.2.0.0. You may continue.'
    gpuOk            = '[O] GPU: {0}'
    noGpu            = '[X] No RTX GPU found.'
    drvOk            = '[O] Driver {0}'
    drvBad           = '[X] Driver {0} - 616.56 or newer is required.'
    drvParse         = '[!] Could not parse the driver version.'
    payMissing       = '[X] Missing from payload: {0}'
    payDirMissing    = '[X] Missing from payload: OptiScaler folder'
    iniWrong         = '[X] OptiScaler.ini is not the project build (it must be 414 bytes).'
    payOk            = '[O] Payload verified'
    conflict         = '[!] Conflicting files (backed up and removed on install): {0}'
    noConflict       = '[O] No conflicting files'

    gameRunning      = '[X] The game is running. Close it and try again.'
    backupHdr        = '--- Backup: {0}  (outside the game folder) ---'
    backupItem       = '  backed up {0}'
    installHdr       = '--- Install ---'
    installItem      = '  {0}'
    iniSize          = '  OptiScaler.ini  {0} bytes'
    verifyHdr        = '--- Verify ---'
    verifyOk         = '  [O] {0}'
    verifyBad        = '  [X] {0} hash mismatch'
    backupPath       = 'Backup location: {0}'

    removeHdr        = '--- Remove ---'
    removeItem       = '  removed {0}'
    restoreHdr       = '--- Restore: {0} ---'
    restoreItem      = '  {0}'
    noBackupFound    = '[X] No backup folder found.'
    noGamePath       = '[X] No game path.'
    btnPrepare       = '0. Get files'
    state_prepping   = 'Downloading files, please wait'
    state_prepOk     = 'Files ready - press [1. Check]'
    state_prepFail   = 'Download failed - see the log'
    state_needModel  = 'Place nvngx_dlssnr.dll in the payload folder'
    prepHdr          = '--- Getting files ---'
    prepDl           = '  downloading: {0}'
    prepDone         = '  done: {0}  ({1} bytes)'
    prepFail         = '  [X] failed: {0}'
    prepExtract      = '  extracting: {0}'
    prepSkip         = '  already present: {0}'
    modelMissing     = '[X] nvngx_dlssnr.dll is not in the payload folder.'
    modelHint        = '    It is an NVIDIA file and is not redistributed here. Obtain it'
    modelHint2       = '    yourself and place it in payload\. 310.8.SF covers RTX 20-50.'
  }
}

function T([string]$key, [object[]]$a) {
  $s = $Script:S[$Script:Lang][$key]
  if ($null -eq $s) { return $key }
  if ($a -and $a.Count) { return ($s -f $a) }
  return $s
}

function Render-Log {
  if (-not $Script:txtLog) { return }
  $sb = New-Object System.Text.StringBuilder
  foreach ($e in $Script:Entries) {
    if ($e.k -eq 'blank') { [void]$sb.AppendLine('') }
    else { [void]$sb.AppendLine(('[{0}] {1}' -f $e.t, (T $e.k $e.a))) }
  }
  $Script:txtLog.Text = $sb.ToString()
  $Script:txtLog.SelectionStart = $Script:txtLog.Text.Length
  $Script:txtLog.ScrollToCaret()
}

function Log([string]$key, [object[]]$a) {
  [void]$Script:Entries.Add(@{ k = $key; a = $a; t = (Get-Date -Format 'HH:mm:ss') })
  Render-Log
}

function Say([string]$key, [object[]]$a, $col) {
  $Script:StateKey = $key
  $Script:StateArg = $a
  $Script:StateCol = $col
  if ($Script:lblState) { $Script:lblState.Text = (T $key $a); $Script:lblState.ForeColor = $col }
}

function Apply-Lang {
  $Script:form.Text      = T 'title'
  $Script:lblPath.Text   = T 'lblPath'
  $Script:lblLang.Text   = T 'lang'
  $Script:btnAuto.Text   = T 'btnAuto'
  $Script:btnBrowse.Text = T 'btnBrowse'
  $Script:btnPrepare.Text= T 'btnPrepare'
  $Script:btnCheck.Text  = T 'btnCheck'
  $Script:btnInstall.Text= T 'btnInstall'
  $Script:btnRestore.Text= T 'btnRestore'
  $Script:lblState.Text  = T $Script:StateKey $Script:StateArg
  $Script:lblState.ForeColor = $Script:StateCol
  Render-Log
}

# ---------------------------------------------------------------- logic
function Find-Game {
  $roots = @()
  foreach ($k in 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam', 'HKLM:\SOFTWARE\Valve\Steam') {
    try { $p = (Get-ItemProperty $k -ErrorAction Stop).InstallPath; if ($p) { $roots += $p } } catch {}
  }
  $libs = @()
  foreach ($r in $roots) {
    $vdf = Join-Path $r 'steamapps\libraryfolders.vdf'
    if (Test-Path $vdf) {
      foreach ($m in [regex]::Matches((Get-Content $vdf -Raw), '"path"\s+"([^"]+)"')) {
        $libs += ($m.Groups[1].Value -replace '\\\\', '\')
      }
    }
    $libs += $r
  }
  foreach ($l in ($libs | Select-Object -Unique)) {
    $c = Join-Path $l 'steamapps\common\Dragons Dogma 2\DD2.exe'
    if (Test-Path $c) { return (Split-Path -Parent $c) }
  }
  return ''
}

function Get-Payload {
  Say 'state_prepping' @() ([System.Drawing.Color]::Black)
  Log 'prepHdr'
  if (-not (Test-Path $Script:Payload)) { New-Item -ItemType Directory -Path $Script:Payload -Force | Out-Null }
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  $okAll = $true

  $optiUrl = 'https://github.com/Dagherbou/OptiScaler_DLSSNR/releases/download/v0.1.1.5-dlssnr/OptiScaler-DLSSNR-v0.1.1.5-dlssnr.zip'
  $need = @('dxgi.dll','nvngx.dll_dlssnr.dll') | Where-Object { -not (Test-Path (Join-Path $Script:Payload $_)) }
  if ($need -or -not (Test-Path (Join-Path $Script:Payload 'OptiScaler'))) {
    $zip = Join-Path $env:TEMP 'OptiScaler-DLSSNR.zip'
    $tmp = Join-Path $env:TEMP 'OptiScaler-DLSSNR-extract'
    try {
      Log 'prepDl' @('OptiScaler-DLSSNR-v0.1.1.5-dlssnr.zip')
      Invoke-WebRequest -Uri $optiUrl -OutFile $zip -UseBasicParsing
      Log 'prepDone' @('OptiScaler-DLSSNR.zip', (Get-Item $zip).Length)
      if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
      Log 'prepExtract' @('OptiScaler-DLSSNR.zip')
      Expand-Archive -Path $zip -DestinationPath $tmp -Force
      Copy-Item (Join-Path $tmp 'OptiScaler.dll')          (Join-Path $Script:Payload 'dxgi.dll') -Force
      Copy-Item (Join-Path $tmp 'nvngx.dll_dlssnr.dll')    (Join-Path $Script:Payload 'nvngx.dll_dlssnr.dll') -Force
      if (Test-Path (Join-Path $Script:Payload 'OptiScaler')) { Remove-Item (Join-Path $Script:Payload 'OptiScaler') -Recurse -Force }
      Copy-Item (Join-Path $tmp 'OptiScaler') (Join-Path $Script:Payload 'OptiScaler') -Recurse -Force
      Remove-Item $zip, $tmp -Recurse -Force -ErrorAction SilentlyContinue
    } catch { Log 'prepFail' @('OptiScaler'); $okAll = $false }
  }
  else { Log 'prepSkip' @('OptiScaler') }

  $base = 'https://raw.githubusercontent.com/dmitrysobolev/DD2-DLSS5/main/GameFiles/'
  foreach ($n in 'dinput8.dll', 'OptiScaler.ini') {
    $dst = Join-Path $Script:Payload $n
    if (Test-Path $dst) { Log 'prepSkip' @($n); continue }
    try {
      Log 'prepDl' @($n)
      Invoke-WebRequest -Uri ($base + $n) -OutFile $dst -UseBasicParsing
      Log 'prepDone' @($n, (Get-Item $dst).Length)
    } catch { Log 'prepFail' @($n); $okAll = $false }
  }

  if (-not (Test-Path (Join-Path $Script:Payload 'nvngx_dlssnr.dll'))) {
    Log 'modelMissing'; Log 'modelHint'; Log 'modelHint2'
    Say 'state_needModel' @() ([System.Drawing.Color]::Firebrick)
    return
  }
  if ($okAll) { Say 'state_prepOk' @() ([System.Drawing.Color]::SeaGreen) }
  else { Say 'state_prepFail' @() ([System.Drawing.Color]::Firebrick) }
}

function Run-Check {
  $ok = $true
  Log 'checkStart'

  if (-not $Script:Game -or -not (Test-Path (Join-Path $Script:Game 'DD2.exe'))) {
    Log 'noPath'
    Say 'state_needPath' @() ([System.Drawing.Color]::Firebrick)
    return $false
  }
  Log 'gameFolder' @($Script:Game)

  $v = (Get-Item (Join-Path $Script:Game 'DD2.exe')).VersionInfo.FileVersion
  if ($v -eq '3.2.0.0') { Log 'verOk' @($v) } else { Log 'verWarn' @($v) }

  $gpu = Get-CimInstance Win32_VideoController | Where-Object { $_.Name -match 'RTX' } | Select-Object -First 1
  if ($gpu) {
    Log 'gpuOk' @($gpu.Name)
    $d = $gpu.DriverVersion -replace '\.', ''
    try {
      $num = [double]('{0}.{1}' -f $d.Substring($d.Length - 5, 3), $d.Substring($d.Length - 2, 2))
      if ($num -ge 616.56) { Log 'drvOk' @($num) } else { Log 'drvBad' @($num); $ok = $false }
    } catch { Log 'drvParse' }
  }
  else { Log 'noGpu'; $ok = $false }

  foreach ($n in 'dxgi.dll', 'dinput8.dll', 'nvngx_dlssnr.dll', 'nvngx.dll_dlssnr.dll', 'OptiScaler.ini') {
    if (-not (Test-Path (Join-Path $Script:Payload $n))) { Log 'payMissing' @($n); $ok = $false }
  }
  if (-not (Test-Path (Join-Path $Script:Payload 'OptiScaler'))) { Log 'payDirMissing'; $ok = $false }

  $ini = Join-Path $Script:Payload 'OptiScaler.ini'
  if ((Test-Path $ini) -and ((Get-Item $ini).Length -gt 2000)) { Log 'iniWrong'; $ok = $false }
  if ($ok) { Log 'payOk' }

  $conf = @()
  $gx = Join-Path $Script:Game 'dxgi.dll'
  if (Test-Path $gx) {
    if ((Get-Item $gx).VersionInfo.ProductName -match 'ReShade') { $conf += 'ReShade dxgi.dll' }
  }
  foreach ($n in 'ReShade.ini', 'ReShade.log', 'ReShadePreset.ini', 'reshade-shaders', 'd3d12.dll', 'OptiScaler.asi') {
    if (Test-Path (Join-Path $Script:Game $n)) { $conf += $n }
  }
  foreach ($a in (Get-ChildItem $Script:Game -Filter '*.addon64' -ErrorAction SilentlyContinue)) { $conf += $a.Name }
  if ($conf.Count) { Log 'conflict' @(($conf -join ', ')) } else { Log 'noConflict' }

  if ($ok) { Say 'state_checkPass' @() ([System.Drawing.Color]::SeaGreen) }
  else { Say 'state_checkFail' @() ([System.Drawing.Color]::Firebrick) }
  Log 'checkEnd'
  return $ok
}

function Run-Install {
  if (Get-Process DD2 -ErrorAction SilentlyContinue) {
    Log 'gameRunning'
    Say 'state_running' @() ([System.Drawing.Color]::Firebrick)
    return
  }
  if (-not (Run-Check)) { return }

  $bk = Join-Path ([Environment]::GetFolderPath('Desktop')) ('DD2-DLSS5-backup_' + (Get-Date -Format 'yyyyMMdd_HHmmss'))
  New-Item -ItemType Directory -Path $bk -Force | Out-Null
  Log 'backupHdr' @($bk)

  foreach ($n in 'dxgi.dll', 'd3d12.dll', 'ReShade.ini', 'ReShade.log', 'ReShade.log.prev', 'ReShadePreset.ini', 'OptiScaler.asi', 'OptiScaler.ini', 'dinput8.dll', 'nvngx_dlssnr.dll', 'nvngx.dll_dlssnr.dll') {
    $s = Join-Path $Script:Game $n
    if (Test-Path $s) { Move-Item $s (Join-Path $bk $n) -Force -ErrorAction SilentlyContinue; Log 'backupItem' @($n) }
  }
  foreach ($d in 'reshade-shaders', 'OptiScaler') {
    $s = Join-Path $Script:Game $d
    if (Test-Path $s) { Move-Item $s (Join-Path $bk $d) -Force -ErrorAction SilentlyContinue; Log 'backupItem' @(($d + '\')) }
  }
  foreach ($a in (Get-ChildItem $Script:Game -Filter '*.addon64' -ErrorAction SilentlyContinue)) {
    Move-Item $a.FullName (Join-Path $bk $a.Name) -Force -ErrorAction SilentlyContinue
    Log 'backupItem' @($a.Name)
  }

  Log 'installHdr'
  foreach ($n in 'dxgi.dll', 'dinput8.dll', 'nvngx_dlssnr.dll', 'nvngx.dll_dlssnr.dll') {
    Copy-Item (Join-Path $Script:Payload $n) (Join-Path $Script:Game $n) -Force
    Log 'installItem' @($n)
  }
  Copy-Item (Join-Path $Script:Payload 'OptiScaler') (Join-Path $Script:Game 'OptiScaler') -Recurse -Force
  Log 'installItem' @('OptiScaler\')
  Copy-Item (Join-Path $Script:Payload 'OptiScaler.ini') (Join-Path $Script:Game 'OptiScaler.ini') -Force
  Log 'iniSize' @((Get-Item (Join-Path $Script:Game 'OptiScaler.ini')).Length)

  Log 'verifyHdr'
  $bad = 0
  foreach ($n in 'dxgi.dll', 'dinput8.dll', 'nvngx_dlssnr.dll', 'nvngx.dll_dlssnr.dll', 'OptiScaler.ini') {
    $h1 = (Get-FileHash (Join-Path $Script:Payload $n) -Algorithm SHA256).Hash
    $h2 = (Get-FileHash (Join-Path $Script:Game $n) -Algorithm SHA256).Hash
    if ($h1 -eq $h2) { Log 'verifyOk' @($n) } else { Log 'verifyBad' @($n); $bad++ }
  }
  if ($bad) { Say 'state_installBad' @() ([System.Drawing.Color]::Firebrick) }
  else { Say 'state_installOk' @() ([System.Drawing.Color]::SeaGreen) }
  Log 'backupPath' @($bk)
}

function Run-Restore {
  if (Get-Process DD2 -ErrorAction SilentlyContinue) { Log 'gameRunning'; Say 'state_running' @() ([System.Drawing.Color]::Firebrick); return }
  if (-not $Script:Game) { Log 'noGamePath'; return }

  $desk = [Environment]::GetFolderPath('Desktop')
  $bk = Get-ChildItem $desk -Directory -Filter 'DD2-DLSS5-backup_*' -ErrorAction SilentlyContinue |
        Sort-Object Name | Select-Object -Last 1
  if (-not $bk) { Log 'noBackupFound'; Say 'state_noBackup' @() ([System.Drawing.Color]::Firebrick); return }

  Log 'removeHdr'
  foreach ($n in 'dxgi.dll', 'dinput8.dll', 'nvngx_dlssnr.dll', 'nvngx.dll_dlssnr.dll', 'OptiScaler.ini', 'OptiScaler.log') {
    $t = Join-Path $Script:Game $n
    if (Test-Path $t) { Remove-Item $t -Force -ErrorAction SilentlyContinue; Log 'removeItem' @($n) }
  }
  $od = Join-Path $Script:Game 'OptiScaler'
  if (Test-Path $od) { Remove-Item $od -Recurse -Force -ErrorAction SilentlyContinue; Log 'removeItem' @('OptiScaler\') }

  Log 'restoreHdr' @($bk.Name)
  foreach ($i in (Get-ChildItem $bk.FullName)) {
    Copy-Item $i.FullName (Join-Path $Script:Game $i.Name) -Recurse -Force -ErrorAction SilentlyContinue
    Log 'restoreItem' @($i.Name)
  }
  Say 'state_restoreOk' @() ([System.Drawing.Color]::SeaGreen)
}

# ---------------------------------------------------------------- UI
$form = New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(770, 630)
$form.StartPosition = 'CenterScreen'
$form.Font = New-Object System.Drawing.Font('Malgun Gothic', 9)
$Script:form = $form

$lblPath = New-Object System.Windows.Forms.Label
$lblPath.Location = New-Object System.Drawing.Point(14, 16)
$lblPath.AutoSize = $true
$form.Controls.Add($lblPath); $Script:lblPath = $lblPath

$lblLang = New-Object System.Windows.Forms.Label
$lblLang.Location = New-Object System.Drawing.Point(566, 14)
$lblLang.Size = New-Object System.Drawing.Size(70, 20)
$lblLang.TextAlign = 'MiddleRight'
$form.Controls.Add($lblLang); $Script:lblLang = $lblLang

$cboLang = New-Object System.Windows.Forms.ComboBox
$cboLang.Location = New-Object System.Drawing.Point(640, 12)
$cboLang.Size = New-Object System.Drawing.Size(106, 24)
$cboLang.DropDownStyle = 'DropDownList'
[void]$cboLang.Items.Add('한국어')
[void]$cboLang.Items.Add('English')
$cboLang.SelectedIndex = $(if ($Script:Lang -eq 'ko') { 0 } else { 1 })
$form.Controls.Add($cboLang)

$txtPath = New-Object System.Windows.Forms.TextBox
$txtPath.Location = New-Object System.Drawing.Point(14, 38)
$txtPath.Size = New-Object System.Drawing.Size(560, 24)
$txtPath.ReadOnly = $true
$form.Controls.Add($txtPath)

$btnAuto = New-Object System.Windows.Forms.Button
$btnAuto.Location = New-Object System.Drawing.Point(584, 36)
$btnAuto.Size = New-Object System.Drawing.Size(78, 27)
$form.Controls.Add($btnAuto); $Script:btnAuto = $btnAuto

$btnBrowse = New-Object System.Windows.Forms.Button
$btnBrowse.Location = New-Object System.Drawing.Point(668, 36)
$btnBrowse.Size = New-Object System.Drawing.Size(78, 27)
$form.Controls.Add($btnBrowse); $Script:btnBrowse = $btnBrowse

$btnPrepare = New-Object System.Windows.Forms.Button
$btnPrepare.Location = New-Object System.Drawing.Point(14, 76)
$btnPrepare.Size = New-Object System.Drawing.Size(150, 34)
$form.Controls.Add($btnPrepare); $Script:btnPrepare = $btnPrepare

$btnCheck = New-Object System.Windows.Forms.Button
$btnCheck.Location = New-Object System.Drawing.Point(174, 76)
$btnCheck.Size = New-Object System.Drawing.Size(150, 34)
$form.Controls.Add($btnCheck); $Script:btnCheck = $btnCheck

$btnInstall = New-Object System.Windows.Forms.Button
$btnInstall.Location = New-Object System.Drawing.Point(334, 76)
$btnInstall.Size = New-Object System.Drawing.Size(150, 34)
$form.Controls.Add($btnInstall); $Script:btnInstall = $btnInstall

$btnRestore = New-Object System.Windows.Forms.Button
$btnRestore.Location = New-Object System.Drawing.Point(494, 76)
$btnRestore.Size = New-Object System.Drawing.Size(110, 34)
$form.Controls.Add($btnRestore); $Script:btnRestore = $btnRestore

$lblState = New-Object System.Windows.Forms.Label
$lblState.Location = New-Object System.Drawing.Point(14, 120)
$lblState.Size = New-Object System.Drawing.Size(736, 22)
$form.Controls.Add($lblState); $Script:lblState = $lblState

$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Location = New-Object System.Drawing.Point(14, 150)
$txtLog.Size = New-Object System.Drawing.Size(736, 420)
$txtLog.Multiline = $true
$txtLog.ScrollBars = 'Vertical'
$txtLog.ReadOnly = $true
$txtLog.Font = New-Object System.Drawing.Font('Consolas', 9)
$form.Controls.Add($txtLog); $Script:txtLog = $txtLog

$cboLang.Add_SelectedIndexChanged({
  $Script:Lang = $(if ($cboLang.SelectedIndex -eq 0) { 'ko' } else { 'en' })
  Apply-Lang
})

$btnAuto.Add_Click({
  $g = Find-Game
  if ($g) {
    $Script:Game = $g; $txtPath.Text = $g
    Log 'gameFound' @($g)
    Say 'state_found' @() ([System.Drawing.Color]::Black)
  }
  else {
    Log 'autoFail'
    Say 'state_autoFail' @() ([System.Drawing.Color]::Firebrick)
  }
})

$btnBrowse.Add_Click({
  $d = New-Object System.Windows.Forms.OpenFileDialog
  $d.Filter = 'DD2.exe|DD2.exe'
  $d.Title = (T 'dlgTitle')
  if ($d.ShowDialog() -eq 'OK') {
    $Script:Game = Split-Path -Parent $d.FileName
    $txtPath.Text = $Script:Game
    Log 'gameSet' @($Script:Game)
  }
})

$btnPrepare.Add_Click({ Get-Payload })
$btnCheck.Add_Click({ [void](Run-Check) })
$btnInstall.Add_Click({ Run-Install })
$btnRestore.Add_Click({ Run-Restore })

Log 'hdr1'
Log 'hdr2'
Log 'blank'
$g0 = Find-Game
if ($g0) { $Script:Game = $g0; $txtPath.Text = $g0; Log 'autoFound' @($g0) }

Apply-Lang
[void]$form.ShowDialog()
