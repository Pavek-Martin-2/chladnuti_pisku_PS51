cls # tento kod kompletne vygenerovala AI
# =====================================================================
# VSTUPNI PARAMETRY SIMULACE
# =====================================================================

$Objem = 1000000.0          # Objem telesa v cm3 (1000 cm3 = 1 litr pisku)
$TeplotaPocatecni = 500.0 # Pocatecni teplota rozhaveneho pisku ve stupnich C
$TeplotaOkolni = 20.0     # Teplota okolniho vzduchu ve stupnich C
$TeplotaCilova = 200.0     # Cilova teplota, na kterou chceme zchladnout ve stupnich C
# konec edit zony

# Fyzikalni konstanty pro suchy pisek
$HustotaPisku = 0.0016         # g/cm3 (cca 1600 kg/m3)
$MernaTepelnaKapacita = 0.830  # J/(g.K) (cca 830 J/kg.K)
$KoeficientPrestupuTepla = 15  # W/(m2.K) - bezne proudeni vzduchu - PUVODNI
#$KoeficientPrestupuTepla = 1  # W/(m2.K) - MUJ POKUS

# Hmotnost pisku (m = V * rho)
$Hmotnost = $Objem * $HustotaPisku * 1000 # prevod na gramy
$CelkovaTepelnaKapacita = $Hmotnost * $MernaTepelnaKapacita

Write-Host "--------------- SIMULACE CHLADNUTI PISKU ---------------" -ForegroundColor Cyan
Write-Host "Objem: $Objem cm3 | Hmotnost pisku: $(([math]::Round($Hmotnost, 1))) g" -ForegroundColor Gray
Write-Host "Chladnuti z $TeplotaPocatecni C na $TeplotaCilova C pri okolni teplote $TeplotaOkolni C" -ForegroundColor Gray
Write-Host "--------------------------------------------------------" -ForegroundColor Gray

# Pomocna funkce pro vypocet casu chladnuti (Newtonuv ochlazovaci zakon)
function SpoctiCasChladnuti ($PovrchCm2) {
    # Prevod povrchu z cm2 na m2 pro fyzikalni vzorec
    $S_m2 = $PovrchCm2 / 10000
    
    # Vypocet koeficientu chladnuti k
    $k = ($KoeficientPrestupuTepla * $S_m2) / $CelkovaTepelnaKapacita
    
    # Newtonuv vzorec: t = -ln((T_cil - T_okol) / (T_poc - T_okol)) / k
    $CasVSekundach = -[Math]::Log(($TeplotaCilova - $TeplotaOkolni) / ($TeplotaPocatecni - $TeplotaOkolni)) / $k
    return $CasVSekundach / 60 # Navrat v minutach
}

# =====================================================================
# VYPOCTY GEOMETRIE A CASU
# =====================================================================

# 1. KOULE
$r_koule = [Math]::Pow((3 * $Objem) / (4 * [Math]::PI), (1/3))
$S_koule = 4 * [Math]::PI * [Math]::Pow($r_koule, 2)
$Cas_koule = SpoctiCasChladnuti $S_koule

# 2. OPTIMALNI VALEC (vyska = prumer)
$r_valec = [Math]::Pow($Objem / (2 * [Math]::PI), (1/3))
$h_valec = 2 * $r_valec
$S_valec = (2 * [Math]::PI * $r_valec * $h_valec) + (2 * [Math]::PI * [Math]::Pow($r_valec, 2))
$Cas_valec = SpoctiCasChladnuti $S_valec

# 3. KRYCHLE
$a_krychle = [Math]::Pow($Objem, (1/3))
$S_krychle = 6 * [Math]::Pow($a_krychle, 2)
$Cas_krychle = SpoctiCasChladnuti $S_krychle

# =====================================================================
# VYSTUP VYSLEDKU DO KONZOLE
# =====================================================================
$Vystup1 = [PSCustomObject]@{
    "Tvar hromady"  = "Koule (Ideal)"
    "Povrch [cm2]"  = "{0:N1}" -f $S_koule
    "Cas chladnuti" = "{0:N1} minut" -f $Cas_koule
    "Efektivita"    = "Udrzi teplo NEJDELE"
}

$Vystup2 = [PSCustomObject]@{
    "Tvar hromady"  = "Optimalni valec"
    "Povrch [cm2]"  = "{0:N1}" -f $S_valec
    "Cas chladnuti" = "{0:N1} minut" -f $Cas_valec
    "Efektivita"    = "Zchladne o {0:N1} min drive nez koule" -f ($Cas_koule - $Cas_valec)
}

$Vystup3 = [PSCustomObject]@{
    "Tvar hromady"  = "Krychle"
    "Povrch [cm2]"  = "{0:N1}" -f $S_krychle
    "Cas chladnuti" = "{0:N1} minut" -f $Cas_krychle
    "Efektivita"    = "Zchladne o {0:N1} min drive nez koule" -f ($Cas_koule - $Cas_krychle)
}

# Slouceni a zobrazeni v jedne prehledne tabulce
$Tabulka = @($Vystup1, $Vystup2, $Vystup3)
$Tabulka | Format-Table -AutoSize

Write-Host -ForegroundColor Red "vtip : " -NoNewline
Write-Host -ForegroundColor Cyan "Co kdyby byl Betelgeus ve tvaru valce ?"

sleep 60
