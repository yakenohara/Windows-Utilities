<# License>------------------------------------------------------------

 Copyright (c) 2020 Shinnosuke Yakenohara

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>

-----------------------------------------------------------</License #>

$str_inDirName = 'like-repositories'
$str_outDirName = 'Utilities'

#変換対象ファイル拡張子
$extCandidates = @(
    ".bat",
    ".ps1",
    ".vbs",
    ".sh"
)

$pauseWhenErr = $TRUE  #エラーがあった場合にpauseするかどうか

# <コピー先ディレクトリがすでに存在する場合は削除>-----------------
if (Test-Path $str_outDirName -PathType Container) {
    Remove-Item -Path $str_outDirName -Force -Recurse
}
New-Item -Path $str_outDirName -ItemType Directory | Out-Null
# ----------------</コピー先ディレクトリがすでに存在する場合は削除>


#処理対象リスト作成
$list = New-Object System.Collections.Generic.List[System.String]

Get-ChildItem  -Recurse -Force -Path $str_inDirName | ForEach-Object {
    $list.Add($_.FullName)
}

#変数宣言
$int_numOfScceeded = 0
$int_numOfFailed = 0

#変換ループ
foreach ($path in $list) {

    $str_resultOne = ""

    if (Test-Path $path -PathType leaf) { #ファイルの場合
        
        $nowExt = [System.IO.Path]::GetExtension($path) #拡張子文字列を取得
        
        $bool_haveToCopy = $FALSE # コピー必要かどうか
        
        # 対象拡張子かどうかチェック
        foreach ($extCandidate in $extCandidates) {
            if ($extCandidate -eq $nowExt) { # 対象拡張子の時
                $bool_haveToCopy = $TRUE # `コピーする` を設定
                break
            }
        }
        
        if ($bool_haveToCopy) { # コピーする場合
            
            $str_destPath = "${str_outDirName}\" + [System.IO.Path]::GetFileName($path)

            Write-Host $str_destPath
            if (Test-Path $str_destPath -PathType leaf) { #すでに存在する場合
                Write-Error "``${str_destPath}`` is already exist."
                $str_resultOne = "[Failed to copy]"
                $int_numOfFailed++

            }else{
                try{
                    Copy-Item -LiteralPath $path -Destination $str_destPath
                    $str_resultOne = "[COPIED]"
                    $int_numOfScceeded++
                    
                } catch { #変換失敗の場合
                    Write-Error $error[0]
                    $str_resultOne = "[Failed to copy]"
                    $int_numOfFailed++
                    
                }
            }
        } else { # `コピーしない` の場合
            $str_resultOne = "[passed]" # todo
            
        }

        Write-Host ($str_resultOne + " " + $path)
    
    } else { #ファイルではない場合
        # nothing to do
    }
}

Write-Host ""
Write-Host "Number of [COPIED]"
Write-Host $int_numOfScceeded
Write-Host "Number of [Failed to copy]"
Write-Host $int_numOfFailed

#失敗か警告がある場合はpauseする
if ((($excluded -gt 0 ) -Or ($int_numOfFailed -gt 0 )) -And ($pauseWhenErr)){
    Write-Host ""
    Read-Host "Press Enter key to continue..."
    
}
