## <div align="center"><b><a href="README.md">Português(BR)</a> | <a href="README_EN.md">English (coming soon)</a></b></div>

<p align="center">
  <img src="assets/arch-logo.png" height=120>
</p>

<div align="center">

[**Início**](#inicio) **|** [**Pré-instalação**](#pré-instalação) **|** [**Instalação**](#instalação) **|** [**Configurar o Sistema**](#configurar-o-sistema) **|** [**Pós-instalação**](#pós-instalação) **|** [**Agradecimentos**](#agradecimentos)

</div>

<div align="center"><h1>🏹 Guia de Instalação do Arch</h1></div>

>**Warning** : As seguintes informações sobre a instalação e configuração do [Arch Linux](https://wiki.archlinux.org/title/Arch_Linux) foram criadas para servirem como **meu guia**, ou seja, isso não é um tutorial, talvez possa dar uma direção ou base sobre algum dos assuntos tratados aqui, mas você não deve seguir esses passos cegamente. Todas as informações que estiverem descritas aqui foram retiradas da [Arch Wiki](https://wiki.archlinux.org/title/ArchWiki:About), portanto acesse caso tenha dúvidas sobre alguma parte da instalação ou configuração. Há outros meios que você também pode tirar dúvidas pela comunidade como nos fóruns ou em grupos, você pode me encontrar no grupo do Arch no telegram 🫡, por exemplo.

>**Note** : Como dito anteriomente, é importante que você acesse e leia a Arch Wiki, pois ela é uma das documentações mais completas do mundo Linux, logo ela irá fornecer os melhores detalhes ou irá direcionar você ao local ideial para conseguir isso. Devo dizer também o local que considero o mais importante para quem deseja utilizar o Arch, o [Dúvidas e Perguntas Frequentes](https://wiki.archlinux.org/title/Frequently_asked_questions), por essa primeira leitura que eu hoje detico parte do meu tempo aprendendo sobre o mundo dessa distribuição Linux. (*Pode chamar de GNU/Linux também 🤷‍♂️... só não me cobre isso, esquisito.*)

---

## Início

### Principais configurações para o sistema:
Antes de iniciar, vale a pena destacar como é o meu hardware e como quero as minhas configurações.

#### Hardware do meu Notebook:
* Intel I5-9300H 
* NVIDIA GTX 1650 Max-Q
* 16G RAM DDR4-2400mhz
* NVME M.2 512G + SSD SATA 512G

#### Configurações Gerais:
- [x] BIOS UEFI e GPT
- [x] Sistema de Arquivos BTRFS
- [x] Criptografia completa do sistema
- [x] UKI (Unified kernel image)
- [x] Systemd-boot
- [x] Secure Boot
- [x] Swapfile para hibernação e ZRAM
- [x] Snapper
- [x] Ambiente GNOME
- [x] Nvidia Prime-Offloading 


>**Observação** : É pelas informações acima que não recomendo usar meus scripts também, eu criei para automatizar minha instalação referente ao que eu uso e também ainda não realizei testes 😂.
---

<!---------------------------------- Pré-instalação --------------------------->
## [Pré-instalação](https://wiki.archlinux.org/title/Installation_guide#Pre-installation)

### Conteúdo:
* [Conectar à internet](#conectar-à-internet)
* [Partição dos discos](#partição-dos-discos)
* [Criptografia de sistema](#criptografia-de-sistema)
* [Formatar as partições](#formatar-as-partições)
* [Montar os sistemas de arquivos](#montar-os-sistemas-de-arquivos)

> **Note** : Esta etapa segue o que está descrito no [Guia de Instalação](https://wiki.archlinux.org/title/Installation_guide), porém costumo fazer somente estas configurações acima, uma vez que não sinto necessidade de, por exemplo, trocar a disposição do teclado ou definir o idioma do sistema, o teclado do meu notebook é padrão `us`, utilizo o sistema em inglês e qualquer outra configuração será necessária refazer após a instalação. Observação: Não deixe de entrar nos links que existem pelo conteúdo, pois eles fornecem informações importantes.

### [Conectar à internet](https://wiki.archlinux.org/title/Installation_guide#Connect_to_the_internet)
>*Dica*: Pule para a próxima configuração caso esteja conectado via cabo ethernet.

Para começar, verifique se a placa de rede (Wi-Fi) está bloqueada pelo hardware e para isso utilize o comando [rfkill](https://wiki.archlinux.org/title/Network_configuration/Wireless#Rfkill_caveat):

```bash
rfkill list
```

Caso o seu wi-fi seja exibido como blocked (bloqueado), realize a seguinte configuração:
```bash
rfkill unblock wifi
```

Em seguida, para conectar seu computador a uma rede sem fio usando o [iwd](https://wiki.archlinux.org/title/Iwd), faça:
```bash
iwctl --passphrase password station device connect SSID
```
>*Dica*: 'password' é a senha da rede a qual deseja conectar o seu dispositivo e se o SSID tiver espaços, coloque entre aspas como em "Wi-Fi do Vizinho". 

### [Partição dos discos](https://wiki.archlinux.org/title/Installation_guide#Partition_the_disks)

#### Layout:
| ################ UEFI com GPT ################# |
|                      :---:                      |

|     Device     |    Size    |  Code |          Name         |
|      :---:     |    :---:   | :---: |         :---:         |
| /dev/nvme0n1p1 |    512MB   |  EF00 |       EFI System      |
| /dev/nvme0n1p2 |  restante  |  8304 | Linux x86-64 root (/) |
|    /dev/sda1   |   total    |  8309 |       Linux LUKS      |

Para modificar a [tabela de partição](https://wiki.archlinux.org/title/Partitioning#Partition_table) de cada disco, pode ser usado alguma ferramenta como [fdisk](https://wiki.archlinux.org/title/Fdisk) ou [gdisk](https://wiki.archlinux.org/title/GPT_fdisk). Exemplo:
```bash
gdisk /dev/nvme0n1
```

Sequência de teclas utilizadas dentro do gdisk:
```console
o
n
[Enter]
[Enter]
+512M
ef00
n
[Enter]
[Enter]
[Enter]
8304
w
```

Repetindo os passos seguindo o layout para `sda`:
```bash
gdisk /dev/sda
```

```console
o
n
[Enter]
[Enter]
[Enter]
8304
w
```

### [Criptografia de sistema](https://wiki.archlinux.org/title/Dm-crypt)

Seguindo com o layout, as partições `nvme0n1p2` e `sda1` serão encriptadas com [dm-crypt](https://wiki.archlinux.org/title/Dm-crypt) e [LUKS](https://pt.wikipedia.org/wiki/Linux_Unified_Key_Setup). Aqui iniciaremos a [encriptação completa do sistema](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system) que se estenderá durante a configuração do sistema.

Para encriptar os dispositivos, faça:
```bash
cryptsetup luksFormat /dev/nvme0n1p2
cryptsetup luksFormat /dev/sda1
```

Em seguida, para utilizar os dispositivos encriptados é necessário desbloqueá-los:
```bash
cryptsetup luksOpen /dev/nvme0n1p2 root
cryptsetup luksOpen /dev/sda1 home-crypt
```

### [Formatar as partições](https://wiki.archlinux.org/title/Installation_guide#Format_the_partitions)

Será utilizado o sistema de arquivos [BTRFS](https://wiki.archlinux.org/title/Btrfs) nessa formatação, somente `nvme0n1p2` será utilizada como root (raiz), `nvme0n1p1` será a [ESP](https://wiki.archlinux.org/title/EFI_system_partition) e para isso precisa ser formatada em [FAT32](https://wiki.archlinux.org/title/FAT).

Para formatar as partições para BTRFS, utilize o comando a seguir:
```bash
mkfs.btrfs --csum xxhash /dev/mapper/root
mkfs.btrfs --csum xxhash /dev/mapper/home-crypt
```

Já para a criação da partição EFI, faça:
```bash
mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1
```

### [Montar os sistemas de arquivos](https://wiki.archlinux.org/title/Installation_guide#Mount_the_file_systems)

Os dispositvos precisam ser montados, o `nvme0n1p2` mapeado em `/dev/mapper/root` deve ser montado em `/mnt`:
```bash
mount /dev/mapper/root /mnt
```

Em seguida, devemos criar os [subvolumes](https://wiki.archlinux.org/title/Btrfs#Subvolumes) como a seguir:

```bash
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@flatpak
btrfs subvolume create /mnt/@libvirt
btrfs subvolume create /mnt/@containerd
btrfs subvolume create /mnt/@machines
btrfs subvolume create /mnt/@docker
btrfs subvolume create /mnt/@swap
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@opt
```

Desabilite o [CoW (Copy-on-Write)](https://wiki.archlinux.org/title/Btrfs#Copy-on-Write_(CoW)) para as subvolumes ou pastas com muita escrita de dados:
```bash
chattr +C /mnt/@libvirt
chattr +C /mnt/@containerd
chattr +C /mnt/@machines
chattr +C /mnt/@docker
chattr +C /mnt/@swap

umount /mnt
```
Agora faça a mesma coisa para o `home-crypt`:
```bash
mount /dev/mapper/home-crypt /mnt

btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@games
btrfs subvolume create /mnt/@VMs
btrfs subvolume create /mnt/@downloads
btrfs subvolume create /mnt/@documents
btrfs subvolume create /mnt/@pictures
btrfs subvolume create /mnt/@videos
btrfs subvolume create /mnt/@cache_home
btrfs subvolume create /mnt/@libvirt_home
btrfs subvolume create /mnt/@docker_home
btrfs subvolume create /mnt/@flatpak_home

chattr +C /mnt/@libvirt_home
chattr +C /mnt/@VMs
chattr +C /mnt/@docker_home

umount /mnt
```

Com exceção da raiz, as pastas onde os subvolumes serão montados devem ser criadas antes, sendo assim, faça:
```bash
mount -o defaults,noatime,compress-force=zstd,subvol=@ /dev/mapper/root /mnt

mkdir /mnt/efi
mkdir /mnt/home
mkdir /mnt/.snapshots
mkdir /mnt/opt
mkdir -p /mnt/var/{log,cache,swap}
mkdir -p /mnt/var/lib/{libvirt,containerd,docker,machines,flatpak}
```

Monte os subvolumes nas pastas:
```
mount -o defaults,noatime,compress-force=zstd,subvol=@home /dev/mapper/home-crypt /mnt/home

mount -o defaults,noatime,compress-force=zstd,subvol=@log /dev/mapper/root /mnt/var/log
mount -o defaults,noatime,compress-force=zstd,subvol=@cache /dev/mapper/root /mnt/var/cache
mount -o defaults,noatime,compress-force=zstd,subvol=@swap /dev/mapper/root /mnt/var/swap
mount -o defaults,noatime,compress-force=zstd,subvol=@libvirt /dev/mapper/root /mnt/var/lib/libvirt
mount -o defaults,noatime,compress-force=zstd,subvol=@machines /dev/mapper/root /mnt/var/lib/machines
mount -o defaults,noatime,compress-force=zstd,subvol=@docker /dev/mapper/root /mnt/var/lib/docker
mount -o defaults,noatime,compress-force=zstd,subvol=@containerd /dev/mapper/root /mnt/var/lib/containerd
mount -o defaults,noatime,compress-force=zstd,subvol=@flatpak /dev/mapper/root /mnt/var/lib/flatpak
mount -o defaults,noatime,compress-force=zstd,subvol=@snapshots /dev/mapper/root /mnt/.snapshots
mount -o defaults,noatime,compress-force=zstd,subvol=@opt /dev/mapper/root /mnt/opt

mount /dev/nvme0n1p1 /mnt/efi
```

>**Note** : O `/dev/mapper/home-crypt` terá continuação após a criação do usuário, pois há subvolumes que deverão ser montados no diretório `$HOME`.

---

<!---------------------------------- Instalação --------------------------->
## [Instalação](https://wiki.archlinux.org/title/Installation_guide#Installation)
### Instalar os pacotes essenciais:

Instalação dos pacotes essenciais no novo diretório raiz, especificado anteriormente, utilizando o [pacstrap](https://wiki.archlinux.org/title/Pacstrap):
```bash
pacstrap /mnt linux linux-headers linux-firmware base base-devel intel-ucode btrfs-progs vim
```

---

<!---------------------------------- Configurar o sistema --------------------------->

## [Configurar o sistema](https://wiki.archlinux.org/title/Installation_guide#Configure_the_system)
### Conteúdo:
* [Chroot](#chroot)
* [Fstab](#fstab)
* [Initramfs](#initramfs)
* [UKI (Unified kernel image)](#uki)
* [Systemd-boot](#sytemd-boot)
* [Secure Boot](#secure-boot)

### [Chroot](https://wiki.archlinux.org/title/Chroot)
Para permitir a transformação  do diretório da instalação no seu diretório raiz atual será utilizado o comando [arch-chroot](https://wiki.archlinux.org/title/Chroot#Using_arch-chroot) no diretório que foi montado a raiz `mnt`:
```bash
arch-chroot /mnt
```

Depois de acessar o diretório com o `chroot`, será configurado o [fuso horário](https://wiki.archlinux.org/title/Time_zone):
```bash
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
```

Seguido pela configuração de [Localização](https://wiki.archlinux.org/title/Installation_guide#Localization):
```bash
sed -i  '/en_US_BR/,+1 s/^#//' /etc/locale.gen
# sed -i  '/pt_BR/,+1 s/^#//' /etc/locale.gen

locale-gen

echo "LANG=en_US.UTF-8" >> /etc/locale.conf
# echo "LANG=pt_BR.UTF-8" >> /etc/locale.conf
```

Configuração do [layout do teclado](https://wiki.archlinux.org/title/Installation_guide#Set_the_console_keyboard_layout):
```bash
echo "KEYMAP=us" >> /etc/vconsole.conf
# echo "KEYMAP=br-abnt2" >> /etc/vconsole.conf
```

Configuração do host e da rede:
```bash
echo "archbtw" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 archbtw.localdomain archbtw" >> /etc/hosts
```

Instalação de alguns pacotes para continuar as configurações e ativação de serviços:
```bash
pacman -S networkmanager reflector acpid acpi snapper sbctl bash-completion git

systemctl enable acpid
systemctl enable NetworkManager
```

>**Note** : Antes de prosseguir eu prefiro fazer algumas configurações como, ativação do swapfile, crypttab e montagem dos subvolumes na `/home` do usuário e portanto farei os seguintes passos:
>>- Administração de usuários
>>- Criação dos subvolumes
>>- Criação das pastas do usuário para os subvolmes
>>- Montagem dos subvolumes nas pastas
>>- Configuração do crypttab
>>- Configuração do swapfile 

Criação de um usuário (leia [Usuários e Grupos](https://wiki.archlinux.org/title/Users_and_groups)):
```bash
useradd -m -G log,http,games,dbus,network,power,rfkill,storage,input,audio,wheel santosbpm
echo "santosbpm ALL=(ALL) ALL" >> /etc/sudoers.d/santosbpm
```

Alteração de senha dos usuários usando o comando `passwd`:
```bash
passwd
passwd santosbpm

# ou senha pré-definida
echo santosbpm:santosbpm | chpasswd
echo root:root | chpasswd
```

Esta etapa é a continuação '[Montar os sistemas de arquivos](#montar-os-sistemas-de-arquivos)', será criado as pastas e montados os subvolumes para o `HOME`:
```bash

mkdir -p ~/{.cache,Games,VirtualBox\ VMs,Downloads,Documents,Pictures,Videos}
mkdir -p ~/.local/share/{libvirt,flatpak,docker}

mount -o defaults,noatime,compress-force=zstd,subvol=@games /dev/mapper/home-crypt /home/santosbpm/Games
mount -o defaults,noatime,compress-force=zstd,subvol=@VMs /dev/mapper/home-crypt /home/santosbpm/VirtualBox\ VMs
mount -o defaults,noatime,compress-force=zstd,subvol=@downloads /dev/mapper/home-crypt /home/santosbpm/Downloads
mount -o defaults,noatime,compress-force=zstd,subvol=@documents /dev/mapper/home-crypt /home/santosbpm/Documents
mount -o defaults,noatime,compress-force=zstd,subvol=@pictures /dev/mapper/home-crypt /home/santosbpm/Pictures
mount -o defaults,noatime,compress-force=zstd,subvol=@videos /dev/mapper/home-crypt /home/santosbpm/Videos
mount -o defaults,noatime,compress-force=zstd,subvol=@cache_home /dev/mapper/home-crypt /home/santosbpm/.cache
mount -o defaults,noatime,compress-force=zstd,subvol=@libvirt_home /dev/mapper/home-crypt /home/santosbpm/.local/share/libvirt
mount -o defaults,noatime,compress-force=zstd,subvol=@flatpak_home /dev/mapper/home-crypt /home/santosbpm/.local/share/flatpak
mount -o defaults,noatime,compress-force=zstd,subvol=@docker_home /dev/mapper/home-crypt /home/santosbpm/.local/share/docker

chown santosbpm:santosbpm -R /home/santosbpm/
```

Nesse momento será feita a configuração da [ZRAM](https://wiki.archlinux.org/title/Zram) e do [SWAPFILE](https://wiki.archlinux.org/title/Swap#Swap_file).
A configuração da zram ficará será automático com o pacote `zram-generator`:
```bash
pacman -S zram-generator

vim /etc/systemd/zram-generator.conf
```
```console
[zram0]
zram-size = 2048
compression-algorithm = zstd
```

Configuração do swapfile será feita de forma manual:
```bash
btrfs filesystem mkswapfile --size 16g /var/swap/swapfile
swapon /var/swap/swapfile

exit
```

Parâmetros do kernel para configuração de [hibernação no swapfile](https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Hibernation) e remoção do [zswap](https://wiki.archlinux.org/title/Zswap) que é habilitada por padrão no kernel:
```bash
echo rd.luks.uuid=$(lsblk -o UUID /dev/nvme0n1p2 | tail -n 1) rd.luks.name=$(lsblk -o UUID /dev/nvme0n1p2 | tail -n 1)=root rd.luks.options=password-echo=no rootflags=subvol=@ resume=UUID=$(findmnt -no UUID -T /mnt/var/swap/swapfile) resume_offset=$(btrfs inspect-internal map-swapfile -r /mnt/var/swap/swapfile) zswap.enabled=0 rw quiet bgrt_disable nmi_watchdog=0 nowatchdog >> /mnt/etc/kernel/cmdline
```
>**Warning** : Foi utilizado outros parâmetros para adiantar a configuração do UKI e desativação do watchdog, mas o conteúdo só será abordado mais para frente.

Configuração [swappiness](https://wiki.archlinux.org/title/Swap#Swappiness):
```bash
echo "vm.swappiness = 10" > /mnt/etc/sysctl.d/99-swappiness.conf
```

Criação do [crypttab](https://wiki.archlinux.org/title/Dm-crypt/System_configuration#crypttab) para desbloquear o sda1:
```bash
echo 'home-crypt         UUID='$(lsblk -o UUID /dev/sda1 | head -n 2 | tail -n 1)'        none       luks' >> /mnt/etc/crypttab
```

### [Fstab](https://wiki.archlinux.org/title/Installation_guide#Fstab)
Para criar um FSTAB utiliza-se a ferramenta `genfstab`:
```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

>**Note** : A partir desse momento será utilizado parte do conteúdo descrito no tópico [Criptografar um sistema inteiro](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system) em especial o conteúdo mencionado em [Encriptação simples da raiz com TPM2 e Secure](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#Simple_encrypted_root_with_TPM2_and_Secure_Boot). Partes desse tópico já foi mencionado quando foi realizado o particionamento, formatação de discos e hibernação.


### [Initramfs](https://wiki.archlinux.org/title/Installation_guide#Initramfs)
Primeiro é necessário entrar novamente no diretório `/mnt`:
```bash
arch-chroot /mnt
```

Adiante é necessário alterar hooks do arquivo [mkinitcpio.conf](https://man.archlinux.org/man/mkinitcpio.conf.5) para aceitar as configurações de discos encriptados:
```bash
HOOKS=(base systemd autodetect modconf kms keyboard sd-vconsole block sd-encrypt filesystems fsck)
```
>**Note**: O systemd foi inserido para adiantar configuração do UKI. Pode ter maius


Adicione também btrfs aos BINARIES:
```bash
BINARIES=(btrfs)
```

### [UKI](https://wiki.archlinux.org/title/Unified_kernel_image)
Primeiro, deverá ser criado o arquivo [cmdline](https://wiki.archlinux.org/title/Unified_kernel_image#Kernel_command_line) com os devidos parâmetros do kernel:
>**Note**: A configuração foi realizado na parte de swapfile e hibernação.
```bash
vim /etc/kernel/cmdline

rd.luks.uuid={$UUID-nvme0n1p2} rd.luks.name={UUID-nvme0n1p2}=root rd.luks.options=password-echo=no rootflags=subvol=@ resume=UUID={UUID-swap-device} resume-offset={swapfile-offset} rw quiet bgrt_disable nmi_watchdog=0 nowatchdog
```

Em seguida, será feito a modificação do arquivo [.preset](https://wiki.archlinux.org/title/Unified_kernel_image#.preset_file):
```bash
vim /etc/mkinitcpio.d/linux.preset

ALL_config="/etc/mkinitcpio.conf"
ALL_kver="/boot/vmlinuz-linux"
ALL_microcode=(/boot/*-ucode.img)

PRESETS=('default' 'fallback')

#default_config="/etc/mkinitcpio.conf"
#default_image="/boot/initramfs-linux.img"
default_uki="esp/EFI/Linux/archlinux-linux.efi"
default_options="--splash=/usr/share/systemd/bootctl/splash-arch.bmp"

#fallback_config="/etc/mkinitcpio.conf"
#fallback_image="/boot/initramfs-linux-fallback.img"
fallback_uki="esp/EFI/Linux/archlinux-linux-fallback.efi"
fallback_options="-S autodetect"
```

Para a [construção](https://wiki.archlinux.org/title/Unified_kernel_image#Building_the_UKIs) de UKIs, execute os comandos:
```bash
mkdir -p efi/EFI/Linux
mkinitcpio -p linux
```

### [Sytemd-boot](https://wiki.archlinux.org/title/Unified_kernel_image#systemd-boot)
A instalação do `systemd-boot` com o `UKI` só precisa de um comando de instalação:
```bash
bootctl install

exit
umount -R /mnt
reboot
```

### [Secure Boot](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot)
Entre como usuário root para fazer a assinatura dos arquivos UKI e do bootloader com [sbctl](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot#sbctl) para funcionamento do secure boot, inicie fazendo o comando a seguir para verifica o status do secure boot:
```bash
sbctl status
```

Criando chaves customizadas:
```bash
sbctl create-keys
```

Para registrar as chaves é necessário o seguinte comando:
```bash
sbctl enroll-keys -m
# sbctl enroll-keys
```
>**Warning** : "Alguns firmwares são assinados e verificados com as chaves da Microsoft quando a inicialização segura (secure boot) está habilitada. A não validação de dispositivos pode bloqueá-los." - Arch Wiki. Por esse motivo utilizo o primeiro comando.

Faça a verificação do Secure Boot novamente:
```bash
sbctl status
```

Verificação para saber quais arquivos devem ser assinados:
```bash
sbctl verify
```

Agora basta assinar os arquivos com o seguinte comando:
```bash
sbctl sign -s /efi/EFI/BOOT/BOOTX64.EFI
sbctl sign -s /efi/EFI/Linux/arch-linux-fallback.efi
sbctl sign -s /efi/EFI/Linux/arch-linux.efi
sbctl sign -s /efi/EFI/systemd/systemd-bootx64.efi
```
---

<!---------------------------------- pós-instalação --------------------------->
## [Pós-instalação](https://wiki.archlinux.org/title/Installation_guide#Post-installation)
### Conteúdo:
* [Horário](#horário)
* [Atualiazação dos espelhos e sistema](#atualiazação-dos-espelhos-e-sistema)
* [Snapper](#snapper)
* [Gnome, ferramentas e serviços](#gnome-ferramentas-e-serviços)
* [Nvidia]()

>**Note** : Faça login com o usuário que foi criado anteriormente.

### Horário
Para atualizar o horário e manter atualizado com um servidor ntp:
```bash
sudo timedatectl set-ntp true
sudo hwclock --systohc
```

### Atualiazação dos espelhos e sistema
Na atualização os mirrors (espelhos) será utilizado a ferramenta [reflector](https://wiki.archlinux.org/title/Reflector) seguida do [pacman -Syu](https://wiki.archlinux.org/title/Pacman#Upgrading_packages) que atualizará o banco de dados e os pacotes do sistema:
```bash
sudo reflector --verbose --latest 10 --sort rate --country Brazil,US --save /etc/pacman.d/mirrorlist

sudo pacman -Syu
```

### [Snapper](https://wiki.archlinux.org/title/Snapper)
#### Configuração:
* Configuração do snapper e do ponto de montagem
* Criando uma nova configuração
* Snapshots manuais

[Configuração do snapper e ponto de montagem](https://wiki.archlinux.org/title/Snapper#Configuration_of_snapper_and_mount_point)
O `/.snapshots` não deve estar montado e nem ser uma pasta, para garantir isso execute os seguintes comandos:
```bash
sudo umount /.snapshots
sudo rm -r /.snapshots
```

[Criando uma nova configuração](https://wiki.archlinux.org/title/Snapper#Creating_a_new_configuration) para `/`:
```bash
sudo snapper -c root create-config /
```

Ao criar uma configuração para o `/` também é criado o subvolume `.snapshot` que será desnecessário:
```bash
sudo btrfs subvolume delete /.snapshots/

```
Recrie o diretório `.snapshots`:
```bash
sudo mkdir /.snapshots
```
Como o subvolume já foi criado e inserido no `fstab` basta utilizar o seguinte comando para remontar:
```bash
sudo mount -a
```

Por útlimo é alterado a [permissão](https://wiki.archlinux.org/title/Permissions#Numeric_method) da pasta `/.snapshots`, isso faz com que todos os snapshots sejam armazenados fora do `@`:
```bash
sudo chmod 750 /.snapshots
```

[Snapshot manual](https://wiki.archlinux.org/title/Snapper#Manual_snapshots):
```bash
sudo snapper -c root create --description "### Configuration Base Arch ###"
```

### Gnome, ferramentas e serviços
>**Note** : Esse é um apanhado de pacotes que sempre utilizo e que considero necessários em minha utilização. Para mais detalhes acesse as [Recomendações Gerais](https://wiki.archlinux.org/title/General_recommendations) e veja a [Lista de Aplicativos](https://wiki.archlinux.org/title/List_of_applications).

Pacotes e ferramentas para o [Gnome](https://wiki.archlinux.org/title/GNOME):
```bash
sudo pacman -S wayland gnome-shell gnome-control-center gnome-tweak-tool gnome-shell-extensions gdm bluez bluez-utils alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber libva-intel-driver libva-utils intel-gpu-tools mesa mesa-utils vulkan-headers vulkan-tools xdg-desktop-portal-gnome xdg-user-dirs xdg-utils nautilus file-roller gnome-console gnome-calculator htop eog gnome-disk-utility dosfstools exfat-utils gvfs-mtp mtpfs neovim neofetch firefox helvum gimp mpv yt-dlp transmission-gtk android-tools android-udev wget networkmanager-openvpn virt-manager qemu-desktop dnsmasq iptables-nft docker docker-compose noto-fonts ttf-hack-nerd ttf-liberation papirus-icon-theme
```

Serviços:
```bash
sudo systemctl enable bluetooth
sudo systemctl enable gdm
sudo systemctl enable libvirtd
sudo systemctl enable docker
sudo systemctl enable snapper-timeline.timer
sudo systemctl enable snapper-cleanup.timer
```

### [Nvidia](https://wiki.archlinux.org/title/NVIDIA)
Pacotes:
```bash
sudo pacman -S nvidia nvidia-utils nvidia-settings nvidia-prime nvtop
```

Configuração do modo [DRM](https://wiki.archlinux.org/title/NVIDIA#DRM_kernel_mode_setting) no Kernel:
```bash
sudo echo "options nvidia_drm modeset=1" >> /etc/etc/modprobe.d/nvidia.conf

sudo printf "blacklist iTCO_wdt\nblacklist iTCO_vendor_support" >> /etc/modprobe.d/watchdog.conf
```
>**Note** : Para adiantar algumas configurações adicionarei mais um arquivo ao `modprobe.d`, o `watchdog.conf` servirá para desativar o watchdog:

[Carregamento antecipado](https://wiki.archlinux.org/title/NVIDIA#Early_loading):
```bash
sudo vim /etc/mkinitcpio.conf
```

```console
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
```

Ativação de serviços de Suspensão e Hibernação da Nvidia:
```bash
sudo systemctl enable nvidia-suspend.service
sudo systemctl enable nvidia-hibernate.service
```

Para finalizar é necessário regenerar o initrams:
```bash
sudo mkinitcpio -p linux
```

>**Warning** : Os hooks do `sbctl` só funcionam para o pacman hooks, então cada vez que for necessário usar o `mkinitcpio` não esqueça de executar o comando `sbctl sign-all` para assinar os novos arquivos. Você pode querer criar um script para fazer isso toda vez que o `mkinitcpio` for executado como a seguir:
```
sudo echo "sbctl sign-all" >> /etc/initcpio/post/uki-sbsign
sudo chmod +x /etc/initcpio/post/uki-sbsign
```

> **Note** : Caso seja necessário, remova a [regra udev](https://wiki.archlinux.org/title/GDM#Wayland_and_the_proprietary_NVIDIA_driver) responsável por desabilitar o [Wayland](https://wiki.archlinux.org/title/Wayland) no [GDM](https://wiki.archlinux.org/title/GDM) quando está sendo utilizado com Nvidia: 
```bash
sudo ln -s /dev/null /etc/udev/rules.d/61-gdm.rules
```

### [Flatpak](https://wiki.archlinux.org/title/Flatpak) e [Paru](https://github.com/morganamilo/paru),

Primeiro será feito a instalação do Flatpak e em seguida utilizaremos ele para instalar mais alguns pacotes:
```bash
sudo pacman -S flaptak
flatpak install obsidian spotify libreoffice obsproject pycharm-community steam telegram flatseal epiphany
```

Também será instalado um [AUR helpers](https://wiki.archlinux.org/title/AUR_helpers), o Paru, em seguinda será feito a instalação de alguns pacotes do repositório do [AUR](https://wiki.archlinux.org/title/Arch_User_Repository):
```bash
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

paru -S gnome-browser-connector-git inxi-git asdf-vm paru-bin
```

### [ZSH](https://wiki.archlinux.org/title/Zsh)
Será realizada a instalação e configuração do ZSH da forma que costumo usar.

Instalação do ZSH, de plugins com [oh-my-zsh](https://ohmyz.sh/) e tema do [powerlevel10k](https://github.com/romkatv/powerlevel10k):
```bash
sudo pacman -S zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
git clone https://github.com/zsh-users/zsh-completions.git ~/.zsh/zsh-completions
echo 'fpath=(~/.zsh/zsh-completions/src $fpath)' >> ~/.zshrc
```

Alteração do o arquivo `.zshrc` para ter as seguintes opções configuradas:
```bash
vim ~/.zshrc
```

```console
ZSH_THEME="powerlevel10k/powerlevel10k"
...
plugins=(zsh-syntax-highlighting zsh-autosuggestions zsh-history-substring-search)
```

Adicionando os alias:
```bash
echo '# Aliases ZSH' >> ~/.zshrc
echo 'alias pf="paru && flatpak update"' >> ~/.zshrc
echo 'alias mu="sudo reflector --verbose --latest 20 --sort rate --country Brazil,US,UK --save /etc/pacman.d/mirrorlist && sudo pacman -Syu"' >> ~/.zshrc
echo 'alias intel="sudo intel_gpu_top"' >> ~/.zshrc
```
Adicionando a linha do caminho para o [asdf](https://asdf-vm.com/):
```bash
echo '# PATH' >> ~/.zshrc
echo '. /opt/asdf-vm/asdf.sh\nexport PATH=/home/santosbpm/.local/bin:$PATH' >> ~/.zshrc
```
Alterando o padrão do shell para o ZSH:
```bash
chsh -s $(which zsh)
```

Instalação do [LunarVim](https://www.lunarvim.org/):
```bash
LV_BRANCH='release-1.2/neovim-0.8' bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)
```

## Agradecimentos
>O desenvolvimento desse guia contou com ajuda de diversas pessoas, dentre as quais eu agradeço:
>> Ao José Rafael e ao Victor Mateus que me tiraram dúvidas e compartilharam comigo seus tempos e conhecimentos para me ajudar. Gostaria que os dois aqui fossem os representantes de toda a comunidade arqueira que ajuda sem pedir nada em troca.

