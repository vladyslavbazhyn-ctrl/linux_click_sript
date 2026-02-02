$LogFile = "$HOME\Desktop\agent_log.txt"
$SleepTime = 10 # milliseconds

# --- 1. THE BRIDGE TO C# ---
# Windows requires us to compile a tiny C# program on the fly to read input.
# We are importing the function 'GetAsyncKeyState' from User32.dll
$signature = @'
[DllImport("user32.dll")]
public static extern short GetAsyncKeyState(int vKey);
'@

# This command compiles the C# code into memory so PowerShell can use it.
$API = Add-Type -MemberDefinition $signature -Name "Win32" -Namespace Win32Functions -PassThru

# --- SETUP ---
Write-Host "--- WINDOWS CLICK COUNTER ---"
Write-Host "Press 'Ctrl+C' to stop."
Write-Host "Waiting for clicks..."

$Counter = 0
$LeftMousButton = 0x01

while ($true) {
	$isPressed = $API::GetAsyncKeyState($LeftMouseButton) -band 0x8000
	if ($isPressed) {
		$Counter++
		Write-Host -NoNewline "`rTotal Clicks: $Counter"
		while ($API::GetAsyncKeyState($LeftMouseButton) -band 0x8000) {
		Start-Sleep -Milliseconds 10
		}
	}
	
	Start-Sleep -Milliseconds $SleepInterval
}

