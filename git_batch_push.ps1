# Define the correct directory path relative to the script location
$directory = ".\ApeCraft_08022025\region"

# Resolve the full path to avoid issues
$directory = Resolve-Path $directory

# Ensure the directory exists
if (!(Test-Path $directory)) {
    Write-Host "Error: The directory does not exist: $directory"
    exit 1
}

# Change to the correct directory
Set-Location $directory

# Get the list of files in the directory
$files = Get-ChildItem -Path $directory -File | Select-Object -ExpandProperty FullName
$totalFiles = $files.Count

if ($totalFiles -eq 0) {
    Write-Host "No files to add. Exiting..."
    exit 0
}

$batchSize = 500
$index = 0

while ($index -lt $totalFiles) {
    # Get the next batch of files
    $batch = $files[$index..($index + $batchSize - 1)]
    $batch = $batch | Where-Object { $_ -ne $null }  # Remove null values if any
    
    if ($batch.Count -eq 0) {
        break
    }

    Write-Host "Adding batch from $index to $(($index + $batch.Count - 1))..."

    # Add files individually to avoid long command errors
    foreach ($file in $batch) {
        git add -- "$file"
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Git add failed on file: $file. Exiting..."
            exit 1
        }
    }

    Write-Host "Committing batch..."
    git commit -m "Batch commit: Files $index to $(($index + $batch.Count - 1))"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Git commit failed. Exiting..."
        exit 1
    }

    Write-Host "Pushing batch..."
    git push
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Git push failed. Exiting..."
        exit 1
    }

    $index += $batchSize
    Start-Sleep -Seconds 1  # Optional delay between batches
}

Write-Host "All files processed successfully."