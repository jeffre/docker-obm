# AhsayOBM v6.29.0.0
backup agent for connecting to an AhsayOBSR


## How to use
1. Create a user account with a backupset and a schedule with your OBSR.
2. Set the "run backup on computers named:" to `*` or give the docker
container a `--hostname` and use that
3. Choose your encryption (see Setting Encryption below)
2. Run: `docker run -e USERNAME=jeffre -e PASSWORD=secretpassword -e SERVER=obsr.example.com -e BSET-1498585537118=PKCS7Padding,AES-256,ECB,SuperStrongSecretString --hostname=docker-obm yoff/obm`


### Available environment variables
+ `USERNAME`* - OBSR username
+ `PASSWORD`* - OBSR password
+ `PROTO` - [http|https]
+ `SERVER`* - OBSR address
+ `BSET-{BACKUPSETID}` - (required) see "Setting Encryption" below
+ `ENABLE_AUA` - if set to TRUE, will run AUA daemon. Be aware, AUA doesnt not
automatically restart after an update.  

\* = required


## Setting Encryption
Using an OBSR provided backupset id, you can formulate an
environment variable that specifies how to encryption its data. The format is:  
+ **BSID-{BACKUPSETID}=PKCS7Padding,{Algorithm}-{Bits},{Mode},{Key}**.

The available choices for the encryption attributes are:  
+ **PKCS7Padding:** PKCS7Padding  
+ **Algorithms:** AES, Twofish, TripleDES, "" &nbsp; &nbsp; &nbsp; &nbsp; # An empty string implies no encryption  
+ **Bits:** 128, 256  
+ **Modes:** ECB, CBC  
+ **Key:** {any string of your choosing}  


### Encryption Examples
+ Strong Encryption: `BSET-1498585537118=PKCS7Padding,AES-256,ECB,ElevenFoughtConstructionFavorite`  
+ No Encryption: `BSET-1468557583616=PKCS7Padding,-256,,`  

## Paths
+ Application home: **/obm/**  
+ User Config: **/root/.obm/**  


## Notes
+ Scheduler.sh is prevented from daemonizing.
+ java-x86 and obc_help.pdf have been removed to reduce bloat.
