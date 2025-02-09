# Define the directory
$directory = ".\ApeCraft_08022025\region\"

# Change to the repository directory
Set-Location $directory

# Get the list of files in the directory
$files = Get-ChildItem -Path $directory -File | Select-Object -ExpandProperty FullName
$totalFiles = $files.Count

if ($totalFiles -eq 0) {
    Write-Host "No files to add. Exiting..."
    exit 0
}

$batchSize = 1000
$index = 0

while ($index -lt $totalFiles) {
    # Get the next batch of files
    $batch = $files[$index..($index + $batchSize - 1)]
    $batch = $batch | Where-Object { $_ -ne $null }  # Remove null values if any
    
    if ($batch.Count -eq 0) {
        break
    }

    Write-Host "Adding batch from $index to $(($index + $batch.Count - 1))..."
    git add -- "@batch"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Git add failed. Exiting..."
        exit 1
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
    Start-Sleep -Seconds 2  # Optional delay between batches
}

Write-Host "All files processed successfully."