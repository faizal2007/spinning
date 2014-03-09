--Test--
# System Sync Toolkit  
This script is use to sync web content or directory and data such as Server folder and MySQL Database.  
This script only sync 1 way meaning that changes only happen on **Destination Server**, **Source Server** will remain the same. 
* **[File](#file "File")**
* **[Requirement](#requirement "Requirement")**
* **[How To](#how-to "How To")**
  * **[www-sync](#www-sync "www-sync")**
  * **[db-sync](#db-sync "db-sync")**

## File  
* www-sync (document root sync)
* db-sync (db sync) - Still in progress .. 

## Requirement 
* ssh 
* rsync
* root acces (sudo)

## How To
### www-sync

1. sudo su
2. git clone https://gist.github.com/9420620.git ./sys-sync or copy script inside www-sync.sh file
3. If using git cd ./sys-sync
4. chmod +x ./www-sync.sh (same for copy script)
5. ./www-sync.sh
```
NOTE: 
Before running the script, make sure all the variable setting inside www-sync.sh meet with your 
requirement.
```

### db-sync

1. sudo su
2. git clone https://gist.github.com/9420620.git ./sys-sync or copy script inside www-sync.sh file
3. If using git cd ./sys-sync
4. Create config file
  * /etc/mysql/db-sync.conf - server config for server where want to sync/download a data (source)
  * /et/mysql/db-sync-local.conf - local server config (local)
5. chmod +x ./db-sync.sh (same for copy script)
6. ./db-sync.sh

**Content inside config file**  
*db-sync.conf*
```text  
[client]
host     = serversource
user     = user
password = test
socket   = /var/run/mysqld/mysqld.sock
```

*db-sync-local.conf*  
```text  
[client]
host     = serverlocal
user     = user    
password = test            
socket   = /var/run/mysqld/mysqld.sock
```