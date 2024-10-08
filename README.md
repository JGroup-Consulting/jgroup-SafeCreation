# CyberArk Safe Creation Script
### Author: Dylan Kremers
### Organisation: J Group Consulting
This Script is designed to Create a CyberArk safe into Privilege Cloud & Assign Roles with specific permissions as well as create a new User Role in Identity to then assign the End User into.

## Requirements
### API Account:
1. Need a CyberArk API onboarding service user account
2. API service user requires the following account permissions:
    - [ ] Is service user
    - [ ] Is OAuth Confidential Client
3. Needs the following CyberArk Roles
    - [ ] System Administrator
    - [ ] Privilege Cloud Administrators
    - [ ] Create a New Role Called "API Users" and add to the "Administrative Rights" Read Only User Management & User Management 
    - [ ] Assign the new API user to the API Users role
4. Ensure that Privilege Cloud Administrators are members of current safes for validation.

### Environment:
1. Tenant ID Value
2. Subdomain Value
3. CPM Name

Update The Client Variables in the Script before running

# Usage
### Workflow

1. Download the Script
2. Open a Terminal in the relevant location as the script
3. Set the password for the API User using the Variable
```
$Env:cyberark_secret = "PASSWORD"
```  
4. Run the script.
```
.\Jgroup-SafeCreation.ps1
```
5. Prompted to enter Safe name & description
```
Enter the name of the safe to create:
Enter the description of the safe: 
```
6. A New Role is created in CyberArk Identity with the following format "SAFENAME_Usr"
7. New Role, Privilege Cloud Administrators & Privilege Cloud Auditors are all added to the safe with permissions set
8. All actions are logged into a "log.txt"
9. Verification
    ```
    1. Check the log.txt output for any errors
    2. Verify that the Safe was created in Privilege Cloud
    3. Verify the Roles are added to the safe
    4. Verify the permissions for each role are correct
    5. Verify in CyberArk Identity > Roles that there is a new role = SAFENAME_Usr
    ```
    
7. Next steps - add the relevant users that need to use the accounts in the safe to the new User role manually in the PVWA
