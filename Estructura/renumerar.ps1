$path = "C:\Users\ccuichan\OneDrive - ALIANZA LOGISTIKA TDGE S.A\Archivos de Luis Campos _ Logiztik Alliance - 55188\Scripts Estructura\Estructura"

$files = Get-ChildItem $path -Filter *.sql | ForEach-Object {

    $name = $_.Name

    if ($name -match "CREATETABLE(?i)") { 
        $tipo = 1; $tipoNombre="CREATE" 
    }
    elseif ($name -match "CREATEVIEW(?i)") { 
        $tipo = 2; $tipoNombre="ALTER" 
    }
    elseif ($name -match "(?i)ALTER") { 
        $tipo = 3; $tipoNombre="ALTER" 
    }
    elseif ($name -match "-ADDDICTIONARY(?i)") { 
        $tipo = 4; $tipoNombre="ADDDICTIONARY" 
    }
    elseif ($name -match "-CREATEINDEXES_(?i)") { 
        $tipo = 5; $tipoNombre="CREATEINDEXES" 
    }
    elseif ($name -match "(?i)INSERTPARAMETROS") { 
        $tipo = 6; $tipoNombre="INSERTPARAMETROS" 
    }
    elseif ($name -match "(?i)INSERTCONTADORES") { 
        $tipo = 7; $tipoNombre="INSERTCONTADORES" 
    }
    elseif ($name -match "(?i)INSERTMENU") { 
        $tipo = 8; $tipoNombre="INSERTMENU" 
    }
    elseif ($name -match "(?i)INSERT") { 
        $tipo = 9; $tipoNombre="INSERT" 
    }
    else { 
        $tipo = 10; $tipoNombre="OTRO" 
    }

    [PSCustomObject]@{
        File = $_
        Tipo = $tipo
        TipoNombre = $tipoNombre
    }
}

$i = 1

$files | Sort-Object Tipo, {$_.File.Name} | ForEach-Object {

    $cleanName = $_.File.Name -replace '^\d+-',''
    $newName = "{0:D2}-$cleanName" -f $i

    Write-Host "Actualizado: $($_.File.Name) [$($_.TipoNombre)] -> $newName"

    if ($_.File.Name -ne $newName) {
        Rename-Item $_.File.FullName -NewName $newName
    }

    $i++
}