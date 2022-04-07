---
title:  "Ubuntu - Stuck on Building EVDI kernel module with DKMS"
excerpt: "DKMS error when installing a driver"
tags: "dkms ubuntu evdi"
---

An error I ran into when installing a driver was that the installer got stuck on the `Building EVDI kernel module with DKMS` step. I didn't capture the output so this will be a bit sparse on details.

## Solution

Since there's no easy way to kill the installer at this step (CTRL+C / Break will not work) I checked what DKMS processes were running:

```bash
ps aux | grep dkms
```

I then killed those processes that were related to the installer (should be obvious based on the process name)

```bash
sudo kill -HUP {process ID}
```

For example, if the process ID was 8088:

```bash
sudo kill -HUP 8088
```

Then I re-ran the run file as per the guide and all worked well.
