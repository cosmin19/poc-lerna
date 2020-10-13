$RootPath = Split-Path $PSScriptRoot -Parent
$ImageName = "namely/protoc-all"
$InternalDockerFolderName = $PSScriptRoot.Split("\")[-1]

$ProtosFolder = "protos"
$NugetFolder = "nuget"

$OutputLanguage = "csharp"

# Read from package.json PackageName, Version, ProtoDependencies
$jsonObject = Get-Content -Raw -Path "${PSScriptRoot}/package.json" | ConvertFrom-Json
$ProtoDependencies = $jsonObject.protoDependencies
$PackageVersion = $jsonObject.version
#Replace invalid characters for nuget package name
$PackageName = $jsonObject.name -Replace "@", '' -Replace "/", '.'

# Remove temporary external protofiles if exists
Remove-Item "${PSScriptRoot}/${ProtosFolder}/external" -Recurse -ErrorAction Ignore
# For each proto dependency, copy in current folder in order to prepare the nuget pack
for ($i = 0; $i -lt $ProtoDependencies.length; $i++) {
	$protoDep = $ProtoDependencies[$i]
	Copy-Item -Path "${RootPath}/${protoDep}" -Destination "${PSScriptRoot}/${ProtosFolder}/external/${protoDep}" -Recurse
}

# Create class files from proto files
docker run `
	-v "${RootPath}:/defs" `
	$ImageName `
	-d "./${InternalDockerFolderName}/${ProtosFolder}" `
	-o "./${InternalDockerFolderName}/${NugetFolder}/" `
	-l $OutputLanguage

# # Create nuGet package
dotnet pack "${PSScriptRoot}/${NugetFolder}/nuget.csproj" -c Release -o "${PSScriptRoot}/${NugetFolder}/release" -p:PackageVersion=$PackageVersion -p:PackageId=$PackageName

# Remove temporary external proto files
Remove-Item "${PSScriptRoot}/${ProtosFolder}/external" -Recurse -ErrorAction Ignore

# Remove .cs classes
Remove-Item "${PSScriptRoot}/${NugetFolder}/*" -Recurse -Include *.cs -ErrorAction Ignore

# Remove bin / obj folders
Remove-Item "${PSScriptRoot}/${NugetFolder}/bin" -Recurse -ErrorAction Ignore
Remove-Item "${PSScriptRoot}/${NugetFolder}/obj" -Recurse -ErrorAction Ignore
