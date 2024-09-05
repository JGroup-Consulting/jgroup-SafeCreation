# CyberArk Safe Creation Script
### Author: Dylan Kremers
### Organisation: J Group Consulting
This Script is designed to Create a CyberArk safe into Privilege Cloud & Assign Roles with specific permissions as well as create a new User Role in Identity to then assign the End User into.
# Installation
1. There are two options, you can 1) clone the repo or, 2) copy the connector-diff.ps1 script directly from here.

### Cloning the repo to your workstation
1. Install git

2. Configure your user details in your git client, you may be asked to sign in to git using your Github account the first time you set this up.
In your CLI run these commands:
    ```
    git config --global user.email "<youremail@jgroupconsulting.com.au>"
    git config --global user.name "<username>"
    ```

3. Open a shell and run this command to clone the repo.
    ```
    git clone https://github.com/JGroup-Consulting/jgroup-SafeCreation.git
    ```

# Usage
### Workflow
1. Copy the script to the computer you want to gather a list of checksums from.

2. Run the scipt, and pass the password.
```
.\Jgroup-SafeCreation.ps1 -$Env:cyberark_secret *PASSWORD*
```

3. Prompted to enter Safe name & description
```
Enter the name of the safe to create:
Enter the description of the safe: 
```

4. New Role is created with the following format "SAFENAME_Usr"


5. New Role, Privilege Cloud Administrators & Privilege Cloud Auditors are all addeed to the safe with permissions set


6. All actions are logged into a "log.txt"


7. Verfication
```
Enter the name of the safe to create:
Enter the description of the safe: 
```
# Todo
If people like this tool, and it gets used, we can look to add these features.
- [ ] 
