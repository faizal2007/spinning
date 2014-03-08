## System Sync Toolkit  
This script is use to sync web content or directory and data such as Server folder and MySQL Database  

**File**  
* www-sync (document root sync)
* db-sync (db sycn) - will be updated later  

**Requirement** 
* ssh 
* rsync
* root acces (sudo)

**How to use** 
www-sync  
1. sudo su
2. git clone https://gist.github.com/9420620.git ./sys-sync or copy script inside www-sync.sh file
3. If using git cd ./sys-sync.sh
4. chmod +x ./www-sync.sh (same for copy script)
5. ./www-sync.sh

NOTE: Before running the script, make sure all the variable setting inside www-sync.sh meet with your requirement.

