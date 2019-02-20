##2019.1.15,disable SAPIEN FW
#by kukisama 
Function Set-PSStudioFW
{
	param (
		[Parameter(Mandatory = $true)]
		[ValidateSet("New", "Update", "Remove")]
		$Type
	)
	$RuleSet = $null
	$RuleSet = New-Object System.Collections.ArrayList
	$x = Get-WmiObject win32_product -Filter "vendor like '%SAPIEN%'"
	$x.InstallLocation | %{
		$Softinfo = ls $_ *.exe | ?{ $_.VersionInfo.CompanyName -match "SAPIEN" }
		$Softinfo | %{ $RuleSet += @{ ("PS Studio " + $_.name) = $_.fullname } }
	}
	#$RuleSet 
	Switch ($Type)
	{
		"New" { New-Rule }
		"Update"{ Update-Rule }
		"Remove"{ Remove-Rule }
	}
}

Function New-Rule
{
	$RuleSet | foreach{
		New-NetFirewallRule -DisplayName $_.keys -Program $_.values -Action Block -Profile Any -Enabled True -Direction Outbound -EdgeTraversalPolicy Block -LooseSourceMapping $false -LocalOnlyMapping $false | out-null
	}
	
}
Function Remove-Rule
{
	Get-NetFirewallRule -DisplayName "PS Studio *" | Remove-NetFirewallRule
}
Function Update-Rule
{
	Remove-Rule
	New-Rule
}