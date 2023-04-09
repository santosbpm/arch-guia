# Guia de Instalação do Arch (versão de teste)
>**Warning** : As seguintes informações sobre a instalação e configuração do Arch Linux foram criadas para servirem como MEU GUIA, ou seja, isso não é um tutorial e você não deve seguir esses passos cegamente (talvez você consiga ter uma base ou caminho por onde começar). Todas as informações que estiverem descritas aqui foram retiradas da [Arch Wiki](https://wiki.archlinux.org/) portanto, leia caso tenha dúvidas sobre instalação e configuração, procure por grupos (você pode me encontrar no grupo do telegram do Arch 😀) e os fóruns.

>**Note** : É de extrema importância ler a Arch Wiki, ela geralmente terá as informações mais detalhadas ou te direcionará, mas o tópico que julgo que todos deveriam ler antes de usar o Arch é o de [Dúvidas e Perguntas Frequentes](https://wiki.archlinux.org/title/Frequently_asked_questions), por causa desse conteúdo eu gasto meu tempo aprendendo sobre o mundo Linux (Pode chamar de GNU/Linux também, esquisito).

## Principais configurações para o sistema:
* BIOS UEFI + GPT
* NVME 512GB + SSD 512GB (sem RAID)
* dm-crypt + LUKS
* BTRFS
* UKI (Unified kernel image)
* Systemd-boot
* Secure Boot
* Snapper
* Nvidia Prime-Offloading 

## Pré-instalação

### Conteúdo:
* Conectar à internet
* Partição dos discos
* Formatação das partições e criptografia
* Montar os sistemas de arquivos

> **Note** : Esta etapa segue o que está descrito no [Guia de Instalação](https://wiki.archlinux.org/title/Installation_guide), porém, costumo fazer somente essas quatro configurações acima, pois, não sinto necessidade de, por exemplo, trocar a disposição do teclado ou definir o idioma do sistema, o teclado do meu notebook é padrão 'us' e utilizo o sistema em inglês e qualquer outra configuração será necessária refazer após a instalação. Observação: Não deixe de entrar nos links que existem pelo conteúdo, pois, eles fornecem informações importantes.

### Conectar à internet
Dica: Pule para a próxima configuração caso esteja conectado via cabo ethernet.

Para verificar se o Wi-Fi (dispositivo sem fio/wireless device) da máquina está ativado:
`
rfkill
`

Caso esteja listado como bloqueado (blocked), faça:
`
rfkill unblock device
ou
rfkill unblock all
`
Dica: substitua 'device' pelo NOME (NAME), TIPO (TYPE) ou ID do seu Wi-Fi.


Para conectar-se a uma rede sem fio:
`
iwctl --passphrase password station device connect SSID
`

Para saber o nome do seu 'device', digite:
`
device list
`
Dica: Esse nome difere do qual o rfkill fornece, geralmente é wlan ou algo relacionado.

Utilizando os seguintes comandos, é possível exibir as redes disponíveis e seus nomes (SSID):
`
station device scan
station device get-networks
`
Dica: 'password' é a senha da rede a qual deseja conectar-se e se o SSID tiver espaços coloque entre aspas como "Wi-Fi do Vizinho". 


### Partição dos discos

> **Warning** : Essa é uma das partes que tudo vai depender do hardware envolvido e o que deseja-se alcançar. Esse layout foi desenvolvido para acompanhar os meus discos (dispositivos de armazenamento), meu tipo de BIOS e o que desejo configurar na minha máquina, logo, para mais detalhes sobre como proceder nas suas condições leiam [1. 10 Partição dos discos] (https://wiki.archlinux.org/title/Installation_guide_(Portugu%C3%AAs)#Parti%C3%A7%C3%A3o_dos_discos).

Layout a ser usado:
| ################## UEFI com GPT ################# |
|                        :---:                      |

|     Device     |    Size    |  Code |          Name         |
|      :---:     |    :---:   | :---: |         :---:         |
| /dev/nvme0n1p1 |    512MB   |  EF00 |       EFI System      |
| /dev/nvme0n1p2 |  restante  |  8304 | Linux x86-64 root (/) |
|    /dev/sda1   |   total    |  8309 |       Linux LUKS      |

Para modificar a tabela de partição de cada disco pode-se usar alguma ferramenta como [fdisk](https://wiki.archlinux.org/title/Fdisk) ou [gdisk](https://wiki.archlinux.org/title/GPT_fdisk). Exemplo:
`
gdisk /dev/nvme0n1
# Sequência de teclas utilizadas dentro do gdisk
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

gdisk /dev/sda1
# Sequência de teclas utilizadas dentro do gdisk
o
n
[Enter]
[Enter]
[Enter]
8304
w
`

### Formatar as partições e criptografia

Seguindo com o layout, as partições nvme0n1p2 e sda1 serão encriptadas com [dm-crypt](https://wiki.archlinux.org/title/Dm-crypt) e formatadas para [BTRFS](https://wiki.archlinux.org/title/Btrfs), somente nvme0n1p2 será utilizada como root (raiz), e sda1 será a ESP e pra isso precisa ser formatado em [FAT32](https://wiki.archlinux.org/title/FAT).

Inicialmente pode ser feito a [Encriptação das Partições](https://wiki.archlinux.org/title/Dm-crypt/Device_encryption) necessárias com dm-crypt + LUKS:
`
cryptsetup luksFormat /dev/nvme0n1p2
cryptsetup luksFormat /dev/sda1
`

Desbloqueando partição com o mapeador de dispositivos:
`
cryptsetup luksOpen /dev/nvme0n1p2 root
cryptsetup luksOpen /dev/sda1 crypt0
`

Formantar os dispositivos mapeados para serem usados com BTRFS:
`
mkfs.btrfs --csum xxhash /dev/mapper/root
mkfs.btrfs --csum xxhash /dev/mapper/crypt0
`

Criação da partição EFI
`
mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1
`

### Montar os sistemas de arquivos para criar [subvolumes](https://wiki.archlinux.org/title/Btrfs#Subvolumes).

Usando BTRFS no root/nvme0n1p2 e montando em /mnt:
`
mount /dev/mapper/root /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@flatpak
btrfs subvolume create /mnt/@libvirt
btrfs subvolume create /mnt/@containerd
btrfs subvolume create /mnt/@machines
btrfs subvolume create /mnt/@docker
btrfs subvolume create /mnt/@swap
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
`

Antes de desmontar, desabilite o [CoW (Copy-on-Write)](https://wiki.archlinux.org/title/Btrfs#Copy-on-Write_(CoW)) dos subvolumes que tenha muita escrita de dados:
`
chattr +C /mnt/@libvirt
chattr +C /mnt/@containerd
chattr +C /mnt/@machines
chattr +C /mnt/@docker
chattr +C /mnt/@swap
umount /mnt
`

Os mesmos passos para o disco sda com os subvolumes necessários:

`
mount /dev/mapper/home-crypt /mnt
btrfs subvolume create /mnt/@games
btrfs subvolume create /mnt/@libvirt_home
btrfs subvolume create /mnt/@docker_home
btrfs subvolume create /mnt/@flatpak_home
btrfs subvolume create /mnt/@VMs
btrfs subvolume create /mnt/@downloads
btrfs subvolume create /mnt/@documents
btrfs subvolume create /mnt/@pictures
btrfs subvolume create /mnt/@videos
btrfs subvolume create /mnt/@cache_home

chattr +C /mnt/@libvirt_home
chattr +C /mnt/@VMs
chattr +C /mnt/@docker_home
umount /mnt
`
>**Note** : Esse subvolumes serão utilizados após a criação do usuário, pois nela tem pastas que irão dentro do diretório $HOME.

Último estágio, as pastas devem ser criadas antes de montar os subvolumes que devem ser montadas nos seus devidos locais:
`
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@ /dev/mapper/root /mnt

mkdir /mnt/efi
mkdir /mnt/home
mkdir /mnt/.snapshots
mkdir -p /mnt/var/{log,cache,swap}
mkdir -p /mnt/var/lib/{libvirt,containerd,docker,machines,flatpak}


mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@home /dev/mapper/root /mnt/home
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@log /dev/mapper/root /mnt/var/log
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@cache /dev/mapper/root /mnt/var/cache
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@libvirt /dev/mapper/root /mnt/var/lib/libvirt
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@machines /dev/mapper/root /mnt/var/lib/machines
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@docker /dev/mapper/root /mnt/var/lib/docker
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@containerd /dev/mapper/root /mnt/var/lib/containerd
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@flatpak /dev/mapper/root /mnt/var/lib/flatpak
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@swap /dev/mapper/root /mnt/var/swap
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@snapshots /dev/mapper/root /mnt/.snapshots

mount /dev/nvme0n1p1 /mnt/efi
`

## Instalação
### Conteúdo:
* Instalar os pacotes essenciais

Instalação dos pacotes essenciais no novo diretório raiz especificado utilizando o [pacstrap](https://wiki.archlinux.org/title/Pacstrap):
`
pacstrap /mnt linux linux-headers linux-firmware base base-devel intel-ucode zstd btrfs-progs vim
`

## Configurar o sistema
### Conteúdo:
* Chroot
* Fstab
* Initramfs
* UKI (Unified kernel image)
* Systemd-boot
* Secure Boot

### Chroot
Para permitir transformar o diretório da instação no seu diretório raiz atual utilize o comando [chroot](https://wiki.archlinux.org/title/Chroot):
`
arch-chroot /mnt
`

Em um primeiro momento será configurado o [fuso horário](https://wiki.archlinux.org/title/Time_zone):
`
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
`

Seguido pela configuração de idioma:
`
sed -i  '/en_US_BR/,+1 s/^#//' /etc/locale.gen
# sed -i  '/pt_BR/,+1 s/^#//' /etc/locale.gen

locale-gen

echo "LANG=en_US.UTF-8" >> /etc/locale.conf
# echo "LANG=pt_BR.UTF-8" >> /etc/locale.conf
`

Configuração do layout do teclado:
`
echo "KEYMAP=us" >> /etc/vconsole.conf
# echo "KEYMAP=br-abnt2" >> /etc/vconsole.conf
`

Para configuração do host e da rede:
`
echo "archbtw" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 archbtw.localdomain archbtw" >> /etc/hosts
`

Instação de alguns pacotes para o funcionamento do sistema e inicialização:
`
pacman -S networkmanager inetutils reflector acpid acpi acpi_call sof-firmware snapper sbctl bash-completion dialog xdg-user-dirs xdg-utils

systemctl enable acpid
systemctl enable NetworkManager
`

>**Note** : Antes de prosseguir eu prefiro fazer alguns configurações como, ativação do swapfile, crypttab e montagem dos subvolumes na /home do usuário e portanto farei os seguintes passos:
* Criação de um usuário e senha root
* Criação das pastas desse usuário
* Montagem dos subvolumes nas pastas
* Configuração do crypttab
* Configuração do swapfile 

Criação de um usuário e senha root:
`
useradd -m -G log,http,games,dbus,network,power,rfkill,storage,input,audio,wheel santosbpm
echo santosbpm:santosbpm | chpasswd
echo root:root | chpasswd
echo "santosbpm ALL=(ALL) ALL" >> /etc/sudoers.d/santosbpm
`
Criar as pasta do usuário:
`
su santosbpm
xdg-user-dirs-update
mkdir -p /home/santosbpm/{.cache,Games,'VirtualBox VMs'}
mkdir -p /home/santosbpm/.local/share/{libvirt,flatpak,docker}

exit

chown santosbpm:santosbpm -R /home/santosbpm/

mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@games /dev/mapper/home-crypt /home/santosbpm/Games
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@VMs /dev/mapper/home-crypt /home/santosbpm/'VirtualBox VMs'
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@downloads /dev/mapper/home-crypt /home/santosbpm/Downloads
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@documents /dev/mapper/home-crypt /home/santosbpm/Documents
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@pictures /dev/mapper/home-crypt /home/santosbpm/Pictures
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@videos /dev/mapper/home-crypt /home/santosbpm/Videos
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@cache_home /dev/mapper/home-crypt /home/santosbpm/.cache
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@libvirt_home /dev/mapper/home-crypt /home/santosbpm/.local/share/libvirt
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@flatpak_home /dev/mapper/home-crypt /home/santosbpm/.local/share/flatpak
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@docker_home /dev/mapper/home-crypt /home/santosbpm/.local/share/docker

exit
`

Criação do arquivo /etc/crypttab para desbloquear o disco secundário:
`
echo 'home-crypt         UUID='$(lsblk -o UUID /dev/sda1 | tail -n 1)'        none       luks' >> /mnt/etc/crypttab
`
Configuração do swapfile:
`
btrfs filesystem mkswapfile --size 16g /mnt/var/swap/swapfile
swapon /mnt/var/swap/swapfile
`
Parâmetros dos kernel para configuração hibernação:
`
echo "rd.luks.uuid="$(lsblk -o UUID /dev/nvme0n1p2 | tail -n 1) "rd.luks.name="$(lsblk -o UUID /dev/nvme0n1p2 | tail -n 1)"=root rd.luks.options=password-echo=no rootflags=subvol=@ resume=UUID="$(findmnt -no UUID -T /mnt/var/swap/swapfile) "resume_offset="$(btrfs inspect-internal map-swapfile -r /mnt/var/swap/swapfile) "rw quiet bgrt_disable nmi_watchdog=0 nowatchdog" >> /mnt/etc/kernel/cmdline
`
>**Note** : Foi utilizado outros parâmetros para a configuração do UKI.

Configuração swappiness:
`
echo wm.swappiness=10 > /mnt/etc/sysctl.d/99-swappiness.conf
`

### Fstab
Para criar um [FSTAB](https://wiki.archlinux.org/title/Fstab_(Portugu%C3%AAs)) (tabela de partições de disco) utilize a ferramenta genfstab:
`
genfstab -U /mnt >> /mnt/etc/fstab
`

>**Note** : A partir desse momento será utilizado parte do conteúdo descrito no tópico [Criptografar um sistema inteiro](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system) em especial o conteúdo mencionado em [Encriptação simples da raiz com TPM2 e Secure](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#Simple_encrypted_root_with_TPM2_and_Secure_Boot). Partes desse tópico já foi mencionado quando foi realizado o particionamento e formatação de discos.

### Initramfs
Entre com chroot novamente em /mnt:
`
arch-chroot /mnt
`
Alterando os hooks do arquivo /etc/mkinitcpio.conf para aceitar as configurações de disco encriptado com btrfs e o UKI:
`
HOOKS=(base systemd autodetect modconf kms keyboard sd-vconsole block sd-encrypt filesystems fsck)
`
Adicione também btrfs aos BINARIES:
`
BINARIES=(btrfs)
`

### UKI
Primeiro, deverá ser criado o /etc/kernel/cmdline com os devidos parâmetros do kernel:
>**Note**: A configuração foi realizado na parte de swapfile e hibernação.
`
vim /etc/kernel/cmdline

rd.luks.uuid={$UUID-nvme0n1p2} rd.luks.name={UUID-nvme0n1p2}=root rd.luks.options=password-echo=no rootflags=subvol=@ resume=UUID={UUID-swap-device} resume-offset={swapfile-offset} rw quiet bgrt_disable nmi_watchdog=0 nowatchdog
`

Em seguida, será feito a modificação do arquivo .preset:
`
/etc/mkinitcpio.d/linux.preset

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
`

Nessa etapa os comandos são utilizados para construir a UKI ou as UKIs:
`
mkdir -p esp/EFI/Linux
mkinitcpio -p linux
`

### Sytemd-boot
A instalação do systemd-boot com o uki só precisa de um comando de instalação:
`
bootctl install
`

### Secure Boot
A assinatura do arquivo UKI com [sbctl](https://archlinux.org/packages/?name=sbctl) para funcionamento do secure boot. Verifica o status do secure boot:
`
sbctl status
`
Cria chaves customizadas:
`
sbctl create-keys
`
Para registrar as chaves é necessário o seguinte comando:
`
sbctl enroll-keys -m
# sbctl enroll-keys
`
>**Warning** : "Alguns firmwares são assinados e verificados com as chaves da Microsoft quando a inicialização segura (secure boot) está habilitada. A não validação de dispositivos pode bloqueá-los." - Arch Wiki. Por esse motivo utilizo o primeiro comando.

Verifique o Secure Boot novamente:
`
sbctl status
`

Verificação para saber quais arquivos devem ser assinados para que o secure boot funcione:
`
sbctl verify
`

Agora basta assinar os arquivos com o seguinte comando:
`
sbctl sign -s /local/arquivo
`

Sair do ambiente chroot, desmontar as partições e reiniciar a máquina:
`
exit
umount -R /mnt
reboot
`
## Pós-instalação
###Configurações
* Horário
* Atualiazção dos espelhos e sistema
* Snapper e Snapshots
* Gnome, ferramentas e serviços
* Nvidia
* Flatpak e Paru
* ZSH

>**Note** : Inicie com a conta do usu

### Horário
Para atualizar e manter atualizado com um servidor ntp:
`
sudo timedatectl set-ntp true
sudo hwclock --systohc
`
### Atualiazção dos espelhos e sistema
Para atualizar os espelhos (mirrors) será utilizado a ferramenta reflector seguido do pacman -Syu que atualizará o banco de dados e os pacotes do sistema:
`
sudo reflector --verbose --latest 20 --sort rate --country Brazil,US --save /etc/pacman.d/mirrorlist

sudo pacman -Syu
`

### Snapper e Snapshots
Para configurar o Snapper é necessário que o subvolume já deve exista e esteja montado. [Configuração do snapper e ponto de montagem](https://wiki.archlinux.org/title/Snapper#Suggested_filesystem_layout):

`
sudo umount /.snapshots
sudo rm -r /.snapshots/
sudo snapper -c root create-config /
sudo btrfs subvolume delete /.snapshots/
sudo mkdir /.snapshots
sudo mount -o subvol=@snapshots /dev/nvme0n1p2 /.snapshots/
sudo mount -a
sudo chmod 750 /.snapshots
`
Snapshot manual:
`
sudo snapper -c root create --description "### Configuration Base Arch ###"
`

### Gnome, ferramentas e serviços
>**Note** : Esse é um apanhado de pacotes que sempre utilizo e que considero necessários em minha utilização.

Pacotes:
`
sudo pacman -S wayland gnome-shell gnome-control-center gnome-tweak-tool gnome-tweaks gnome-shell-extensions gdm bluez bluez-utils alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber libva-intel-driver libva-utils intel-gpu-tools mesa mesa-utils nvidia nvidia-utils nvidia-settings nvidia-prime nvtop opencl-nvidia opencl-headers vulkan-headers vulkan-tools xdg-desktop-portal-gnome nautilus file-roller gnome-console gnome-calculator gnome-system-monitor htop eog gnome-disk-utility dosfstools exfat-utils gvfs-mtp mtpfs neovim neofetch firefox helvum gimp mpv yt-dlp transmission-gtk android-tools android-udev wget networkmanager-openvpn virt-manager qemu-desktop dnsmasq iptables-nft docker docker-compose noto-fonts ttf-hack-nerd ttf-liberation papirus-icon-theme git
`
Serviços:
`
systemctl enable bluetooth
sudo systemctl enable gdm
# sudo systemctl enable libvirtd
# sudo systemctl enable docker
sudo systemctl enable snapper-timeline.timer
sudo systemctl enable snapper-cleanup.timer
`

### Nvidia
A instalação dos pacotes foram inseridas no conteúdo acima, essa etapa cobre as principais configurações.

Configuração de ativação do drm:
`
sudo echo "options nvidia_drm modeset=1" >> /etc/etc/modprobe.d/nvidia.conf
`
>**Note** : Aproveintado que estou no modprobe vou adicionar mais dois arquivos que não são para configurações da nvidia. Um arquivo é para parar o beep do tty e o outro é para desativação do watchdog.
`
sudo echo "blacklist pcspkr\nblacklist snd_pcsp" >> /etc/modprobe.d/nobeep.conf

sudo echo "blacklist iTCO_wdt\nblacklist iTCO_vendor_support" >> /etc/modprobe.d/watchdog.conf
`

Adicionar os modulos da nvidia em /etc/mkinitcpio.conf:
`
sudo vim /etc/mkinitcpio.conf

MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
`

Para finalizar é regenerado o initrams:

`
sudo mkinitcpio -p linux
`
