# Server Archive

I have a small server running at home with some plain Debian installation. I like complete control of what is running, how the disks and partions is set up and so on and I like to work mostly in the shell, so things like Proxmox, FreeNAS and such is not for me. But automation and monitoring is a good thing to have, so I have created a few usefull scripts along the way. Maybe this could be of some use to others, but in any case this is as good a place as any to store it. 

The scripts are made to be highly flexible, but they are made to fit into my setup, so I will include a small diagram of my setup to better make sense of them. 

        ┌────────────╮
    ┌─> │   RAIDz1   │
    │   ╰────────────┘
    │                    ┏ Internal 172.0.0.0/16 Bridge / AutoFS
    │ ╼ Passthrough      ┃
    │                    ╿
    │   ┌────────────╮       ┌────────────╮
    └── │    LXD     │ <──── │   Docker   │
        ╰────────────┘       ╰────────────┘
              
              ┢ NFS                ┢ Omada
              ┗ Samba              ┣ Syncthing
                                   ┣ Jellyfin
                                   ┣ Uptime Kuma
                                   ┣ Passbolt
                                   ┣ Wireguard
                                   ┣ Pi-hole
                                   ┣ ...


The main server is set up to run everything in containers. This makes the main system very minimal and by not having to screw around with it constantly, fewer reasons for it to break. Conatiners are much easier to replace/rebuild/backup, especially if you have each container only dealing with one task, this includes the LXD containers. I have a few LXD's, containers and VMs but only included the one that matter here. This is a VM running another debian installation and is setup to only deal with my ZFS array and allow access via NFS and Samba. This can be accessed via the network or by docker using an internal bridge _(much faster)_. 

Both LXD and Docker uses ZFS on the main SSD. Each have their own partition, no redundency, but data volumes for each container is backed up automatically to the RAID Array through one of the scripts included in this repo. 

Some of the data from the RAID Array is also being backed up to an external server via rclone, also via one of the scripts included here. 


### Crond

These scripts are built for this [crond](https://github.com/dk-zero-cool/crond) project. But it can of cause be adapted to something else. 

