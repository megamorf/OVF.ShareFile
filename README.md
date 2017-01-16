[![Build status](https://ci.appveyor.com/api/projects/status/h6satpvsv33aa9kc/branch/master?svg=true)](https://ci.appveyor.com/project/megamorf/ovf-sharefile/branch/master)

# OVF.ShareFile

## Overview
This is a set of [Pester](https://github.com/pester/Pester) tests designed to test the basic operation of a Citrix ShareFile Storage Zones Controller.
These Pester tests have been packaged into a module according to the [Operation Validation Framework](https://github.com/PowerShell/Operation-Validation-Framework) layout.

### Current tests

* ShareFile SZC Website is up and running

* Monitoring page entries:
  * Registry Permissions Access
  * Storage Location Access
  * IIS User Account Configuration
  * File Cleanup Service Status
  * File Copy Service Status
  * File Upload Service Status
  * ShareFile Connectivity from Management Service
  * ShareFile Connectivity from StorageZones Controller Website
  * ShareFile Connectivity from File Cleanup Service
  * ShareFile Connectivity from File Copy Service
  * Queue SDK Connectivity
  * Proxy Configuration
  * Citrix Cloud Storage Uploader Service

## Example Output
![Example Pester output](/Media/example.png)
