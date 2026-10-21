cls
# encodes all *.ps1 files in a folder
# udela *.bat ke vsem souborum v adresari

# $files = Get-ChildItem -path $pwd -filter "*.ps1" # puvodni
$files = Get-ChildItem -file *.ps1 -Exclude enc_ps1_base64.ps1 # sam sebe nebere
echo $files
sleep 2

foreach($file in $files) { 
write-output "Encoding $file"
$code = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes((Get-Content $file | %{$_}|out-string)))
Write-Output $code
echo "----------------------------------------------------------------------------"
$bat = "powershell -encodedcommand $code"
$base = [io.path]::GetFileNameWithoutExtension("$file")
$batfile = $base + ".bat"
$bat | set-content $batfile
}

sleep 2

