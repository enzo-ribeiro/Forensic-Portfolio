# AUDIT CIS BENCHMARK - Version 2.0 (Améliorée)
# Auteur: Enzo (Amélioré par Gemini CLI)
# Description: Audit de sécurité Windows selon les standards CIS (Center for Internet Security)

$Report = @()
$Date = Get-Date -Format "yyyy-MM-dd_HH-mm"
$ComputerName = $env:COMPUTERNAME
$TempCfg = "$env:TEMP\secpol.cfg"

Write-Host "=== AUDIT CIS BENCHMARK PRO - $ComputerName ($Date) ===" -ForegroundColor Cyan
Write-Host "[*] Initialisation de l'audit..." -ForegroundColor Gray

# --- Fonction utilitaire pour ajouter un test au rapport ---
function New-AuditCheck {
    param($Title, $Current, $Expected, $Status, $Remediation = "Consulter le benchmark CIS pour Windows")
    return [PSCustomObject]@{
        Check       = $Title
        Current     = $Current
        Expected    = $Expected
        Status      = $Status
        Remediation = $Remediation
    }
}

# --- Export de la politique de sécurité locale pour analyse multilingue ---
secedit /export /cfg "$TempCfg" /quiet | Out-Null
$SecPol = if (Test-Path $TempCfg) { Get-Content $TempCfg -Encoding Unicode } else { "" }

# 1. POLITIQUES DE COMPTES (Account Policies)
Write-Host "`n[1] Politiques de Comptes..." -ForegroundColor Yellow
$AccountChecks = @(
    @{ Key = "MinimumPasswordLength"; Expected = 14; Title = "1.1.1 Longueur min mot de passe (>=14)"; Rem = "GPO: Password Policy > Minimum password length" }
    @{ Key = "PasswordHistorySize"; Expected = 24; Title = "1.1.2 Historique mot de passe (>=24)"; Rem = "GPO: Password Policy > Enforce password history" }
    @{ Key = "MaximumPasswordAge"; Expected = 365; Title = "1.1.3 Âge max mot de passe (<=365j)"; Rem = "GPO: Password Policy > Maximum password age" }
    @{ Key = "PasswordComplexity"; Expected = 1; Title = "1.1.5 Complexité mot de passe (Activée)"; Rem = "GPO: Password Policy > Password must meet complexity requirements" }
)

foreach ($c in $AccountChecks) {
    $Line = $SecPol | Select-String "^$($c.Key)\s*="
    $Val = if ($Line) { $Line.Line.Split('=')[1].Trim() } else { "Unknown" }
    
    $Status = "FAIL"
    if ($Val -ne "Unknown") {
        if ($c.Key -eq "MaximumPasswordAge") {
            if ([int]$Val -le $c.Expected -and [int]$Val -gt 0) { $Status = "PASS" }
        } else {
            if ([int]$Val -ge $c.Expected) { $Status = "PASS" }
        }
    }
    
    $Report += New-AuditCheck -Title $c.Title -Current $Val -Expected $c.Expected -Status $Status -Remediation $c.Rem
    Write-Host " - $($c.Title): $Status ($Val)" -ForegroundColor $(if($Status -eq "PASS"){"Green"}else{"Red"})
}

# 2. DROITS UTILISATEURS (User Rights Assignment)
Write-Host "`n[2] Droits Utilisateurs (Critiques)..." -ForegroundColor Yellow
$UserRightsChecks = @(
    @{ Key = "SeDebugPrivilege"; Expected = "Administrators"; Title = "2.2.20 Debug programs (Admins only)"; Rem = "GPO: User Rights > Debug programs" }
    @{ Key = "SeRemoteInteractiveLogonRight"; Expected = "Administrators"; Title = "2.2.9 RDP Access (Admins only)"; Rem = "GPO: User Rights > Allow log on through Remote Desktop Services" }
    @{ Key = "SeDenyNetworkLogonRight"; Expected = "S-1-5-32-546"; Title = "2.2.21 Deny network access (Guests)"; Rem = "GPO: User Rights > Deny access to this computer from the network" }
)

foreach ($r in $UserRightsChecks) {
    $Line = $SecPol | Select-String "^$($r.Key)\s*="
    $Val = if ($Line) { $Line.Line.Split('=')[1].Trim() } else { "None" }
    $Status = if ($Val -match $r.Expected) { "PASS" } else { "FAIL" }
    $Report += New-AuditCheck -Title $r.Title -Current $Val -Expected $r.Expected -Status $Status -Remediation $r.Rem
    Write-Host " - $($r.Title): $Status" -ForegroundColor $(if($Status -eq "PASS"){"Green"}else{"Red"})
}

# 3. SECURITÉ RÉSEAU
Write-Host "`n[3] Sécurité Réseau..." -ForegroundColor Yellow

# SMBv1 (EternalBlue Prevention)
$SmbV1 = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "SMB1" -ErrorAction SilentlyContinue).SMB1
$StatusSmb = if ($SmbV1 -eq 0 -or $null -eq $SmbV1) { "PASS" } else { "FAIL" }
$Report += New-AuditCheck -Title "Désactivation SMBv1" -Current (if ($null -eq $SmbV1) { "Désactivé" } else { $SmbV1 }) -Expected "0" -Status $StatusSmb -Remediation "PowerShell: Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol"
Write-Host " - SMBv1 désactivé: $StatusSmb" -ForegroundColor $(if($StatusSmb -eq "PASS"){"Green"}else{"Red"})

# LLMNR (Poisoning Prevention)
$Llmnr = (Get-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient" -Name "EnableMulticast" -ErrorAction SilentlyContinue).EnableMulticast
$StatusLlmnr = if ($Llmnr -eq 0) { "PASS" } else { "FAIL" }
$Report += New-AuditCheck -Title "Désactivation LLMNR" -Current $Llmnr -Expected "0" -Status $StatusLlmnr -Remediation "GPO: Network > DNS Client > Turn off LLMNR"
Write-Host " - LLMNR désactivé: $StatusLlmnr" -ForegroundColor $(if($StatusLlmnr -eq "PASS"){"Green"}else{"Red"})

# Firewall
$Firewall = Get-NetFirewallProfile | Select-Object Name, Enabled
$GlobalFirewall = "PASS"
foreach ($p in $Firewall) { if ($p.Enabled -ne "True") { $GlobalFirewall = "FAIL" } }
$Report += New-AuditCheck -Title "Pare-feu actif (tous profils)" -Current "Vérifié" -Expected "Enabled" -Status $GlobalFirewall -Remediation "Activer le Pare-feu via le Panneau de Configuration ou GPO"
Write-Host " - Pare-feu actif: $GlobalFirewall" -ForegroundColor $(if($GlobalFirewall -eq "PASS"){"Green"}else{"Red"})

# 4. SYSTÈME ET SERVICES
Write-Host "`n[4] Système et Services..." -ForegroundColor Yellow

# LSASS Protection
$Lsass = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL" -ErrorAction SilentlyContinue).RunAsPPL
$StatusLsass = if ($Lsass -eq 1) { "PASS" } else { "FAIL" }
$Report += New-AuditCheck -Title "LSASS Protection (RunAsPPL)" -Current $Lsass -Expected "1" -Status $StatusLsass -Remediation "Registry: HKLM\SYSTEM\CurrentControlSet\Control\Lsa\RunAsPPL = 1"
Write-Host " - LSASS Protection: $StatusLsass" -ForegroundColor $(if($StatusLsass -eq "PASS"){"Green"}else{"Red"})

# PowerShell Logging
$PsLog = (Get-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -ErrorAction SilentlyContinue).EnableScriptBlockLogging
$StatusPs = if ($PsLog -eq 1) { "PASS" } else { "FAIL" }
$Report += New-AuditCheck -Title "PowerShell ScriptBlock Logging" -Current $PsLog -Expected "1" -Status $StatusPs -Remediation "GPO: PowerShell > Turn on PowerShell Script Block Logging"
Write-Host " - PowerShell Logging: $StatusPs" -ForegroundColor $(if($StatusPs -eq "PASS"){"Green"}else{"Red"})

# Services inutiles
$UnwantedServices = @("Spooler", "Fax", "WINS", "RemoteRegistry")
foreach ($s in $UnwantedServices) {
    $svc = Get-Service $s -ErrorAction SilentlyContinue
    $Status = if (!$svc -or $svc.Status -eq "Stopped") { "PASS" } else { "FAIL" }
    $Report += New-AuditCheck -Title "Service $s arrêté" -Current (if ($svc) { $svc.Status } else { "Non installé" }) -Expected "Stopped" -Status $Status -Remediation "Désactiver le service $s via services.msc"
    Write-Host " - Service $s: $Status" -ForegroundColor $(if($Status -eq "PASS"){"Green"}else{"Red"})
}

# 5. RAPPORT FINAL
Write-Host "`n=== SYNTHÈSE ===" -ForegroundColor Cyan
$FailedCount = ($Report | Where-Object Status -eq "FAIL").Count
Write-Host "RÉSULTATS : " -NoNewline
Write-Host "$FailedCount / $($Report.Count) ÉCHECS" -ForegroundColor $(if($FailedCount -eq 0){"Green"}else{"Red"})

$OutputFile = "Audit_CIS_Resultats_$ComputerName_$Date.csv"
$Report | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8
Write-Host "Rapport complet exporté : $OutputFile" -ForegroundColor Green

# NETTOYAGE
if (Test-Path $TempCfg) { Remove-Item $TempCfg -Force }
