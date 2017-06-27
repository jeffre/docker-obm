# AhsayOBM v6.29.0.0
backup agent for connecting to an AhsayOBSR

## How to use
1. Create a user account with a backupset and a schedule. Be sure to give the schedule a hostname (eg docker-obm).
3. Choose your encryption (see Setting Encryption below)
2. Run: `docker run -e USERNAME=jeffre -e PASSWORD=secretpassword -e SERVER=obsr.example.com -e BSET-1498585537118=PKCS7Padding,AES-256,ECB,SuperStrongSecretString --hostname=docker-obm yoff/obsr`

### Available environment variables
+ `USERNAME` (required)
+ `PASSWORD` (required)
+ `HOST`  (required)
+ `BSET-{BACKUPSETID}`   (required)
+ `LANG`
+ `PROTOCOL` (defaults to https)

## Setting Encryption
Using an OBSR provided backupset id, you can formulate an
environment variable that specifies how to encryption its data. The format is: **BSID-{BACKUPSETID}=PKCS7Padding,{Algorithm},{Mode},{Bits},{Key}**.  The available choices for the encryption attributes are:

+ **PKCS7Padding:** PKCS7Padding  
+ **Algorithms:** AES, Twofish, TripleDES, "" &nbsp; &nbsp; &nbsp; &nbsp; # An empty string implies no encryption  
+ **Modes:** ECB, CBC  
+ **Bits:** 128, 256  
+ **Key:** {any string of your choosing}  

### Examples
Strong Encryption: `BSET-1498585537118=PKCS7Padding,AES-256,ECB,ElevenFoughtConstructionFavorite`  
No Encryption: `BSET-1468557583616=PKCS7Padding,-256,,`  


## Paths
+ Application home: **/obm/**  
+ User Config: **/root/.obm/**  

## Notes
+ Scheduler.sh is prevented from daemonizing.
+ java-x86 and obc_help.pdf have been removed to reduce bloat.
