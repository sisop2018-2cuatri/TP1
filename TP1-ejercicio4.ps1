<#
    .SYNOPSIS
    Adminsitrador de reservas y devolución de pasajes

    .DESCRIPTION
    Realice control de pasajes mediante la RESERVA o la DEVOLUCIÓN de los mismos.
    El operador deberá seleccionar el destino entre los disponibles
    y luego se realizará la operación que haya seleccionado.
    Siempre se realizan reservas a menos que se indique explicitamente
    que es una devolución.
    Siempre se realizarán operaciones de sobre un único pasaje a menos que
    indique una cantidad diferente.

    .PARAMETER ciudadOrigen
    Ciudad la cual será tomada como punto de partida

    .PARAMETER ciudadDestino
    Ciudad la cual será tomada como punto de llegada

    .PARAMETER euro 
    (OPCIONAL) Representa cuantos leks son un euro

    .PARAMETER Devolucion 
    Ingresarlo si se quiere hacer una devolución de pasaje

    .PARAMETER cantidad
    (OPCIONAL) Cantidad de pasajes que se van a reservar o devolver, por defecto es un solo pasaje.
    Como máximo cien pasajes.

    .EXAMPLE
    .\TP1-ejercicio4.ps1 -ciudadOrigen 'kotor' -ciudadDestino 'tirana'

    .EXAMPLE
    .\TP1-ejercicio4.ps1 -ciudadOrigen 'kotor' -ciudadDestino 'tirana' -euro 140

    .EXAMPLE
    .\TP1-ejercicio4.ps1 -ciudadOrigen 'kor' -ciudadDestino 'ti'

    .EXAMPLE
    .\TP1-ejercicio4.ps1 -ciudadOrigen 'Ko' -ciudadDestino 'T' -euro 10 -Devolucion

    .EXAMPLE
    .\TP1-ejercicio4.ps1 -ciudadOrigen 'k' -ciudadDestino 's' -Devolucion

    .EXAMPLE
    .\TP1-ejercicio4.ps1 -ciudadOrigen 'k' -ciudadDestino 's' -Devolucion -Cantidad 2

    .INPUTS
    .\bdd.csv

    .OUTPUTS
    .\bdd.csv

    .NOTES
    Sistemas Operativos
    -------------------
	Trabajo Práctico N°1
	Ejercicio 4
	Script: .\TP1-ejercicio4.ps1
    -------------------
	Integrantes:
	    Avila, Leandro - 35.537.983
	    Di Lorenzo, Maximiliano - 38.166.442
	    Lorenz, Lautaro - 37.661.245
	    Mercado, Maximiliano - 37.250.369
	    Sequeira, Eliana - 39.061.003

#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$TRUE, Position=1)]
    [ValidateNotNullOrEmpty()]
    [string] $ciudadOrigen,

    [Parameter(Mandatory=$TRUE, Position=2)]
    [ValidateNotNullOrEmpty()]
    [string] $ciudadDestino,

    [Parameter(Mandatory=$FALSE, Position=3)]
    [ValidateRange(0, [int]::MaxValue)] 
    [Int] 
    $euro,
        
    [Parameter(Mandatory=$FALSE)]
    [Switch]
    $Devolucion,

    [Parameter(Mandatory=$FALSE)]
    [ValidateRange(0, 100)] 
    [Int] 
    $cantidad = 1
)

# Versión del script
Set-Variable VERSION_CODE -option Constant -value '1.0.0'
Write-Verbose "versión del script $VERSION_CODE" 

# Buscar y abrir base de datos
$path_bdd = '.\bdd.csv'

if(Test-Path $path_bdd) { 
    # si la base de datos fue encontrada
    Write-Verbose "base de datos encontrada"

    # controlar tipo de moneda ingresado
    $precio_unidad = "euros"
    if ($euro -eq 0) {
        $precio_unidad = "leks"
    }

    Write-Verbose "el precio se muestra en [$precio_unidad]"

    # títulos de los datos leídos desde la base de datos
    $headers = 
        'Origen', 
        'Fecha-Hora origen', 
        'Destino', 
        'Fecha-Hora destino', 
        "Precio ($precio_unidad)", 
        'Lugares libres'

    # Importar destinos cargados en base de datos
    $bdd = Import-Csv $path_bdd -Delimiter ';' -Header $headers

    # agregamos la propiedad 'ID' (número de fila menos uno) a cada destino
    $bdd_filter = $bdd | ForEach-Object -Begin {$index = 0} -Process {
        $_ | Select-Object @{l='ID'; e={$index}}, *
        $index += 1
    }

    Write-Verbose "columna [ID] agregada a los datos"

    # obtener fecha-hora de ejecución en formato "MM/dd/yyyy hh:mm AM"
    # formato 'dd/MM/yyyy hh:mm tt' = [Globalization.CultureInfo]::CreateSpecificCulture('es-AR')
    $culture_en_US = New-Object system.globalization.cultureinfo('en-US')
    $execution_datetime = Get-Date -format (($culture_en_US.DateTimeFormat.ShortDatePattern) + " hh:mm tt")

    # aplicamos los filtros:
    # ciudades que comienzan con $ciudadDestino y $ciudadOrigen
    # pasajes con Fecha-Hora desde mayor a la de ejecución.
    $bdd_filter = $bdd_filter.Where{ 
        ($_.Origen -like "$ciudadOrigen*") -and 
        ($_.Destino -like "$ciudadDestino*") -and
        ([dateTime]::Parse($_.'Fecha-Hora origen', ([Globalization.CultureInfo]::CreateSpecificCulture('es-AR'))) -gt $execution_datetime)
    }

    Write-Verbose "filtros aplicados"
        
    if(!$Devolucion) { 
        # si es una nueva reserva de pasaje
        Write-Verbose "los destinos sin suficientes lugares libres no pueden ser modificados en esta operación"

        # no muestro los destinos sin suficientes lugares disponibles
        $bdd_filter = $bdd_filter.Where{ [Int]$_.'Lugares libres' -ge [Int]$cantidad }        
    } 

    if($bdd_filter.count -gt 0) { 
        # si hay destinos para mostrar
        Write-Verbose "mostrar destinos seleccionables"

        # agregamos el 'ID' a los headers
        $headers = @("ID") + $headers

        # formateamos el precio según la unidad usada para la búsqueda
        if($precio_unidad -eq "euros") {
            # mostrar precio en euros (redondeando a dos las posiciones decimales)
            $headers[5] = @{
                Label="Precio ($precio_unidad)"; 
                Expression={"" + [math]::Round($_."Precio ($precio_unidad)"/$euro,2)}}
        }

        #mostramos los destinos encontrados
        $bdd_filter | Format-Table -Property $headers -Wrap -AutoSize

        #verificamos que el usuario ingrese un ID válido
        do {
            #solicitamos al usuario el ID del destino a modificar (reserva/devolución)
            Write-Host 'Ingrese [ID] del destino para [' -NoNewline
            if($Devolucion) {
                Write-Host 'CANCELAR RESERVA' -NoNewline -ForegroundColor Yellow
                if(-not ([int]$cantidad -eq 1)) {
                    # si la cantidad es mayor a uno (ya sabemos que no es menor)
                    Write-Host 'S' -NoNewline -ForegroundColor Yellow
                }
            } else {
                Write-Host 'RESERVAR' -NoNewline -ForegroundColor Yellow
            }
            Write-Host ']: ' -NoNewline

            $inputString = Read-Host
            $ID = $inputString -as [Int]
              
            # validamos que el ID ingresado exista
            $ok = ($ID -ne $NULL) -and ($bdd_filter.where{ $_.'ID' -eq $ID }.count -gt 0)
            if ( -not $ok ) { 
                Write-Verbose "el [ID] ingresado no corresponde a ninguno de los destinos disponibles"
                Write-Host "ERROR: debe ingresar un [ID] de destino entre los mostrados en la tabla" -ForegroundColor Red
                Write-Host ""
            }
        } until ($ok)

        # [ID] ingresado por el usuario
        Write-Verbose "[ID] de destino ingresado: [$ID]"

        # generar cambio en la base de datos de salida
        $index = 0  
        $bdd_output = foreach ($register in $bdd) { # buscamos la linea para modificar              
            if($index -eq $ID) {
                # si encontramos la linea para modificar
                Write-Verbose "se encontró el [ID] ingresado en la base de datos"

                if($Devolucion) { 
                    Write-Verbose "realizar operación [DEVOLUCIÓN]"

                    # realizamos la devolución
                    $register.'Lugares libres' = [int]$register.'Lugares libres' + [Int]$cantidad
                } else {
                    Write-Verbose "realizar operación [RESERVA]"

                    if(([int]$register.'Lugares libres' - [Int]$cantidad) -ge 0) {
                        Write-Verbose "hay suficientes lugares libres para realizar la reserva"

                        # si hay suficientes lugares libres para reservar
                        $register.'Lugares libres' = [int]$register.'Lugares libres' - [Int]$cantidad
                    } else {
                        # no hay lugares suficientes para realizar la reserva
                        Write-Error "ERROR: lugares disponibles insuficientes para realizar la reserva" -ErrorAction Stop
                    }                    
                }

                $destino_modificado = $register
            } 

            # guardar registro modificado 
            $register 
            
            # incrementar contador de registro
            $index++
        }
               
        if(Test-Path $path_bdd) {  # si la base de datos física aún existe               
            # guardar cambios en base de datos
            $bdd_output | ConvertTo-Csv -NoTypeInformation -Delimiter ';' | select -Skip 1 | Set-Content $path_bdd -Force -Encoding BigEndianUnicode
            
            Write-Verbose "cambios guardados en base de datos"

            # mensaje de estado de la operación   
            Write-Host "Pasaje" -NoNewline -ForegroundColor Green
            if(-not ([int]$cantidad -eq 1)) {
                Write-Host 's' -NoNewline -ForegroundColor Green
            }       
            if($Devolucion) {
                Write-Host ' [CANCELADO' -NoNewline -ForegroundColor Green
            } else {
                Write-Host ' [RESERVADO' -NoNewline -ForegroundColor Green
            }
            if(-not ([int]$cantidad -eq 1)) {
                Write-Host 'S' -NoNewline -ForegroundColor Green
            }
            Write-Host '] correctamente' -ForegroundColor Green

            Write-Verbose "mostrar resultado de la operación sobre la fila modificada"

            # mostrar resultado de la operación
            Write-Host ""
            Write-host "El destino modificado quedó guardado con los siguientes datos"
            $destino_modificado | Select-Object @{l='ID'; e={$ID}},* | Format-Table -Property $headers -Wrap -AutoSize
        } else {
            Write-Host "ERROR: al guardar archivo '$path_bdd' no encontrado" -ForegroundColor Red
        }            
    } else { # si no hay destinos disponibles
        Write-Host "No se encontraron destinos, intente con otras ciudades"
    }
} else { # si no se encontró la base de datos        
    Write-Host "ERROR: archivo '$path_bdd' no encontrado" -ForegroundColor Red
}

<# Fin de archivo #>