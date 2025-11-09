# Network Systems and Security Lab

- [Ubuntu](#ubuntu)
  - [Set up](#set-up)
- [Windows](#windows)
  - [Set up](#set-up-1)
  - [General Tips](#general-tips)

## Ubuntu

### Set up

If needed install the virtualbox guest additions to use shared folders and the clip board.

```bash
sudo apt-get install virtualbox-guest-additions-iso
```

## Windows

### Set up

1. On the VM install [Chocolatey](https://chocolatey.org/install#individual)

    ```ps1
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    ```

2. Install VirtualBox guest additions via this [guide](https://forums.virtualbox.org/viewtopic.php?t=104811)

    ```ps1
    choco install virtualbox-guest-additions-guest.install
    ```

3. Shut down the VM and share a folder with the VM via VirtualBox with the script `scripts/set_up_<machine>.ps1`
4. Boot up the VM again and connect the shared network folder with the command from [this Comment](https://askubuntu.com/a/52779)

    Share the folder with the following command

    ```ps1
    net use x: \\vboxsrv\<machine>_share
    ```

    Now the folder is accessible under `\\vboxsrv`

### General Tips

Force shut down windows to prevent updating with:

```ps1
shutdown.exe /f /s /t 0
```

Set keyboard layout:

```ps1
Set-WinUserLanguageList -LanguageList "de-DE"
```
