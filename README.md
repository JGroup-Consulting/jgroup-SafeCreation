# CyberArk Safe Creation Script
### Author: Dylan Kremers
### Organisation: J Group Consulting
This Script is designed to Create a CyberArk safe into Privilege Cloud & Assign Roles with specific permissions as well as create a new User Role in Identity to then assign the End User into.

## Requirements
### API Account:
1. Need a CyberArk API onboarding service user account
2. API service user requires the following account permissions:
    - [ ] Is service user
    - [ ] Is OAuth confidential Client
3. Needs the following CyberArk Roles
    - [ ] System Administrator
    - [ ] Privilege Cloud Administrators
    - [ ] Create a New Role Called "API Users" and add to the "Administrative Rights" Read Only User Management & User Management 
    - [ ] Assign the new API user to the API Users role
4. Ensure that Privilege Cloud Administrators is member of current safes for validation.

### Enviroment:
1. Tenant ID Value
2. Subdomain Value
3. CPM Name

Update The Client Variables in the Script before running

# Usage
### Workflow

1. Run the scipt, and pass the password.
```
.\Jgroup-SafeCreation.ps1 -$Env:cyberark_secret *PASSWORD*
```

2. Prompted to enter Safe name & description
```
Enter the name of the safe to create:
Enter the description of the safe: 
```

3. New Role is created in CyberArk Identity with the following format "SAFENAME_Usr"


4. New Role, Privilege Cloud Administrators & Privilege Cloud Auditors are all addeed to the safe with permissions set


5. All actions are logged into a "log.txt"


6. Verfication
    ```
    1. Check the log.txt output for any errors
    2. Verify that the Safe was created in Privilege Cloud
    3. Verify the Roles are added to the safe
    4. Verify the permissions for each role are correct
    5. Verify in CyberArk Identity > Roles that there is a new role = SAFENAME_Usr
    ```
    
7. Next steps - add the revelent users that need to use the accounts in the safe to the new User role
