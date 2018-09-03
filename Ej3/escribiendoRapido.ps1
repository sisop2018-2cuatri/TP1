<#
.Synopsis
    Juego de escritura de palabras
.DESCRIPTION
    El juego consiste en escribir la palabra mostrada en pantalla lo mas rapido posible. El tiempo que se tarde por cada palabra va a decidir el score final (tiempo promedio).
.EXAMPLE
    .\escribiendoRapido.ps1 3 palabras.txt score.txt -Aleatoria
        Bienvenido a EscribiendoRapido!


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
        Ingrese su nombre: JIM

        Name                           Value                                                                                                                                                 
        ----                           -----                                                                                                                                                 
        TIM                            00:00:01.4330000                                                                                                                                      
        maxi                           00:00:01.5600000                                                                                                                                      
        max                            00:00:01.8870000
.EXAMPLE
    .\escribiendoRapido.ps1 2 palabras.txt -Descendente
        Bienvenido a EscribiendoRapido!


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
    Nombre del Script: escribiendoRapido.ps1
    Trabajo Practico: 1
    Numero de Ejercicio: 3

.Integrantes:
    38166442 Maximiliano Di Lorenzo

#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateRange(2,10)]
    [int]$cantidad,
    [Parameter(Mandatory=$false, Position=1)]
    [ValidateNotNullOrEmpty()]
    [String]$rutaPalabras = ".\palabras.txt",
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

Write-Host("`nBienvenido a EscribiendoRapido!`n`n");
Write-Host("Este juego toma el tiempo que tardas en escribir las palabras mostradas en pantalla.`n");

if((Get-Content $rutaPalabras).Count -lt $cantidad){
    Write-Error -Message "CANTIDAD DE PALABRAS MAYOR A LAS EXISTENTES EN EL ARCHIVO." -ErrorAction Stop
}else{
$palabras = Get-Content -Path $rutaPalabras | select -First $cantidad;
}

switch($PSCmdlet.ParameterSetName){
    'Aleatoria' {$palabras = $palabras | Sort-Object {Get-Random};}
    'Descendente' {$palabras = $palabras | Sort-Object -Descending;}
    'Ascendente' {$palabras = $palabras | Sort-Object;}
}

$stopwatch =  New-Object System.Diagnostics.Stopwatch;
$tiempoTranscurrido = $stopwatch.Elapsed;
$tiempoPalabra = @{};

Read-Host "Presiona Enter para comenzar" | Out-Null;

Write-Host("`n------`nSTART!`n------`n");

foreach($palabra in $palabras){
    $stopwatch.Start();
    do{
        $palabraEscrita = Read-Host -prompt $palabra;
        $teclas+= $palabraEscrita.Length;
    }while($palabraEscrita -notlike $palabra);
    
    $stopwatch.Stop();
    $tiempoPalabra[$palabra] = ($stopwatch.Elapsed - $tiempoTranscurrido);
    $tiempoTranscurrido = $stopwatch.Elapsed;
}

Write-Host("`n----------`nFINISHED!`n----------`n");
Write-Host("Tiempo total: " + $stopwatch.Elapsed);

foreach($palabra in $palabras){
    Write-Host("Palabra '$palabra' / Tiempo: " + $tiempoPalabra[$palabra]);
}

$tiempoPromedio =  [TimeSpan]::FromMilliseconds($stopwatch.Elapsed.TotalMilliseconds/ $cantidad); 

Write-Host("Tiempo Promedio por palabra: $tiempoPromedio");
Write-Host("Teclas por segundo: "+ $teclas / $stopwatch.Elapsed.TotalSeconds);

if($rutaScore){
    [Hashtable]$score = @{};
    Get-Content -Path $rutaScore | ForEach-Object{
        $objeto = $_.ToString().Split("/").trim();
        $score[$objeto[0]]=$objeto[1];
    }
    
    $nombre = Read-Host -prompt "Ingrese su nombre";
    $score[$nombre]=$tiempoPromedio;

    $score.GetEnumerator() | sort value | select -First 3;
    
    Add-Content $rutaScore "$nombre/$tiempoPromedio";
}