# AhsayOBM v6.27.0.0
is a backup agent for connecting to an AhsayOBSR.

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
Using an OBSR provided backupsetid, you can then formulate the
environment variable using the following format: **"PKCS7Padding"**, **Algorithm**,
**Mode**, **Bits**, **Key**.  The available choices for these attributes are as
such:

**PKCS7Padding:** PKCS7Padding  
**Algorithms:** AES, Twofish, TripleDES, "" &nbsp; &nbsp; &nbsp; &nbsp; # An empty string implies no encryption  
**Modes:** ECB, CBC  
**Bits:** 128, 256  
**Key:** {any string of your choosing}  

### Examples
Strong Encryption: `-e BSET-1498585537118=PKCS7Padding,AES-256,ECB,SuperStrongSecretString`  
No Encryption: `-e BSET-1498585537118=PKCS7Padding,-256,,`  


## Paths
+ Application home: **/obm/**
+ User Config: **/root/.obm/**

## Notes
+ Scheduler.sh is prevented from daemonizing.
+ java-x86 and obc_help.pdf have been removed to reduce bloat.
