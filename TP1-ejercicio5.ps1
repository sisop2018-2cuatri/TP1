<#

.SYNOPSIS
Monitoreo de cambios de un directorio.

.DESCRIPTION 
Se notifica cuando se modifica, crea o elimina un archivo del directorio provisto como parametro,
en la salida se muestra la ruta del archivo, el tipo de modificacion, y la fecha y hora de la misma.
La ruta del directorio a monitoriar es un parametro obligatorio. El filtro, es la extension de los archivos
a monitoriar, se pueden pasar varias extensiones separandolas con comas (','); deben tener el formato '.*'
(EJ: .txt) o bien un '*' si se desea tomar todas las extensiones. Si no se pasa filtro toma '*' como default.
    
.PARAMETER path
Directorio a monitoriar
    
.PARAMETER filter
Entension de archivos a monitoriar

.EXAMPLE
.\TP1-ejercicio5.ps1 -path .\Desktop\carpeta -filter .txt,.doc
.EXAMPLE
.\TP1-ejercicio5.ps1 -path .\Desktop\carpeta
.EXAMPLE
.\TP1-ejercicio5.ps1 -path .\Desktop\carpeta -filter *
    
.NOTES
Trabajo Práctico N°1
Ejercicio 5
Script: TP1-ejercicio5.ps1
Entrega: primera
Integrantes:
    Avila, Leandro - 35.537.983
    Di Lorenzo, Maximiliano - 38.166.442
    Lorenz, Lautaro - 37.661.245
    Mercado, Maximiliano - 37.250.369
    Sequeira, Eliana - 39.061.003
#>
[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, HelpMessage = "Directorio a monitoriar")][String]$path,
    [Parameter(Mandatory = $false, HelpMessage = "Extension")][String[]]$filter=$null
)

function File-SystemWatcher{
[CmdLetBinding()]
Param(
    [String]$path,    
    [String]$extension
)
        $folder = $path
        
        if($extension -eq '*'){
            $filter = "*.*"            
        }
        else{
            $filter = "*$extension"
        }
        
        Write-Host "filter: $filter"

        $fsw = New-Object IO.FileSystemWatcher $folder, $filter -Property @{
        IncludeSubdirectories = $true;
        NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'}
        
        $IDCreated = "$extension-FileCreated"
        Register-ObjectEvent $fsw Created -SourceIdentifier $IDCreated  -Action {#Evento para creacion de archivos
        $path = $Event.SourceEventArgs.FullPath #obtengo la ruta del archivo creado
        $changeType = $Event.SourceEventArgs.ChangeType   
        [string]$timeStamp = $Event.TimeGenerated #tomo el instante en que ocurre el evento
        write-host "$path $changeType $timeStamp"
        }
         
        $IDChanged = "$extension-FileChanged"
        Register-ObjectEvent $fsw Changed -SourceIdentifier $IDChanged -Action {#Evento para modificacion de archivos
        $path = $Event.SourceEventArgs.FullPath #obtengo la ruta del archivo creado
        $changeType = $Event.SourceEventArgs.ChangeType   
        [string]$timeStamp = $Event.TimeGenerated #tomo el instante en que ocurre el evento   
        if ($out -ne "$path $changeType $timeStamp"){#Para que no realice la salida dos veces
            write-host "$path $changeType $timeStamp"
        }
        $out = "$path $changeType $timeStamp"        
        }
        
        $IDDeleted = "$extension-FileDeleted"
        Register-ObjectEvent $fsw Deleted -SourceIdentifier $IDDeleted -Action {#Evento para modificacion de archivos
        $path = $Event.SourceEventArgs.FullPath #obtengo la ruta del archivo creado
        $changeType = $Event.SourceEventArgs.ChangeType   
        [string]$timeStamp = $Event.TimeGenerated #tomo el instante en que ocurre el evento
        write-host "$path $changeType $timeStamp"
        }       
}

if ((Test-path $path) -eq $true){
    Write-Host "Path valido"
}
else
{
    Write-Host "Path invalido"
    exit
}

if($filter -eq $null){#como el param no es obligatorio le asingo '*', si no se completó
    $filter = '*'
}

foreach($exten in $filter){#Registro un evento por cada extension
    write-host "Extension: $exten"
    if ($exten -ne "*" -AND $exten -notlike ".*"){#Verifico que tenga un formato correcto
        Write-Host "Extension invalida: $exten"        
        exit
    }

    File-SystemWatcher -path $path -extension $exten #Funcion con el evento

}

    <#Unregister-Event *.txt-filecreated  #para borrar la suscripcion al evento
    Unregister-Event *.txt-filechanged
    Unregister-Event *.txt-fileDeleted

    Unregister-Event *.docx-filecreated  #para borrar la suscripcion al evento
    Unregister-Event *.docx-filechanged
    Unregister-Event *.docx-fileDeleted

    Unregister-Event *-filecreated  #para borrar la suscripcion al evento
    Unregister-Event *-filechanged
    Unregister-Event *-fileDeleted#>