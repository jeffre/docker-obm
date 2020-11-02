# docker-obm
AhsayOBM is a backup agent that is used to transmit encrypted backups to an
AhsayCBS.


## Build docker image 
    git clone https://github.com/jeffre/docker-obm.git
    cd docker-obm
    make # or `make hotfix` 


## How to use
1. Create a user account with a fully configured backup set in an AhsayCBS.
    * Note the **backup set id** (a 13 digit integer) which will be used later within the name
      of a **BSET-** environment variable.  
    * Ensure that the backup schedule is set to run on a computer named "docker-obm"
1. Choose your encryption (see Setting Encryption below)
1. Run detached: `docker run -d -e USERNAME=jeffre -e PASSWORD=secretpassword -e SERVER=obsr.example.com -e BSET-1498585537118=PKCS7Padding,AES-256,ECB,SuperStrongSecretString --hostname=docker-obm jeffre/obm`


## Setting Encryption
Using a backupset id provided from CBS, you can formulate an
environment variable that specifies how OBM will encrypt your data. The format is:  
+ **BSID-{BACKUPSETID}=PKCS7Padding,{Algorithm}-{Bits},{Mode},{Key}**.

The available choices for the encryption attributes are:  
+ **PKCS7Padding:** PKCS7Padding  
+ **Algorithms:** AES, Twofish, TripleDES, "" &nbsp; &nbsp; &nbsp; &nbsp; # An empty string implies no encryption  
+ **Bits:** 128, 256  
+ **Modes:** ECB, CBC  
+ **Key:** {any string of your choosing}  


### Encryption Examples
+ Strong Encryption: `BSET-1498585537118=PKCS7Padding,AES-256,ECB,ElevenFoughtConstructionFavorite`  
+ No Encryption: `BSET-1468557583616=,,,`  



### Available environment variables
+ `USERNAME`* - OBSR username  
+ `PASSWORD`* - OBSR password  
+ `PROTO` - [http|https]  
+ `SERVER`* - OBSR address  
+ `BSET-{BACKUPSETID}`* - see "Setting Encryption"  
    \* = required


## Noteworthy paths
+ Application logs: **/obm/logs**  
+ User logs: **/root/.obm/logs**  