# System Sync Toolkit  
This script is use to sync web content or directory and data such as Server folder and MySQL Database  

## File  
* www-sync (document root sync)
* db-sync (db sycn) - will be updated later  

## Requirement 
* ssh 
* rsync
* root acces (sudo)

## How to
### www-sync

1. sudo su
2. git clone https://gist.github.com/9420620.git ./sys-sync or copy script inside www-sync.sh file
3. If using git cd ./sys-sync
4. chmod +x ./www-sync.sh (same for copy script)
5. ./www-sync.sh
```
NOTE: Before running the script, make sure all the variable setting inside www-sync.sh 
meet with your requirement.
```

### db-sync

1. sudo su
2. git clone https://gist.github.com/9420620.git ./sys-sync or copy script inside www-sync.sh file
3. If using git cd ./sys-sync
4. Create config file
  1. /etc/mysql/db-sync.conf - server config for server where want to sync/download a data (source)
  2. /et/mysql/db-sync-local.conf - local server config (local)
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
