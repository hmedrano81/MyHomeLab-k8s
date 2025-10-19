# Proxmox

> Note:
>
> These are just some notes I've collected. Not a full description on how to install Proxmox.

Offical documentation:

- [Proxmox: High Availability](https://pve.proxmox.com/wiki/High_Availability)

YoutTube Videos:

- [Let's Install Proxmox 8.0!: Linux ](https://www.youtube.com/watch?v=sZcOlW-DwrU)

- [Don’t run Proxmox without these settings!](https://www.youtube.com/watch?v=VAJWUZ3sTSI)

- [ProxMox High Availability Cluster!](https://www.youtube.com/watch?v=08b9DDJ_yf4)

- [Windows 11 on Proxmox -- Virtualization made easy](https://www.youtube.com/watch?v=iq3F5wgn_CI)

## Installing Proxmox

### Install using a USB Flash Drive

- Download the latest version of the Proxmox VE ISO Installer: [Proxmox: Downloads](https://www.proxmox.com/en/downloads).

- Flash a USB drive using a software such as [Balena Etcher](https://etcher.balena.io/)

- Connect the USB drive in the the machine/server, power it up and enter in the BIOS to make sure it will boot using the USB.

- Select the option with Graphical interface

    <img src="images/image-03.png" alt="drawing" width="600"/>

- Adjust the fixed IP address and finish the set up.

- Using your browser, open the IP assigned, followed by the port 8006 [https://<proxmox_ip_address>:8006](https://<proxmox_ip_address>:8006).

### Upgrade Proxmox

#### Versions 9.x

- Find out the version of your Proxmox server

  ```sh
  pveversion -v
  ```

- Update Repository Sources. Change from Bookworm (PVE 8) to Trixie (PVE 9):

  ```sh
  nano /etc/apt/sources.list
  # Old (comment out or remove):
  # deb http://ftp.debian.org/debian bookworm main contrib
  # deb http://ftp.debian.org/debian bookworm-updates main contrib
  # deb http://security.debian.org/debian-security bookworm-security main contrib

  # New:
  deb http://ftp.debian.org/debian trixie main contrib
  deb http://ftp.debian.org/debian trixie-updates main contrib
  deb http://security.debian.org/debian-security trixie-security main contrib
  ```

- Update Proxmox Repository. For no-subscription repository.

  ```sh
  nano /etc/apt/sources.list.d/pve-no-subscription.list

  # New:
  deb http://download.proxmox.com/debian/pve trixie pve-no-subscription
  ```

- Perform the Upgrade

  ```sh
  # Update package lists
  apt update

  # Check for held packages
  apt-mark showhold

  # Start the upgrade
  apt dist-upgrade
  ```

- Handle Configuration Questions. During upgrade, you'll be prompted about configuration files. Generally:

  - Keep your current configuration for network interfaces
  - Accept new configurations for system files unless you have specific customizations

- Reboot

  ```sh
  reboot
  ```

- Post-installation, verify Installation

  ```sh
  pveversion -v
  cat /etc/debian_version  # Should show Trixie/Sid
  ```

- Check Services

  ```sh
  systemctl status pveproxy pvedaemon pve-cluster
  ```

- Update VM/CT Configurations. Some VMs might need configuration updates for new features or compatibility.

- Clean Up
  ```sh
  apt autoremove
  apt autoclean
  ```

#### Versionx 8.x

- Disable the Enterprise Repository.

  ```sh
  vi /etc/apt/sources.list.d/pve-enterprise.list
  # Comment this line
  # deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise

  vi /etc/apt/sources.list.d/ceph.list
  # Comment this line
  # deb https://enterprise.proxmox.com/debian/ceph-quincy bookworm enterprise
  ```

- Enable the No-Subscription Repository

  ```sh
  echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" | tee /etc/apt/sources.list.d/pve-no-subscription.list
  ```

- Find out the version of your Proxmox server

  ```sh
  pveversion -v
  ```

    <img src="images/image-15.png" alt="drawing" width="600"/>

- Run these two commands. This will update all packages to the latest version of that major version.
  ```sh
  apt update
  apt full-upgrade
  ```

### High availability set up with two nodes

YouTube video: [ProxMox High Availability Cluster!](https://www.youtube.com/watch?v=08b9DDJ_yf4)

- Edit the `nano /etc/hosts` and add the name of the other host, on each server.

    <img src="images/image-04.png" alt="drawing" width="600"/>

#### On your **First Proxmox node**:

- Go to Datacenter -> Cluster -> Create Cluster.

    <img src="images/image-05.png" alt="drawing" width="1100"/>

- Enter a name for the new Cluster and the network card to communicate with the second node.

    <img src="images/image-06.png" alt="drawing" width="1100"/>

- Go to Datacenter -> Cluster -> Select the cluster created -> Join information.

    <img src="images/image-07.png" alt="drawing" width="1100"/>

- Copy the information shown.

#### On your **Second Proxmox node**:

- Go to Datacenter -> Cluster -> Join Cluster.

    <img src="images/image-08.png" alt="drawing" width="1100"/>

- Paste the Join Information, add the IP address of the first node and enter its password.

    <img src="images/image-09.png" alt="drawing" width="1100"/>

    <img src="images/image-10.png" alt="drawing" width="1100"/>

- After a few seconds, the two nodes will be shown unther the Cluster.

    <img src="images/image-11.png" alt="drawing" width="1100"/>

#### Configuring a ZFS Volume

> Note: We are going to configure a CFS mirror to enable high availability in the cluster.
>
> The ZFS pools must have identical names. Otherwise, if a VM is migrated to a new node it won't know what path it needs to follow to access its virtual disk

- Make sure in both nodes its own storage has is configured and healthy. Go to Datacenter -> `<Proxmox_first_node>` -> Disks.

    <img src="images/image-12.png" alt="drawing" width="1100"/>

    <img src="images/image-13.png" alt="drawing" width="1100"/>

- Go to Datacenter -> `<Proxmox_first_node>` -> Disks -> ZFS -> Create ZFS.

    <img src="images/image-14.png" alt="drawing" width="1100"/>

  - `Name: HL-Storage`
  - `RAID Level: Mirror`
  - Make sure the `Add Storage` checkbox is selectec.
  - Select the disks you'd like to add.

WORK IN PROGRESS

HIGH AVAILABILITY REQUIRES THREE NODES

...

...

...

...

...

...

...

## Settings for each VM

- OS:

  - Guest OS type: Microsoft Windows (Required for Windows 11)
  - Guest OS Version: 11/2022/2025 (Required for Windows 11)
  - Add additional driver for VirtIO: Checked (Required for Windows 11)
  - Select local storage and the virtio ISO (Required for Windows 11)

- System:

  - Machine: q35 (UEFI)
  - BIOS: OVMF (UEFI)
  - Add EFI Disk: (Not required for Windows 11)
    § EFI Storage: local-lvm
  - Add TPM: Checked. (Required for Windows 11)

- Disks:

  - Bus/Device: SCSI
  - Cache: Write back (Recommended for Windows 11)
  - Enable Discard (Recommended for Windows 11)
  - Enable IO thread (Recommended for Windows 11)
  - SSD emulation (Recommended for Windows 11)
  - Storage: local-lvm
  - Disk size: 60 GiB (Thin prevision by default)

- CPU:

  - Sockets: 1
  - Cores: 8
  - Types: x86-64-v2-AES (New default)

- Memory:

  - Memory: 16384 MiB
  - Advanced -> Balloning Device: Uncheck (Not recommended , as it will allocate all the memory to the VM)

- Network:
  - Bridge: vmbr0
  - Mode: Intel E1000

## Windows install (Virtual Machine)

Official Documentation:

- [How to install Win11 in Proxmox | Quick guide | And fix problems of network search](https://forum.proxmox.com/threads/how-to-install-win11-in-proxmox-quick-guide-and-fix-problems-of-network-search.136596/)

- [How to Install Windows 11 on M1/M2 Mac with VMWARE Fusion 13 (NEW)](https://www.youtube.com/watch?v=srOty2jflF4)

Download the ISO: - [x86](https://www.microsoft.com/en-us/software-download/windowsinsiderpreviewiso) - [ARM](https://www.microsoft.com/en-us/software-download/windowsinsiderpreviewarm64)

Download Virtio-win ISO: [virtio-win.iso](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso)

### Windows Inside program

- Install the Vmware tools / mount the drive

- Upgrade the driver for the network adapter

- Settings -> Windows insider program - > Link an account

- Set-ExecutionPolicy RemoteSigned

## Enable RDP on Windows 11 Hack

[https://www.youtube.com/watch?v=QWeQk-8HwFo](How To Fix Rdp Not Working On Windows 11 Home)

    > Note: [How to Install Windows 11 on M1/M2 Mac with VMWARE Fusion 13 (NEW)](https://www.microsoft.com/en-us/software-download/windowsinsiderpreviewiso)

## Ubuntu install (Virtual Machine)

- Install Ubuntu Desktop 24.04 TLS and set IP address udring install
- Enable SSH
  ```sh
  sudo apt update
  sudo apt install nala -y
  sudo nala install openssh-server -y
  sudo systemctl start ssh
  sudo systemctl enable ssh
  sudo systemctl status ssh
  sudo nala install ufw -y
  sudo ufw allow ssh
  sudo ufw enable
  sudo ufw status

  # Then from your laptop
  ssh-copy-id -i homelab.pub hmedrano@192.168.86.7
  ```
- Enable RDP Server
  ```sh
  sudo nala install xrdp -y
  sudo systemctl start xrdp
  sudo systemctl enable xrdp
  sudo systemctl status xrdp
  sudo ufw allow 3389
  sudo ufw enable
  sudo ufw status
  ```
- Upgrade the system

  ```sh
  sudo nala update
  sudo nala upgrade -y
  sudo reboot now
  ```

- Install curl

  ```sh
  sudo nala install curl -y
  ```

- Set up automatic upgrades

  ```sh
  sudo nala install unattended-upgrades
  systemctl status unattended-upgrades
  ```

  ```sh
  sudo vi /etc/apt/apt.conf.d/50unattended-upgrades
  # Remove the comment for the line "${distro_id}:${distro_codename}-updates";
  ```

    <img src="images/image-01.png" alt="drawing" width="600"/>

  ```sh
  sudo vi /etc/apt/apt.conf.d/20auto-upgrades
  APT::Periodic::AutocleanInterval "7";
  ```

     <img src="images/image-02.png" alt="drawing" width="600"/>

  ```sh
  sudo systemctl restart unattended-upgrades.service
  sudo systemctl status unattended-upgrades.service
  sudo unattended-upgrades --dry-run --debug
  sudo unattended-upgrades
  ```
