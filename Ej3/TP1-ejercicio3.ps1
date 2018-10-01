<#
.Synopsis
    Juego de escritura de palabras
.DESCRIPTION
    El juego consiste en escribir la palabra mostrada en pantalla lo mas rapido posible. El tiempo que se tarde por cada palabra va a decidir el score final (tiempo promedio).
.EXAMPLE
    .\TP1-ejercicio3.ps1 3 .\palabras\palabras.txt .\score\score.txt -Aleatoria
        Bienvenido a TP1-ejercicio3.ps1!


        Este juego toma el tiempo que tardas en escribir las palabras mostradas en pantalla.

        Presiona Enter para comenzar: 

        ------
        START!
        ------

        cartucho: cartucho
        letrina: letrina
        sarampion: sarampion

        ----------
        FINISHED!
        ----------

        Tiempo total: 00:00:05.8187271
        Palabra 'cartucho' / Tiempo: 00:00:02.0732400
        Palabra 'letrina' / Tiempo: 00:00:01.4023230
        Palabra 'sarampion' / Tiempo: 00:00:02.3431641
        Tiempo Promedio por palabra: 00:00:01.9400000
        Teclas por segundo: 4.12461343993947
        Ingrese su nombre con letras de la a-z y numeros 0-9: JIM

        Name                           Value                                                                                                                                                 
        ----                           -----                                                                                                                                                 
        TIM                            00:00:01.4330000                                                                                                                                      
        maxi                           00:00:01.5600000                                                                                                                                      
        max                            00:00:01.8870000
.EXAMPLE
    .\TP1-ejercicio3.ps1 2 .\palabras\palabras.txt -Descendente
        Bienvenido a TP1-ejercicio3!


        Este juego toma el tiempo que tardas en escribir las palabras mostradas en pantalla.

        Presiona Enter para comenzar: 

        ------
        START!
        ------

        letrina: letrina
        cartucho: cartucho

        ----------
        FINISHED!
        ----------

        Tiempo total: 00:00:02.7876103
        Palabra 'letrina' / Tiempo: 00:00:01.4042077
        Palabra 'cartucho' / Tiempo: 00:00:01.3834026
        Tiempo Promedio por palabra: 00:00:01.3940000
        Teclas por segundo: 5.38095299762668
    
.NOTES
    Nombre del Script: TP1-ejercicio3.ps1
    Trabajo Practico: 1
    Numero de Ejercicio: 3

    Integrantes:
    Avila, Leandro - 35.537.983
	Di Lorenzo, Maximiliano - 38.166.442
	Lorenz, Lautaro - 37.661.245
	Mercado, Maximiliano - 37.250.369
	Sequeira, Eliana - 39.061.003

#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateRange(2,10)]
    [int]$cantidad,
    [Parameter(Mandatory=$false, Position=1)]
    [ValidateNotNullOrEmpty()]
    [String]$rutaPalabras = ".\palabras\palabras.txt",
    [Parameter(Mandatory=$false, Position=2)]
    [ValidateNotNullOrEmpty()]
    [String]$rutaScore,
    [Parameter(Mandatory=$True, ParameterSetName='Aleatoria')]
    [Switch]$Aleatoria,
    [Parameter(Mandatory=$True, ParameterSetName='Ascendente')]
    [Switch]$Ascendente,
    [Parameter(Mandatory=$True, ParameterSetName='Descendente')]
    [Switch]$Descendente

)

Write-Host("`nBienvenido a TP1-ejercicio3!`n`n");
Write-Host("Este juego toma el tiempo que tardas en escribir las palabras mostradas en pantalla.`n");

if((Test-Path $rutaPalabras) -eq $false){
    write-error -Message "PATH ERRONEO, NO SE ENCUENTRA UN ARCHIVO DE PALABRAS EN ESA DIRECCION" -ErrorAction Stop
}

#Recojo las palabras del archivo, las palabras vacias o null las filtro
[System.Collections.ArrayList]$palabras = @()
foreach($linea in Get-Content $rutaPalabras){
    if(![String]::IsNullOrWhiteSpace($linea) -and $linea){
        $palabras.Add($linea.trim()) > $null #Recorto excesos de espacios al inicio y fin de palabras para emprolijar
    }
}

write-debug "Cantidad de palabras: $($palabras.Count)"
if($palabras.Count -lt $cantidad){
    Write-Error -Message "CANTIDAD DE PALABRAS MAYOR A LAS EXISTENTES EN EL ARCHIVO." -ErrorAction Stop #Evaluo si la cantidad de palabras en el archivo es menor a las pedidas por parametro
}
$palabras = $palabras | Sort {Get-Random} | select -First $cantidad



#Segun lo que hayan elegido, determino como ordenar las palabras
switch($PSCmdlet.ParameterSetName){
    'Aleatoria' {$palabras = $palabras | Sort-Object {Get-Random};}
    'Descendente' {$palabras = $palabras | Sort-Object -Descending;}
    'Ascendente' {$palabras = $palabras | Sort-Object;}
}

#Instancio la clase stopwatch(Cronometro) para poder realizar las mediciones de los tiempos
$stopwatch =  New-Object System.Diagnostics.Stopwatch;
$tiempoTranscurrido = $stopwatch.Elapsed;
$tiempoPalabra = @{}; #Hashtable donde voy a guardar los tiempos de cada palabra

Read-Host "Presiona Enter para comenzar" | Out-Null;

#Inicio del juego
Write-Host "`n------`nSTART!`n------`n" -ForegroundColor Green -BackgroundColor Black

#Recorro todas las palabras de la lista, tomando el tiempo que tardan en escribirlas
foreach($palabra in $palabras){
    $stopwatch.Start();
    do{
        $palabraEscrita = Read-Host -prompt $palabra;
        $teclas+= $palabraEscrita.Length; #La cantidad de letras es la longitud de la palabra
    }while($palabraEscrita -notlike $palabra); #Si la palabra esta mal escrita, la pido devuelta hasta que le salga bien.
    
    $stopwatch.Stop(); #Paro el cronometro cuando la palabra se escribe correctamente
    $tiempoPalabra[$palabra] = ($stopwatch.Elapsed - $tiempoTranscurrido); #Como el cronometro no me deja hacer laps, tengo que guardar el tiempo transcurrido hasta el anterior lap y restarle el Elapsed para calcular delta tiempo (el tiempo de la palabra)
    $tiempoTranscurrido = $stopwatch.Elapsed; 
}

Write-Host "`n----------`nFINISHED!`n----------`n" -ForegroundColor White -BackgroundColor DarkGreen

#Muestro las palabras y sus tiempos
foreach($palabra in $palabras){
    Write-Host "Palabra $($palabra) / Tiempo:  $($tiempoPalabra[$palabra])" -ForegroundColor Cyan -BackgroundColor DarkMagenta
}

$tiempoPromedio =  [TimeSpan]::FromMilliseconds($stopwatch.Elapsed.TotalMilliseconds/ $cantidad); #La unica forma que se me ocurrio de calcular el average time por palabra en juego, usando TimeSpan de .Net para poder crear un TimeSpan con milliseconds, cosa que el de PS no me deja
Write-Host "Tiempo total: $($stopwatch.Elapsed)" -ForegroundColor Green -BackgroundColor Black
Write-Host "Tiempo Promedio por palabra: $tiempoPromedio" -ForegroundColor Green -BackgroundColor Black
Write-Host "Teclas por segundo: $($teclas / $stopwatch.Elapsed.TotalSeconds)" -ForegroundColor Green -BackgroundColor Black
Write-Host ""

#Si hay algun archivo de scores, guardo el score y muestro el top 3
if($rutaScore){
    [Hashtable]$score = @{}; #Hashtable de scores donde voy a trabajar
    
    #Me fijo si existe el archivo de scores especificado, si no existe lo creo
    if(!(Test-Path $rutaScore)){
        New-Item $rutaScore -type file > $null
    }
    
    Get-Content -Path $rutaScore | ForEach-Object{
        $objeto = $_.ToString().Split("/").trim();
        $score[$objeto[0]]=$objeto[1]; #Guardo en el hashtable los scores del archivo
    }
    
    do{
        $nombre = (Read-Host -prompt "Ingrese su nombre con letras de la a-z y numeros 0-9").Trim()
    }while($nombre -notmatch "^[a-z0-9]"); #Para que no ingresen caracteres foraneos que revienten el split de arriba

    $score[$nombre]=$tiempoPromedio; #Agrego al hastable el score del jugador actual

    $score.GetEnumerator() | sort value | select -First 3; #Del hashtable levanto los mejores 3
    
    Add-Content $rutaScore "$nombre/$tiempoPromedio"; #Guardo el score del jugador actual al final del archivo
}