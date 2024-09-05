<# 
    Script:      Jgroup Safe Onboarding
    Version:     1.0
    Author:      Dylan Kremers (dylan.kremers@jgroupconsulting.com.au)
    Date:        Sept 2024
    Support:     support@jgroupconsulting.com.au
    Usage:       1. Run the Script
                 2. Prompted to enter Safe name
                 3. Prompted to enter description of safe
                 4. New Role is created with the following format "SAFENAME_Usr"
                 5. New Role, Privilege Cloud Administrators & Privilege Cloud Auditors are
                 all addeed to the safe with permissions set
                 6. All actions are logged into a "log.txt"

    Client Variables configured for this test. Ensure it is correct before proceeding.
#>

# 1. ---- Client variables ----#
#TO BE UPDATED PER CLIENT
$tenantID = 'ABA4130'
$subdomain = 'jgroup'
$api_user = 'api_onboarding_user@jgroupconsulting.com.au'
$client_secret = $Env:cyberark_secret
$CPM = 'CONNECTOR01'

#Standard Priv Cloud URLs please verify before use.
$auth_url = "https://$tenantID.id.cyberark.cloud/oauth2/platformtoken"
$api_url = "https://$subdomain.privilegecloud.cyberark.cloud/PasswordVault/api"
$client_id = [uri]::EscapeDataString($api_user)
$tenant_api_url = "https://$subdomain.id.cyberark.cloud"

if ($client_secret.length -eq 0) {
    Throw "Client Secret not defined in env variable, please set `$Env:cyberark_secret"
}

# 2. ---- Authorization ----#
Write-Host "Starting authorization..." -ForegroundColor Cyan
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/x-www-form-urlencoded")
$body = "grant_type=client_credentials&client_id=$client_id&client_secret=$client_secret"
$response = Invoke-RestMethod $auth_url -Method 'POST' -Headers $headers -Body $body
$bearer_token = $response.access_token
Write-Host "Authorization successful." -ForegroundColor Green

# 3. ---- Get List of Safes ----#
Write-Host "Fetching list of safes..." -ForegroundColor Cyan
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer $bearer_token")
$response = Invoke-RestMethod ($api_url+'/safes') -Method 'GET' -Headers $headers
$response | ConvertTo-Json
Write-Host "List of safes fetched successfully." -ForegroundColor Green

# 4. ---- Create New Safe ----#
function Create-Safe {
    param (
        [string]$safeName,
        [string]$description,
        [string]$bearerToken
    )

    Write-Host "Creating safe '$safeName'..." -ForegroundColor Cyan
    $headers = @{
        "Authorization" = "Bearer $bearerToken"
        "Content-Type"  = "application/json"
    }

    $body = @{
        "safeName" = $safeName
        "description" = $description
        "managingCPM" = $CPM
        "numberOfVersionsRetention" = 5
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "$api_url/Safes" -Method 'POST' -Headers $headers -Body $body
        Add-Content -Path "log.txt" -Value "[$(Get-Date)] Safe '$safeName' created successfully."
        Write-Host "Safe '$safeName' created successfully." -ForegroundColor Green
    } catch {
        Add-Content -Path "log.txt" -Value "[$(Get-Date)] Failed to create safe '$safeName'. Error: $_"
        Write-Host "Failed to create safe '$safeName'. Error: $_" -ForegroundColor Red
        throw $_
    }
}

# 5. ---- Create User Role in Identity ----#
function Create-UserRole {
    param (
        [string]$roleName,
        [string]$bearerToken
    )

    Write-Host "Creating user role '$roleName'..." -ForegroundColor Cyan
    $headers = @{
        "Authorization" = "Bearer $bearerToken"
        "Content-Type"  = "application/json"
        "Accept" = "application/json, text/html"
    }

    $body = @{
        "Name" = $roleName
        "Description" = "Role for $roleName"
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "$tenant_api_url/Roles/StoreRole" -Method 'POST' -Headers $headers -Body $body
        Add-Content -Path "log.txt" -Value "[$(Get-Date)] Role '$roleName' created successfully."
        Write-Host "Role '$roleName' created successfully." -ForegroundColor Green
    } catch {
        Add-Content -Path "log.txt" -Value "[$(Get-Date)] Failed to create role '$roleName'. Error: $_"
        Write-Host "Failed to create role '$roleName'. Error: $_" -ForegroundColor Red
        throw $_
    }
}

# 6. ---- Add Roles & Set Permissions ----#
function Add-SafeMember {
    param (
        [string]$safeName,
        [string]$memberName,
        [string]$memberType,
        [hashtable]$permissions,
        [string]$bearerToken
    )

    Write-Host "Adding member '$memberName' to safe '$safeName'..." -ForegroundColor Cyan
    $headers = @{
        "Authorization" = "Bearer $bearerToken"
        "Content-Type"  = "application/json"
    }

    $body = @{
        "memberName" = $memberName
        "memberType" = $memberType
        "permissions" = $permissions
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "$api_url/safes/$safeName/members" -Method 'POST' -Headers $headers -Body $body
        Add-Content -Path "log.txt" -Value "[$(Get-Date)] Member '$memberName' added to safe '$safeName' successfully."
        Write-Host "Member '$memberName' added to safe '$safeName' successfully." -ForegroundColor Green
    } catch {
        Add-Content -Path "log.txt" -Value "[$(Get-Date)] Failed to add member '$memberName' to safe '$safeName'. Error: $_"
        Write-Host "Failed to add member '$memberName' to safe '$safeName'. Error: $_" -ForegroundColor Red
    }
}

# Main Script Execution
$safeName = Read-Host -Prompt "Enter the name of the safe to create: "
$description = Read-Host -Prompt "Enter the description of the safe: "
$safeList = $response.safes | Select-Object -ExpandProperty safeName

if ($safeList -contains $safeName) {
    Write-Host "Safe '$safeName' already exists. Please choose a different name." -ForegroundColor Yellow
    Add-Content -Path "log.txt" -Value "[$(Get-Date)] Safe '$safeName' already exists."
} else {
    Create-Safe -safeName $safeName -description $description -bearerToken $bearer_token
    $roleName = $safeName +'_Usr'
    Create-UserRole -roleName $roleName -bearerToken $bearer_token

    #Permission sets for the safe
    $permissionsAdmin = @{
        "listAccounts" = $true
        "addAccounts" = $true
        "updateAccountContent" = $true
        "updateAccountProperties" = $true
        "initiateCPMAccountManagementOperations" = $true
        "specifyNextAccountContent" = $true
        "renameAccounts" = $true
        "deleteAccounts" = $true
        "unlockAccounts" = $true
        "manageSafe" = $true
        "manageSafeMembers" = $true
        "viewAuditLog" = $true
        "viewSafeMembers" = $true
        "accessWithoutConfirmation" = $true
        "createFolders" = $true
        "deleteFolders" = $true
        "moveAccountsAndFolders" = $true
        "requestsAuthorizationLevel1" = $true
    }

    $permissionsAuditor = @{
        "listAccounts" = $true
        "viewAuditLog" = $true
        "manageSafeMembers" = $true
        "viewSafeMembers" = $true
        "accessWithoutConfirmation" = $true
    }

    $permissionsUser = @{
        "useAccounts" = $true
        "retrieveAccounts" = $true
        "listAccounts" = $true
        "initiateCPMAccountManagementOperations" = $true
        "specifyNextAccountContent" = $true
    }

    #Individually add Safe Members just incase any failures.
    Add-SafeMember -safeName $safeName -memberName "Privilege Cloud Administrators" -memberType "Role" -permissions $permissionsAdmin -bearerToken $bearer_token
    Add-SafeMember -safeName $safeName -memberName "Privilege Cloud Auditors" -memberType "Role" -permissions $permissionsAuditor -bearerToken $bearer_token
    Add-SafeMember -safeName $safeName -memberName $roleName -memberType "Role" -permissions $permissionsUser -bearerToken $bearer_token
}
