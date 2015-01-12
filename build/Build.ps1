Import-Module "$PSScriptRoot\modules\msbuild\Invoke-MsBuild.psm1"

$nuget = "$PSScriptRoot\nuget\nuget.exe"

properties {
	$solutionDir = Resolve-Path "$PSScriptRoot\.."
	$build = "0"
}

task default -depends Package

task Package -depends Compile, Clean { 
	#& $nuget pack 
}

task Compile -depends Version, Clean { 
	Write-Host "Version: $Version"
	$solutionPath = "$solutionDir\Enexure.Fire.Data.sln"
	Invoke-MsBuild $solutionPath -MSBuildProperties @{ Configuration = "Release" }
}

task Version -depends Clean {

	$versionSourceFile = "$solutionDir\src\Enexure.Fire.Data\Version.json"
	$versionDetail = ConvertFrom-Json (Get-Content $versionSourceFile)
	$version = "$($versionDetail.Major).$($versionDetail.Minor).$($versionDetail.Patch).$build"

	$projectDir = "$solutionDir\src\Enexure.Fire.Data\Properties"
	$versionFile = "$projectDir\AssemblyVersion.cs"

	# Version information for an assembly consists of the following four values:
	# 
	#      Major Version
	#      Minor Version 
	#      Build Number
	#      Revision
	# 
	# You can specify all the values or you can default the Build and Revision Numbers 
	# by using the '*' as shown below:
	# [assembly: AssemblyVersion("1.0.*")]
	
	$versionFileContents = 
	"[assembly: AssemblyVersion(`"$version`")]" + "`n" +
	"[assembly: AssemblyFileVersion(`"$version`")]"

	Set-Content $versionFile $versionFile
}

task Clean { 
	
}

task ? -Description "Helper to display task info" {
	Write-Documentation
}