# Secret drive mounter
This daemon is designed to open and mount a drive that is encrypted with LUKS and uses a usb-drive or similar as the key.

## What it actually does
The daemon waits for a pre-configured drive to be inserted,<br>
and then unlocks the encrypted drive with it.<br>
After the key drive is removed, the daemon unmounts and locks the encrypted drive.<br>

## Setting up the key and the encrypted drive
First format the key drive with 2 partitions,<br>
one "data" partition and a partition that is at most 1 MiB in size.<br>
Note: The first partition can be used for anything, since the program only uses the key partition.<br>
After this run the following command and replace ```key-partition``` with the second partition:<br>
```dd if=/dev/random of=key-partition bs=4K```<br>
This will generate a random key and store it on the second partiton, without a file-system.

Next find or create a partition, that will be encrypted.<br>
After this create encrypt it with LUKS <br>
and replace ```key-partition``` with the previously created key partition<br>
and ```enc-partition``` with the encrypted partition:<br>
```cryptsetup luksFormat enc-partition key-partition```<br>

Now you're setup and can configure the program itself.

## Installation
To setup the daemon just run ```./configure```.<br>
Then copy the resulting ./secret-daemon to a directory in $PATH.<br>

