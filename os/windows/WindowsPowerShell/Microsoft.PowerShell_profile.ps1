# Console ModeをEmacs Modeに変更
Set-PSReadLineOption -EditMode Emacs

# 出力/入力を UTF-8 に
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
[Console]::InputEncoding  = [System.Text.UTF8Encoding]::new($false)

# editを個人用のvimと同じように開く設定
Set-Alias n edit

Set-Alias unzip Expand-Archive

# 親ディレクトリへ
function .. { Set-Location .. }

# 2階層上へ
function ... { Set-Location ../.. }

# 3階層上へ
function .... { Set-Location ../../.. }

function teams() {
    Start-Process "ms-teams.exe"
}

# フsァイル名のみ
function lf() {
    param([string]$Path = ".")
    Get-ChildItem -Force -Path $Path | Select-Object -Property Name
}

# 詳細表示
function l() {
    param([string]$Path = ".")
    dir
}


# 詳細表示
function ll() {
    param([string]$Path = ".")
    Get-ChildItem -Force -Path $Path | Format-Table Mode, LastWriteTime, Length, Name
}

function touch() {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    if (-Not (Test-Path $Path)) {
        New-Item -ItemType File -Path $Path | Out-Null
    } else {
        (Get-Item $Path).LastWriteTime = Get-Date
    }
}

function tree() {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$Path = ".",

        # 内部利用（先頭の余白/罫線）
        [string]$Prefix = "",

        # 隠し/システムも含める
        [switch]$Force
    )

    # 罫線文字（コードポイントから生成：ファイルの文字コードに依存しない）
    $PIPE       = [char]0x2502  # │
    $TEE        = [char]0x251C  # ├
    $ELBOW      = [char]0x2514  # └
    $HLINE      = [char]0x2500  # ─

    # 便利な組み合わせ
    $TEE3   = "$TEE$HLINE$HLINE "
    $ELBOW3 = "$ELBOW$HLINE$HLINE "

    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Error "Path not found: $Path"
        return
    }

    # 出力をUTF-8（念のため）
    try {
        [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
        [Console]::InputEncoding  = [System.Text.UTF8Encoding]::new($false)
    } catch {}

    # 子要素（ディレクトリを先、次にファイル）
    $items = Get-ChildItem -LiteralPath $Path -Force:$Force -ErrorAction SilentlyContinue |
             Sort-Object @{ Expression = { -not $_.PSIsContainer } }, Name

    $result = New-Object System.Collections.Generic.List[string]

    for ($i = 0; $i -lt $items.Count; $i++) {
        $item   = $items[$i]
        $isLast = ($i -eq $items.Count - 1)

        # └── or ├──
        $connector = if ($isLast) { $ELBOW3 } else { $TEE3 }
        $result.Add("$Prefix$connector$($item.Name)")

        # ディレクトリなら再帰
        if ($item.PSIsContainer) {
            # 継続罫線：最下段なら空白4つ、途中なら │ + 空白3
            $newPrefix = if ($isLast) { "$Prefix    " } else { "$Prefix$PIPE   " }
            $sub = tree -Path $item.FullName -Prefix $newPrefix -Force:$Force
            foreach ($line in $sub) { $result.Add($line) }
        }
    }

    return ,$result.ToArray()
}

function treec() {Set-Clipboard (tree | Out-String)}

function catc() {
     param(
        [string]$FilePath
    )
    Get-Content $FilePath -Encoding UTF8 | Set-Clipboard
}

function edge() {
    [CmdletBinding(DefaultParameterSetName='None')]
    param(
        [Parameter(ParameterSetName='Url', Mandatory=$true)]
        [Alias('u')]
        [string]$Url,

        [Parameter(ParameterSetName='Search', Mandatory=$true)]
        [Alias('q','s')]
        [string]$Query,

        [Parameter(ParameterSetName='File', Mandatory=$true)]
        [Alias('f')]
        [string]$File,

        [Parameter(ParameterSetName='None')]
        [Alias('p')]
        [switch]$Private
    )

    $edgeArgs = @()
    if ($Private) { $edgeArgs += "--inprivate" }

    switch ($PSCmdlet.ParameterSetName) {
        'Url' {
            if ([string]::IsNullOrWhiteSpace($Url)) {
                Write-Host "Error: URL value is required." -ForegroundColor Red
                return
            }
            $edgeArgs += $Url
        }
        'Search' {
            if ([string]::IsNullOrWhiteSpace($Query)) {
                Write-Host "Error: Search query is required." -ForegroundColor Red
                return
            }
            $searchUrl = "https://www.bing.com/search?q=" + [uri]::EscapeDataString($Query)
            $edgeArgs += $searchUrl
        }
        'File' {
            if ([string]::IsNullOrWhiteSpace($File)) {
                Write-Host "Error: File path is required." -ForegroundColor Red
                return
            }
            if (Test-Path $File) {
                $absolutePath = (Resolve-Path $File).Path
                $uri = "file:///$absolutePath"
                $edgeArgs += $uri
            } else {
                Write-Host "Error: File '$File' not found." -ForegroundColor Red
                return
            }
        }
    }

    # Edge起動
    if ($edgeArgs.Count -gt 0) {
        Start-Process "msedge.exe" -ArgumentList $edgeArgs
    } else {
        Start-Process "msedge.exe"
    }
}

# ホーム配下のパスを ~ に短縮して返す（表示用）
function ShortHomePath {
    param([Parameter(Mandatory)][string]$Path)
    return ($Path -replace [regex]::Escape($HOME), '~')
}


# pwdc        → ~\Projects\App をコピー
# pwdc -Full  → C:\Users\mizutani\Projects\App をコピー
function pwdc() {
 [CmdletBinding()]
    param(
        [switch]$Full
    )
    # 現在位置（フルパス）
    $path = $pwd.Path

    # 表示用短縮
    $out = if ($Full) { $path } else { ShortHomePath -Path $path }

    Set-Clipboard -Value $out

    # フィードバック（画面にも短縮で見せる）
    Write-Host "Copied: $out" -ForegroundColor Cyan
}

function findr() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$SearchDir,
        [Parameter(Mandatory=$true)]
        [string]$Keyword,
        [switch]$CaseSensitive,
        [switch]$IncludeHidden,
        [switch]$PassThru   # ← 戻り値が必要なときだけ付ける
    )

    # 検索ルートの解決（~や相対もOK）
    try {
        $resolvedRoot = (Resolve-Path -LiteralPath $SearchDir).ProviderPath
    } catch {
        Write-Host "SearchDir not found: $SearchDir" -ForegroundColor Red
        return
    }

    # マッチ用Regex（-CaseSensitive対応）
    $regexOptions = if ($CaseSensitive) { 'None' } else { 'IgnoreCase' }
    $regex = New-Object System.Text.RegularExpressions.Regex($Keyword, [System.Text.RegularExpressions.RegexOptions]::$regexOptions)

    # コレクション（フルパスで保持）
    [System.Collections.ArrayList]$dirs = @()
    [System.Collections.ArrayList]$files = @()

    # ルートディレクトリ自身
    $leaf = Split-Path -Leaf $resolvedRoot
    if ($regex.IsMatch($leaf)) { [void]$dirs.Add($resolvedRoot) }

    # 列挙パラメータ
    $gciParams = @{
        Path        = $resolvedRoot
        Recurse     = $true
        ErrorAction = 'SilentlyContinue'
        Force       = [bool]$IncludeHidden
    }

    # 進捗用に一度全件取得（分母が不要なら逐次処理に変えても良い）
    $items = Get-ChildItem @gciParams
    $total = $items.Count
    $count = 0

    foreach ($item in $items) {
        $count++

        # 進捗（短縮表示）
        $short = ShortHomePath -Path $item.FullName
        $msg = "Searching ($count/$total): $short"

        # コンソール幅に合わせて省略
        $width = $Host.UI.RawUI.WindowSize.Width
        if ($msg.Length -ge $width) {
            $keep = [Math]::Max(10, $width - 10)
            $msg = $msg.Substring(0, $keep) + "…"
        }
        Write-Host "`r$msg" -NoNewline

        # 判定（名前のみ）
        if ($item.PSIsContainer) {
            if ($regex.IsMatch($item.Name)) { [void]$dirs.Add($item.FullName) }
        } else {
            if ($regex.IsMatch($item.Name)) { [void]$files.Add($item.FullName) }
        }
    }

    # 進捗行を確実に改行してクリア
    Write-Host ""

    # 見出し（新しい行から）
    Write-Host ("`nFound items containing '{0}':" -f $Keyword) -ForegroundColor Green

    # ディレクトリ表示
    Write-Host "`nDirectory:"
    if ($dirs.Count -gt 0) {
        for ($i = 0; $i -lt $dirs.Count; $i++) {
            $short = ShortHomePath -Path $dirs[$i]
            Write-Host ("  {0}. {1}" -f ($i+1), $short)
        }
    } else {
        Write-Host "  No directories found"
    }

    # ファイル表示
    Write-Host "`nFile:"
    if ($files.Count -gt 0) {
        for ($j = 0; $j -lt $files.Count; $j++) {
            $short = ShortHomePath -Path $files[$j]
            Write-Host ("  {0}. {1}" -f ($j+1), $short)
        }
    } else {
        Write-Host "  No files found"
    }

    if ($PassThru) {
        return [PSCustomObject]@{
            Directories = $dirs.ToArray()
            Files       = $files.ToArray()
            CountDirs   = $dirs.Count
            CountFiles  = $files.Count
        }
    }
}

function memo {
    $path = Join-Path $HOME "Documents\memo.txt"
    $today = Get-Date -Format 'yyyy.MM.dd'

    # 検索パターン（"# yyyy.MM.dd"）
    $pattern = "^#\s+$([regex]::Escape($today))$"

    # ファイル末尾から1000行を読み、今日の見出しがあるか確認
    $tail = Get-Content -Path $path -Tail 1000
    $exists = $tail -match $pattern

    if (-not $exists) {
        $template = @"

---

# $today
"@
        Add-Content -Path $path -Value $template -Encoding UTF8
    }

    edit $path
}

# ================================
# Win32: SetForegroundWindow — 既存型がなければ追加（重複回避）
# ================================
if (-not ('ElInterop.Native.User32' -as [type])) {
Add-Type -Language CSharp -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

namespace ElInterop.Native {
  public static class User32 {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
  }
}
"@
}

# ==============
# Explorer ユーティリティ
# ==============
function Get-ExplorerWindows {
    $shell = New-Object -ComObject Shell.Application
    @(
        $shell.Windows() |
        Where-Object {
            $_.Document -and $_.Document.Folder -and ($_.FullName -match 'explorer\.exe$')
        }
    )
}

function Ensure-Foreground([IntPtr]$Hwnd) {
    try { [ElInterop.Native.User32]::SetForegroundWindow($Hwnd) | Out-Null } catch {}
}

# --- 既存再利用（仮想デスクトップの考慮なし） ---
function Move-ExplorerTo {
    <#
      .SYNOPSIS
        既存の Explorer を再利用して指定フォルダへ移動。
        既存が無ければ新規で開く。
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Path)

    # パス正規化（存在チェック）
    try { $Path = (Resolve-Path -LiteralPath $Path).Path }
    catch { throw "Path not found: $Path" }

    $wins = Get-ExplorerWindows

    # 最後（アクティブっぽい）ウィンドウを選択
    $win = $wins | Select-Object -Last 1

    if ($win) {
        Ensure-Foreground -Hwnd ([IntPtr]$win.HWND)
        # 既存ウィンドウのアクティブタブを目的パスへ遷移
        $win.Navigate($Path)
    } else {
        # 既存が無ければ新規で開く
        Start-Process explorer.exe -ArgumentList "`"$Path`""
    }
}

# --- 新規タブ（貼り付け方式：URL誤認対策＋検証＋フォールバック） ---
function Open-ExplorerInNewTab {
    <#
      .SYNOPSIS
        既存の Explorer の「新規タブ」で指定フォルダを開く（擬似操作）。
      .NOTES
        Explorer のタブを直接開く公開APIはないため、SendKeysベースのワークアラウンド。
        クリップボード貼り付け（Ctrl+L→Ctrl+V→Enter）で URL 誤認を抑制。
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Path)

    # 引用符除去 → 正規化
    $Path = $Path.Trim('"')
    try { $Path = (Resolve-Path -LiteralPath $Path).Path }
    catch { throw "Path not found: $Path" }

    $wins = Get-ExplorerWindows
    if (-not $wins) {
        Start-Process explorer.exe
        Start-Sleep -Milliseconds 600
        $wins = Get-ExplorerWindows
    }

    $win = $wins | Select-Object -Last 1
    if (-not $win) { throw "Explorer window not found." }

    Ensure-Foreground -Hwnd ([IntPtr]$win.HWND)
    Start-Sleep -Milliseconds 200

    # クリップボードへ正規化済みパスを設定し、貼り付けで確定
    Set-Clipboard -Value $Path
    $wshell = New-Object -ComObject WScript.Shell
    $wshell.SendKeys('^{t}')       # 新規タブ
    Start-Sleep -Milliseconds 180
    $wshell.SendKeys('^{l}')       # アドレスバー選択（Ctrl+L が安定しやすい）
    Start-Sleep -Milliseconds 180
    $wshell.SendKeys('^v{ENTER}')  # 貼り付け → Enter

    # 遷移検証（失敗なら新規ウィンドウでフォールバック）
    Start-Sleep -Milliseconds 350
    $ok = $false
    try {
        $cur = $win.Document.Folder.Self.Path
        if ($cur -and ($cur -eq $Path)) { $ok = $true }
    } catch { $ok = $false }

    if (-not $ok) {
        Start-Process explorer.exe -ArgumentList "`"$Path`""
    }
}

# --- 置き換え版 el(): -NewTab/-n でタブ指定 ---
function el {
    param(
      [string]$Path = ".",
      [Alias('n','NewTab')]
      [switch]$OpenInNewTab
    )

    if ($OpenInNewTab) {
        Open-ExplorerInNewTab -Path $Path
    } else {
        Move-ExplorerTo -Path $Path
    }
}




# コマンドラインをカラフルに（ホームを ~ に短縮）
function prompt {
    # 現在のパスを取得して、ホーム配下なら ~ に短縮
    $here = ShortHomePath -Path $pwd.Path

    # パス部分をマゼンタで表示（末尾改行あり）
    Write-Host "$here " -ForegroundColor Magenta

    # プロンプト記号を緑で表示（末尾改行なし）
    Write-Host "$" -ForegroundColor Green -NoNewline

    # PowerShellのpromptは「返した文字列がそのまま表示の末尾」に付く
    # ここではスペース1個だけ返して見た目を整える
    return " "
}

