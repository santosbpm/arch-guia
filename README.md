## <div align="center"><b><a href="README.md">Português(BR)</a> | <a href="README_EN.md">English (coming soon)</a></b></div>

<p align="center">
  <img src="assets/arch-logo.png" height=120>
</p>

<div align="center">

🏁 [**Início**](#inicio) **|** 📐 [**Pré-instalação**](#pré-instalação) **|** 👨‍🔧[**Instalação**](#instalação) **|** 👨‍💻 [**Configurar o Sistema**](#configurar-o-sistema) **|** 📝 [**Pós-instalação**](#pós-instalação) **|** 🗣️ [**Agradecimentos**](#agradecimentos)

</div>

<div align="center"><h1>🏹 Guia de Instalação do Arch (Beta)</h1></div>

>**Warning** : As seguintes informações sobre a instalação e configuração do Arch Linux foram criadas para servirem como MEU GUIA, ou seja, isso não é um tutorial e você não deve seguir esses passos cegamente (talvez você consiga ter uma base ou caminho por onde começar). Todas as informações que estiverem descritas aqui foram retiradas da [Arch Wiki](https://wiki.archlinux.org/) portanto, leia caso tenha dúvidas sobre instalação e configuração, procure por grupos (você pode me encontrar no grupo do telegram do Arch 😀) e os fóruns.

>**Note** : É de extrema importância ler a Arch Wiki, ela geralmente terá as informações mais detalhadas ou te direcionará, mas o tópico que julgo que todos deveriam ler antes de usar o Arch é o de [Dúvidas e Perguntas Frequentes](https://wiki.archlinux.org/title/Frequently_asked_questions), por causa desse conteúdo eu gasto meu tempo aprendendo sobre o mundo Linux (Pode chamar de GNU/Linux também, esquisito).

>**Observação** : Ainda estou revisando o guia, então é facilmente possível encontrar erros de português ou digitação, isso não torna o guia inutilizável, apenas incompleto (ou mal feito... 🫣).

---

## Início

### Principais configurações para o sistema:
Antes começar vale destacar como é o meu hardware e o que desejo alcançar.

#### Hardware do Notebook:
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

---

<!---------------------------------- Pré-instalação --------------------------->
## [Pré-instalação](https://wiki.archlinux.org/title/Installation_guide#Pre-installation)

### Conteúdo:
* [Conectar à internet](#conectar-à-internet)
* [Partição dos discos](#partição-dos-discos)
* [Criptografia de sistema](#criptografia-de-sistema)
* [Formatar as partições](#formatar-as-partições)
* [Montar os sistemas de arquivos](#montar-os-sistemas-de-arquivos)

> **Note** : Esta etapa segue o que está descrito no [Guia de Instalação](https://wiki.archlinux.org/title/Installation_guide), porém, costumo fazer somente essas configurações acima, pois, não sinto necessidade de, por exemplo, trocar a disposição do teclado ou definir o idioma do sistema, o teclado do meu notebook é padrão 'us' e utilizo o sistema em inglês e qualquer outra configuração será necessária refazer após a instalação. Observação: Não deixe de entrar nos links que existem pelo conteúdo, pois, eles fornecem informações importantes.

### [Conectar à internet](https://wiki.archlinux.org/title/Installation_guide#Connect_to_the_internet)
>*Dica*: Pule para a próxima configuração caso esteja conectado via cabo ethernet.

Utilizando o [rfkill](https://wiki.archlinux.org/title/Network_configuration/Wireless#Rfkill_caveat) para verificar se a placa está bloqueada pelo hardware.
Exibir status atual da placa:

```bash
rfkill list
```

Caso esteja listado como bloqueado (blocked):
```bash
rfkill unblock wifi
```

Para conectar-se a uma rede sem fio usando o [iwd](https://wiki.archlinux.org/title/Iwd_(Portugu%C3%AAs)#iwctl):
```bash
iwctl --passphrase password station device connect SSID
```
>*Dica*: 'password' é a senha da rede a qual deseja conectar-se e se o SSID tiver espaços coloque entre aspas como "Wi-Fi do Vizinho". 

### [Partição dos discos](https://wiki.archlinux.org/title/Installation_guide#Partition_the_disks)

> **Warning** : Essa é uma das partes que tudo vai depender do hardware envolvido e o que deseja-se alcançar. Esse layout foi desenvolvido para acompanhar os meus discos (dispositivos de armazenamento), meu tipo de BIOS e o que desejo configurar na minha máquina, logo, para mais detalhes sobre como proceder nas suas condições entre no link acima.

**Layout**:
| ################ UEFI com GPT ################# |
|                      :---:                      |

|     Device     |    Size    |  Code |          Name         |
|      :---:     |    :---:   | :---: |         :---:         |
| /dev/nvme0n1p1 |    512MB   |  EF00 |       EFI System      |
| /dev/nvme0n1p2 |  restante  |  8304 | Linux x86-64 root (/) |
|    /dev/sda1   |   total    |  8309 |       Linux LUKS      |

Para modificar a [tabela de partição](https://wiki.archlinux.org/title/Partitioning#Partition_table) de cada disco pode-se usar alguma ferramenta como [fdisk](https://wiki.archlinux.org/title/Fdisk) ou [gdisk](https://wiki.archlinux.org/title/GPT_fdisk). Exemplo:
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

Repetindo os passos seguindo o layout para sda:
```bash
gdisk /dev/sda
```

```console
# Sequência de teclas utilizadas dentro do gdisk
o
n
[Enter]
[Enter]
[Enter]
8304
w
```

### [Criptografia de sistema](https://wiki.archlinux.org/title/Dm-crypt_(Portugu%C3%AAs))

Seguindo com o layout, as partições nvme0n1p2 e sda1 serão encriptadas com [dm-crypt](https://wiki.archlinux.org/title/Dm-crypt) e [LUKS](https://pt.wikipedia.org/wiki/Linux_Unified_Key_Setup). Aqui iniciaremos a [encriptação completa do sistema](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system) que se estenderá durante a instalação:

```bash
cryptsetup luksFormat /dev/nvme0n1p2
cryptsetup luksFormat /dev/sda1
```

Desbloqueando as partições:
```bash
cryptsetup luksOpen /dev/nvme0n1p2 root
cryptsetup luksOpen /dev/sda1 crypt0
```

### [Formatar as partições](https://wiki.archlinux.org/title/Installation_guide#Format_the_partitions)


Será utilizado o sistema de arquivos [BTRFS](https://wiki.archlinux.org/title/Btrfs) nessa formatação, somente nvme0n1p2 será utilizada como root (raiz), e nvme0n1p1 será a [ESP](https://wiki.archlinux.org/title/EFI_system_partition) e pra isso precisa ser formatada em [FAT32](https://wiki.archlinux.org/title/FAT).
Para formatar as partições para BTRFS:
```bash
mkfs.btrfs --csum xxhash /dev/mapper/root
mkfs.btrfs --csum xxhash /dev/mapper/crypt0
```

Criação da partição EFI:
```bash
mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1
```

### [Montar os sistemas de arquivos](https://wiki.archlinux.org/title/Installation_guide#Mount_the_file_systems)

Montagem do dispostivo nvme0n1p2 mapeado em /dev/mapper/root em /mnt:
```bash
mount /dev/mapper/root /mnt
```

Criação dos [subvolumes](https://wiki.archlinux.org/title/Btrfs#Subvolumes):

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
```

Antes de desmontar, desabilite o [CoW (Copy-on-Write)](https://wiki.archlinux.org/title/Btrfs#Copy-on-Write_(CoW)) para subvolumes com muita escrita de dados:
```bash
chattr +C /mnt/@libvirt
chattr +C /mnt/@containerd
chattr +C /mnt/@machines
chattr +C /mnt/@docker
chattr +C /mnt/@swap
umount /mnt
```

Repetição da configuração para o sda1 mapeado em /dev/mapper/home-crypt:

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

Último estágio, as pastas devem ser criadas antes de montar os subvolumes que devem ser montadas nos seus devidos locais:
```bash
mount -o defaults,noatime,compress-force=zstd,subvol=@ /dev/mapper/root /mnt

mkdir /mnt/efi
mkdir /mnt/home
mkdir /mnt/.snapshots
mkdir -p /mnt/var/{log,cache,swap}
mkdir -p /mnt/var/lib/{libvirt,containerd,docker,machines,flatpak}

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

mount /dev/nvme0n1p1 /mnt/efi
```

>**Note** : O /dev/mapper/home-crypt terá continuação após a criação do usuário, pois há subvolumes que deverão ser montados no diretório $HOME.

---

<!---------------------------------- Instalação --------------------------->
## [Instalação](https://wiki.archlinux.org/title/Installation_guide#Installation)
### Instalar os pacotes essenciais:

Instalação dos pacotes essenciais no novo diretório raiz especificado utilizando o [pacstrap](https://wiki.archlinux.org/title/Pacstrap):
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
Para permitir transformar o diretório da instalação no seu diretório raiz atual será utilizado o comando [arch-chroot](https://wiki.archlinux.org/title/Chroot#Using_arch-chroot):
```bash
arch-chroot /mnt
```

Em um primeiro momento será configurado o [fuso horário](https://wiki.archlinux.org/title/Time_zone):
```bash
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
```

Seguido pela configuração de [Localização](https://wiki.archlinux.org/title/Installation_guide_(Portugu%C3%AAs)#Localiza%C3%A7%C3%A3o):
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

Para configuração do host e da rede:
```bash
echo "archbtw" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 archbtw.localdomain archbtw" >> /etc/hosts
```

Instalação de alguns pacotes para continuar as configurações:
```bash
pacman -S networkmanager reflector acpid acpi snapper sbctl bash-completion dialog xdg-user-dirs xdg-utils

systemctl enable acpid
systemctl enable NetworkManager
```

>**Warning** : Antes de prosseguir eu prefiro fazer algumas configurações como, ativação do swapfile, crypttab e montagem dos subvolumes na /home do usuário e portanto farei os seguintes passos:
- Administração de usuários
- Criação das pastas do usuário para os subvolmes
- Montagem dos subvolumes nas pastas
- Configuração do crypttab
- Configuração do swapfile 

Criação de um usuário (leia [Usuários e Grupos](https://wiki.archlinux.org/title/Users_and_groups)):
```bash
useradd -m -G log,http,games,dbus,network,power,rfkill,storage,input,audio,wheel santosbpm
echo "santosbpm ALL=(ALL) ALL" >> /etc/sudoers.d/santosbpm
```

Alteração de senha. Para alterar a senha é necessário usar o passwd:
```bash
passwd
passwd santosbpm

# ou senha pré-definida
echo santosbpm:santosbpm | chpasswd
echo root:root | chpasswd

```

Criar as pasta do usuário:
```bash
su santosbpm
xdg-user-dirs-update
mkdir -p /home/santosbpm/{.cache,Games,'VirtualBox VMs'}
mkdir -p /home/santosbpm/.local/share/{libvirt,flatpak,docker}

exit
```

Montar os subvolumes nas pastas criadas anteriormente:
```bash
mount -o defaults,noatime,compress-force=zstd,subvol=@games /dev/mapper/home-crypt /home/santosbpm/Games
mount -o defaults,noatime,compress-force=zstd,subvol=@VMs /dev/mapper/home-crypt /home/santosbpm/'VirtualBox VMs'
mount -o defaults,noatime,compress-force=zstd,subvol=@downloads /dev/mapper/home-crypt /home/santosbpm/Downloads
mount -o defaults,noatime,compress-force=zstd,subvol=@documents /dev/mapper/home-crypt /home/santosbpm/Documents
mount -o defaults,noatime,compress-force=zstd,subvol=@pictures /dev/mapper/home-crypt /home/santosbpm/Pictures
mount -o defaults,noatime,compress-force=zstd,subvol=@videos /dev/mapper/home-crypt /home/santosbpm/Videos
mount -o defaults,noatime,compress-force=zstd,subvol=@cache_home /dev/mapper/home-crypt /home/santosbpm/.cache
mount -o defaults,noatime,compress-force=zstd,subvol=@libvirt_home /dev/mapper/home-crypt /home/santosbpm/.local/share/libvirt
mount -o defaults,noatime,compress-force=zstd,subvol=@flatpak_home /dev/mapper/home-crypt /home/santosbpm/.local/share/flatpak
mount -o defaults,noatime,compress-force=zstd,subvol=@docker_home /dev/mapper/home-crypt /home/santosbpm/.local/share/docker

exit
```

Configuração do [swapfile](https://wiki.archlinux.org/title/Swap#Swap_file):
```bash
btrfs filesystem mkswapfile --size 16g /mnt/var/swap/swapfile
swapon /mnt/var/swap/swapfile
```

Parâmetros do kernel para configuração [hibernação no swapfile](https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Hibernation):
```bash
echo rd.luks.uuid=$(lsblk -o UUID /dev/nvme0n1p2 | tail -n 1) rd.luks.name=$(lsblk -o UUID /dev/nvme0n1p2 | tail -n 1)=root rd.luks.options=password-echo=no rootflags=subvol=@ resume=UUID=$(findmnt -no UUID -T /mnt/var/swap/swapfile) resume_offset=$(btrfs inspect-internal map-swapfile -r /mnt/var/swap/swapfile) zswap.enabled=0 rw quiet bgrt_disable nmi_watchdog=0 nowatchdog >> /mnt/etc/kernel/cmdline
```
>**Note** : Foi utilizado outros parâmetros para adiantar a configuração do UKI, mas o conteúdo só será abordado mais pra frente.

Configuração [swappiness](https://wiki.archlinux.org/title/Swap#Swappiness):
```bash
echo "vm.swappiness = 10" > /mnt/etc/sysctl.d/99-swappiness.conf
```

Nesse momento será feita a configuração da [ZRAM](https://wiki.archlinux.org/title/Zram) e inicialmente será desativado a [zswap](https://wiki.archlinux.org/title/Zswap) que é habilitada por padrão no kernel, mas esse passo já foi efetuado nos parâmetros de kernel acima.

A configuração será feita manualmente executando os seguintes comando:
```
modprobe zram
echo zstd > /sys/block/zram0/comp_algorithm
echo 2G > /sys/block/zram0/disksize
mkswap --label zram0 /dev/zram0
swapon --priority 100 /dev/zram0
```

Criação do [crypttab](https://wiki.archlinux.org/title/Dm-crypt/System_configuration#crypttab) para desbloquear o sda1:
```bash
echo 'home-crypt         UUID='$(lsblk -o UUID /dev/sda1 | tail -n 1)'        none       luks' >> /mnt/etc/crypttab
```

### [Fstab](https://wiki.archlinux.org/title/Installation_guide#Fstab)
Para criar um FSTAB utiliza-se a ferramenta genfstab:
```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

>**Note** : A partir desse momento será utilizado parte do conteúdo descrito no tópico [Criptografar um sistema inteiro](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system) em especial o conteúdo mencionado em [Encriptação simples da raiz com TPM2 e Secure](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#Simple_encrypted_root_with_TPM2_and_Secure_Boot). Partes desse tópico já foi mencionado quando foi realizado o particionamento, formatação de discos e hibernação.


### [Initramfs](https://wiki.archlinux.org/title/Installation_guide_(Portugu%C3%AAs)#Initramfs)
Primeiro é necessário entrar novamente no diretório /mnt:
```bash
arch-chroot /mnt
```

Alterando os hooks do arquivo [mkinitcpio.conf](https://man.archlinux.org/man/mkinitcpio.conf.5) para aceitar as configurações de disco encriptado com btrfs:
```bash
HOOKS=(base systemd autodetect modconf kms keyboard sd-vconsole block sd-encrypt filesystems fsck)
```
>**Note**: O systemd foi inserido para adiantar configuração do UKI.


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

Nessa etapa os comandos são utilizados para [construção](https://wiki.archlinux.org/title/Unified_kernel_image#Building_the_UKIs) de UKIs:
```bash
mkdir -p esp/EFI/Linux
mkinitcpio -p linux
```

### [Sytemd-boot](https://wiki.archlinux.org/title/Unified_kernel_image#systemd-boot)
A instalação do systemd-boot com o uki só precisa de um comando de instalação:
```bash
bootctl install
```

### [Secure Boot](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot)
A assinatura do arquivo UKI e do bootloader com [sbctl](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot#sbctl) para funcionamento do secure boot. O comando a seguir verifica o status do secure boot:
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

Verificação para saber quais arquivos devem ser assinados para que o secure boot funcione:
```bash
sbctl verify
```

Agora basta assinar os arquivos com o seguinte comando:
```bash
sbctl sign -s /local/arquivo
```

Sair do ambiente chroot, desmontar as partições e reiniciar a máquina:
```bash
exit
umount -R /mnt
reboot
```

---

<!---------------------------------- pós-instalação --------------------------->
## [Pós-instalação](https://wiki.archlinux.org/title/Installation_guide_(Portugu%C3%AAs)#P%C3%B3s-instala%C3%A7%C3%A3o)
### Conteúdo:
* [Horário](#horário)
* [Atualiazação dos espelhos e sistema](#atualiazação-dos-espelhos-e-sistema)
* [Snapper](#snapper)
* [Gnome, ferramentas e serviços](#gnome-ferramentas-e-serviços)
* [Nvidia]()

>**Note** : Após reiniciar, faça login com o usuário que foi criado anteriormente.

### Horário
Para atualizar e manter atualizado com um servidor ntp:
```bash
sudo timedatectl set-ntp true
sudo hwclock --systohc
```

### Atualiazação dos espelhos e sistema
Para atualizar os espelhos (mirrors) será utilizado a ferramenta [reflector](https://wiki.archlinux.org/title/Reflector) seguido do [pacman -Syu](https://wiki.archlinux.org/title/Pacman#Upgrading_packages) que atualizará o banco de dados e os pacotes do sistema:
```bash
sudo reflector --verbose --latest 20 --sort rate --country Brazil,US --save /etc/pacman.d/mirrorlist

sudo pacman -Syu
```

### [Snapper](https://wiki.archlinux.org/title/Snapper)
#### Configuração:
* Configuração do snapper e do ponto de montagem
* Criando uma nova configuração
* Snapshots manuais

[Configuração do snapper e ponto de montagem](https://wiki.archlinux.org/title/Snapper#Configuration_of_snapper_and_mount_point)


>**Note** : O ponto de montagem já foi configurado anteriormente quando criamos todos os subvolumes.

[Criando uma nova configuração](https://wiki.archlinux.org/title/Snapper#Creating_a_new_configuration) para /:
```bash
sudo snapper -c root create-config /
```

Ao criar uma configuração para o / também é criado o subvolume .snapshot que será desnessário e pode ser deletado com os seguintes comandos:
```bash
sudo btrfs subvolume delete /.snapshots/

```

Por útlimo é alterado a [permissão](https://wiki.archlinux.org/title/Permissions#Numeric_method) para 750 da pasta /.snapshots, isso faz com que os subvolumes fiquem fora do @:
```bash
sudo chmod 750 /.snapshots
```

[Snapshot manual](https://wiki.archlinux.org/title/Snapper#Manual_snapshots):
```bash
sudo snapper -c root create --description "### Configuration Base Arch ###"
```

### Gnome, ferramentas e serviços
>**Note** : Esse é um apanhado de pacotes que sempre utilizo e que considero necessários em minha utilização.

Pacotes e ferramentas para o [Gnome](https://wiki.archlinux.org/title/GNOME):
```bash
sudo pacman -S wayland gnome-shell gnome-control-center gnome-tweak-tool gnome-tweaks gnome-shell-extensions gdm bluez bluez-utils alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber libva-intel-driver libva-utils intel-gpu-tools mesa mesa-utils vulkan-headers vulkan-tools xdg-desktop-portal-gnome nautilus file-roller gnome-console gnome-calculator htop eog gnome-disk-utility dosfstools exfat-utils gvfs-mtp mtpfs neovim neofetch firefox helvum gimp mpv yt-dlp transmission-gtk android-tools android-udev wget networkmanager-openvpn virt-manager qemu-desktop dnsmasq iptables-nft docker docker-compose noto-fonts ttf-hack-nerd ttf-liberation papirus-icon-theme git
```

Serviços:
```bash
sudo systemctl enable bluetooth
sudo systemctl enable gdm
# sudo systemctl enable libvirtd
# sudo systemctl enable docker
sudo systemctl enable snapper-timeline.timer
sudo systemctl enable snapper-cleanup.timer
```

### [Nvidia](https://wiki.archlinux.org/title/NVIDIA)
A instalação dos pacotes foram inseridas no conteúdo acima, essa etapa cobre as principais configurações.

Pacotes:
```bash`
sudo pacman -S nvidia nvidia-utils nvidia-settings nvidia-prime nvtop xorg-xwayland libxcb egl-wayland
```

Configuração do modo [DRM](https://wiki.archlinux.org/title/NVIDIA#DRM_kernel_mode_setting) no Kernel:
```bash
sudo echo "options nvidia_drm modeset=1" >> /etc/etc/modprobe.d/nvidia.conf
```

>**Note** : Para adiantar algumas configurações adicionarei mais dois arquivos ao modprobe, o primeiro `nobeep.conf` servirá para o TTY parar de emitir som e o segundo `watchdog.conf` servirá para desativar o watchdog:
```bash
sudo printf "blacklist pcspkr\nblacklist snd_pcsp" >> /etc/modprobe.d/nobeep.conf

sudo printf "blacklist iTCO_wdt\nblacklist iTCO_vendor_support" >> /etc/modprobe.d/watchdog.conf
```


[Carregamento antecipado](https://wiki.archlinux.org/title/NVIDIA#Early_loading):
```bash
sudo vim /etc/mkinitcpio.conf
```

```console
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
```

Serviços de Suspensão e Hibernação da Nvidia:
```bash
sudo systemctl enable nvidia-suspend.service
sudo systemctl enable nvidia-hibernate.service
```

Para finalizar é regenerado o initrams:
```bash
sudo mkinitcpio -p linux
```

>**Warning** : Os hooks do sbctl só funcionam para o pacman, então cada vez que for usar o mkinitcpio não esqueça de rodar o comando sbctl sign-all ou escreva um scrpit pra ser usado  após o sbctl ser usado como no exemplo abaixo:
```
echo "sbctl sign-all" >> /etc/initcpio/post/uki-sbsign
chmod +x /etc/initcpio/post/uki-sbsign
```

> **Note** : Caso seja necessário, remova a regra udev responsável por desabilitar o Wayland no GDM: 
```bash
sudo ln -s /dev/null /etc/udev/rules.d/61-gdm.rules
```

### [Flatpak](https://wiki.archlinux.org/title/Flatpak) e [Paru](https://github.com/morganamilo/paru),

Primeiro será feito a instalação do Flatpak e utilizaremos ele para instalar mais alguns pacotes:
```bash
sudo pacman -S flaptak
flatpak install obsidian spotify libreoffice obsproject pycharm-community steam telegram flatseal flameshot
```
Também será instalado um [AUR helpers](https://wiki.archlinux.org/title/AUR_helpers), o Paru. Seguindo será feito a instalação de pacotes do repositório do [AUR](https://wiki.archlinux.org/title/Arch_User_Repository):
```bash
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

paru -S gnome-browser-connector-git inxi-git asdf-vm ventoy-bin paru-bin
```

### [ZSH](https://wiki.archlinux.org/title/Zsh)
Será realizada uma instalação e configuração do ZSH da forma que mais uso.

Instalação do ZSH e de plugins com [oh-my-zsh](https://ohmyz.sh/) e tema [powerlevel10k](https://github.com/romkatv/powerlevel10k):
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
```console
echo '# Aliases ZSH' >> ~/.zshrc
echo 'alias pf="paru && flatpak update"' >> ~/.zshrc
echo 'alias mu="sudo reflector --verbose --latest 20 --sort rate --country Brazil,US,UK --save /etc/pacman.d/mirrorlist && sudo pacman -Syu"' >> ~/.zshrc
echo 'alias intel="sudo intel_gpu_top"' >> ~/.zshrc
```
Adicionando a linha do caminho para o [asdf](https://asdf-vm.com/):
```console
echo '# PATH' >>~/.zshrc
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
O desenvolvimento desse guia contou com ajuda de diversas pessoas, dentre as quais eu agradeço:
Ao José Rafael e o Victor Mateus que me tiraram dúvidas e compartilharam comigo seus tempos e conhecimentos para me ajudar. Gostaria que os dois aqui fossem os representantes de toda a comunidade arqueira que ajuda sem pedir nada em troca.
