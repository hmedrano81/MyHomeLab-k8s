# Installing Proxmox 

These are just some notes I've collected. Not a full description on how to install Proxmox.

YoutTube Videos:
- [Don’t run Proxmox without these settings!](https://www.youtube.com/watch?v=VAJWUZ3sTSI)

- [Let's Install Proxmox 8.0!: Linux ](https://www.youtube.com/watch?v=sZcOlW-DwrU)

- [Windows 11 on Proxmox -- Virtualization made easy](https://www.youtube.com/watch?v=iq3F5wgn_CI)


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

Official Documentation: [How to install Win11 in Proxmox | Quick guide | And fix problems of network search](https://forum.proxmox.com/threads/how-to-install-win11-in-proxmox-quick-guide-and-fix-problems-of-network-search.136596/)

Virtio-win ISO: [virtio-win.iso](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso)

### Windows Inside program 

- Install the Vmware tools / mount the drive

- Upgrade the driver for the network adapter

- Settings -> Windows insider program - > Link an account

- Set-ExecutionPolicy RemoteSigned

- Enable RDP on Windows 11 Hack [https://www.youtube.com/watch?v=QWeQk-8HwFo](How To Fix Rdp Not Working On Windows 11 Home)

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
