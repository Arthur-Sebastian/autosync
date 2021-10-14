# AutoSync
## Automatic folder synchronisation tool for linux-based systems utilising existing samba shares.
### (C) Arthur Sebastian Miller 2021

This script is used to synchronise a folder collection between a samba server,
and a machine of your choice.

WARNING: Use with care. This script can delete or overwrite important files if used carelessly.
Once you start a synchronisation session in the wrong direction (upload or download),
you may end up overwriting your folders with their older counterparts.
Make frequent backups!

## Prerequisites
1) a static ip adressed or otherwise statically accessible smb server
2) credential protected, configured samba share to synchronise with
3) sudo access to mount samba share inside a folder as user

## Dependencies:
1) cifs-utils package
2) samba package (server only)

## Usage instructions:

### Configuration

INSIDE THE CONFIG FILE:
1) ip - a server adress or netBios name
2) path - (starting with /) including samba share name pointing at synchronisation root directory (all synchronised folders must be contained within this directory)
3) credentials - name of the file inside /credentials which will be used for samba authentication
4) synclist - name of the list file which will tell the scripts which folder pairs to synchronise between each other
5) localuser - name of the local user the share will be mounted as
6) localgroup - name of the local user group the share will be mounted for (usually the same name as user)

INSIDE THE SYNCLIST FILE:
1) fill the file according to the template in the example file:
2) remote directory paths with respect to synchronisation root directory (see CONFIG FILE point 2)
3) local paths with respect to the root directory
4) every line represents a synchronised folder path pair, separated with a comma (,). Contents of the two will be exchanged during runtime.
5) line scheme: /remotedirectory,/localdirectory

### Launching the script
1) Run 'sync.sh' in a terminal.
2) First the script will print out the config information.
3) Next, grant sudo access for samba share mounting into /remote directory.
4) PROCEED WITH CAUTION! KEEP TRACK OF WHICH DEVICE HAS THE NEWEST COPY!
5) The script will ask whether you want to update the server (up sync) or your local copy with data from the server (down sync). 
6) You can also cancel the synchronisation by typing 'c' and check which copy is the newer one.
7) The script will then proceed to copy-update the files and remove (scrub) files that have been deleted in the recently changed copy.
8) After everything is done, the samba share will be unmounted, and script will exit. Your folders will now be synchronised!
