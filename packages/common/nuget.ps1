$RootPath = Split-Path $PSScriptRoot -Parent
$ImageName = "namely/protoc-all"
$InternalDockerFolderName = $PSScriptRoot.Split("\")[-1]

$ProtosFolder = "protos"
$NugetFolder = "nuget"

$OutputLanguage = "csharp"

# Read from package.json PackageName, Version, ProtoDependencies
$jsonObject = Get-Content -Raw -Path "${PSScriptRoot}/package.json" | ConvertFrom-Json
$ProtoDependencies = $jsonObject.protoDependencies
$ProtoDependenciesRecursiveFetch = $jsonObject.protoDependencies
$PackageVersion = $jsonObject.version
#Replace invalid characters for nuget package name
$PackageName = $jsonObject.name -Replace "@", '' -Replace "/", '.'

# Add recursive dependencies to array
function ResolveDependecies() {
	param
	(
		[Parameter(Mandatory = $true)]
		[object[]]$dependency
	)

	for ($i = 0; $i -lt $dependency.length; $i++) {
		$protoDep = $dependency[$i]
		$protoRoot = $protoDep.root
		$tempJsonObject = Get-Content -Raw -Path "${RootPath}/${protoRoot}/package.json" | ConvertFrom-Json
		$ProtoDependencies = $ProtoDependencies + $tempJsonObject.protoDependencies
		if($tempJsonObject.protoDependencies.length -gt 0) {
			$ProtoDependencies = ResolveDependecies -dependency $tempJsonObject.protoDependencies
		}
	}
	return $ProtoDependencies;
}

if($ProtoDependenciesRecursiveFetch.protoDependencies.length -gt 0) {
	$ProtoDependencies = ResolveDependecies -dependency $ProtoDependenciesRecursiveFetch
	$ProtoDependencies = $ProtoDependencies | Sort-Object 'root', 'protoPath' | Get-Unique -AsString
}

# Remove temporary external protofiles if exists
Remove-Item "${PSScriptRoot}/${ProtosFolder}/external" -Recurse -ErrorAction Ignore
# For each proto dependency, copy in current folder in order to prepare the nuget pack
for ($i = 0; $i -lt $ProtoDependencies.length; $i++) {
	$protoDep = $ProtoDependencies[$i]
	$protoRoot = $protoDep.root
	$protoPath = $protoDep.protoPath
	$protoDepPath = "${protoRoot}/${protoPath}";
	Copy-Item -Path "${RootPath}/${protoDepPath}" -Destination "${PSScriptRoot}/${ProtosFolder}/external/${protoDepPath}" -Recurse
}

# Create class files from proto files
docker run `
	-v "${RootPath}:/defs" `
	$ImageName `
	-d "./${InternalDockerFolderName}/${ProtosFolder}" `
	-o "./${InternalDockerFolderName}/${NugetFolder}/" `
	-l $OutputLanguage

# Create nuGet package
dotnet pack "${PSScriptRoot}/${NugetFolder}/nuget.csproj" -c Release -o "${PSScriptRoot}/${NugetFolder}/release" -p:PackageVersion=$PackageVersion -p:PackageId=$PackageName

# Remove temporary external proto files
Remove-Item "${PSScriptRoot}/${ProtosFolder}/external" -Recurse -ErrorAction Ignore

# Remove .cs classes
Remove-Item "${PSScriptRoot}/${NugetFolder}/*" -Recurse -Include *.cs -ErrorAction Ignore

# Remove bin / obj folders
Remove-Item "${PSScriptRoot}/${NugetFolder}/bin" -Recurse -ErrorAction Ignore
Remove-Item "${PSScriptRoot}/${NugetFolder}/obj" -Recurse -ErrorAction Ignore
