# F5 Utilites

This is a repository containing a few F5 shell scripts I've created for configuration audits

  * tls_audit.bash
    - This script sorts virtuals into those using only TLS1.2 historically, and those using 1.0 and 1.1.  Easily modified to set thresholds for number of historical connections.   
  * orphaned_object.bash
    - Takes user input to determine the type of object to audit, scans configuration files in all partitions, and provides output for cleanup
  * cipher_finder.bash
    - Locates ssl profiles out of standard
  * Active_cipher_finder.bash
    - Checks statistics for ssl profiles to determine historical usage of specified cipher
  * node_decom_arpfailed.bash
    - Finds nodes that are not available on the network and generates tmsh commands to allow for decom