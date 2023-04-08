# Guia de Instalação do meu Arch (vers)
>**Warning** : As seguintes informações sobre a instalação e configuração do Arch Linux foram criadas para servirem como MEU GUIA, ou seja, isso não é um tutorial e você não deve seguir esses passos cegamente (talvez você consiga ter uma base ou caminho por onde começar). Todas as informações que estiverem descritas aqui foram retiradas da [Arch Wiki](https://wiki.archlinux.org/) portanto, leia caso tenha dúvidas sobre instalação e configuração, procure por grupos (você pode me encontrar no grupo do telegram do Arch 😀) e os fóruns.

>**Note** : É de extrema importância ler a Arch Wiki, ela geralmente terá as informações mais detalhadas ou te direcionará, mas o tópico que julgo que todos deveriam ler antes de usar o Arch é o de [Dúvidas e Perguntas Frequentes](https://wiki.archlinux.org/title/Frequently_asked_questions), por causa desse conteúdo eu gasto meu tempo aprendendo sobre o mundo Linux (Pode chamar de GNU/Linux também, esquisito).

## O sistema seguirá as seguintes configurações:
* BIOS UEFI + GPT
* NVME 512GB + SSD 512GB (sem RAID)
* dm-crypt + LUKS
* BTRFS
* UKI (Unified kernel image)
* Systemd-boot
* Secure Boot
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
```
rfkill
```

Caso esteja listado como bloqueado (blocked), faça:
```
rfkill unblock device
ou
rfkill unblock all
```
Dica: substitua 'device' pelo NOME (NAME) ou ID do seu Wi-Fi.


Para conectar-se a uma rede sem fio:
```
iwctl --passphrase password station device connect SSID
```

Para saber o nome do seu 'device', digite:
```
device list
```
Dica: Esse nome difere do qual o rfkill fornece, geralmente é wlan ou algo relacionado.

Utilizando os seguintes comandos, é possível exibir as redes disponíveis e seus nomes (SSID):
```
station device scan
station device get-networks
```
Dica: 'password' é a senha da rede a qual deseja conectar-se e se o SSID tiver espaços coloque entre aspas como "Wi-Fi do Vizinho". 


### Partição dos discos

> **Warning** : Essa é uma das partes que tudo vai depender do hardware envolvido e o que deseja-se alcançar. Esse layout foi desenvolvido para acompanhar os meus discos (dispositivos de armazenamento), meu tipo de BIOS e o que desejo configurar na minha máquina, logo, para mais detalhes sobre como proceder nas suas condições leiam [1. 10 Partição dos discos] (https://wiki.archlinux.org/title/Installation_guide_(Portugu%C3%AAs)#Parti%C3%A7%C3%A3o_dos_discos).

Layout a ser usado:
| ################## UEFI com GPT ################# |
|                        :---:                      |

|     Device     |    Size    |  Code |          Name         |
|      :---:     |    :---:   | :---: |         :---:         |
| /dev/nvme0n1p1 |    512MB   |  EF00 |       EFI System      |
| /dev/nvme0n1p2 |    16GB    |  8200 | Linux swap (em breve) |
| /dev/nvme0n1p2 |  restante  |  8304 | Linux x86-64 root (/) |
|    /dev/sda1   |   total    |  8309 |       Linux LUKS      |

Para modificar a tabela de partição de cada disco pode-se usar alguma ferramenta como [fdisk](https://wiki.archlinux.org/title/Fdisk) ou [gdisk](https://wiki.archlinux.org/title/GPT_fdisk). Exemplo:
```
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
```

### Formatar as partições e criptografia

Seguindo com o layout, as partições nvme0n1p2 e sda1 serão encriptadas com [dm-crypt](https://wiki.archlinux.org/title/Dm-crypt) e formatadas para [BTRFS](https://wiki.archlinux.org/title/Btrfs), somente nvme0n1p2 será utilizada como root (raiz), e sda1 será a ESP e pra isso precisa ser formatado em [FAT32](https://wiki.archlinux.org/title/FAT).

Inicialmente pode ser feito a [Encriptação das Partições](https://wiki.archlinux.org/title/Dm-crypt/Device_encryption) necessárias com dm-crypt + LUKS:
```
cryptsetup luksFormat /dev/nvme0n1p2
cryptsetup luksFormat /dev/sda1
```

Desbloqueando partição com o mapeador de dispositivos:
```
cryptsetup luksOpen /dev/nvme0n1p2 root
cryptsetup luksOpen /dev/sda1 crypt0
```

Formantar os dispositivos mapeados para serem usados com BTRFS:
```
mkfs.btrfs --csum xxhash /dev/mapper/root
mkfs.btrfs --csum xxhash /dev/mapper/crypt0
```

Criação da partição EFI
```
mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1
```

### Montar os sistemas de arquivos para criar [subvolumes](https://wiki.archlinux.org/title/Btrfs#Subvolumes).

Usando BTRFS no root/nvme0n1p2 e montando em /mnt:
```
mount /dev/mapper/root /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@libvirt
btrfs subvolume create /mnt/@containerd
btrfs subvolume create /mnt/@machines
btrfs subvolume create /mnt/@docker
# btrfs subvolume create /mnt/@swap
btrfs subvolume create /mnt/@home

```

Antes de desmontar, desabilite o [CoW (Copy-on-Write)](https://wiki.archlinux.org/title/Btrfs#Copy-on-Write_(CoW)) dos subvolumes que tenha muita escrita de dados:
```
chattr +C /mnt/@libvirt
chattr +C /mnt/@containerd
chattr +C /mnt/@machines
chattr +C /mnt/@docker
umount /mnt
```

Os mesmos passos para o disco sda com os subvolumes necessários:

```
mount /dev/mapper/crypt0 /mnt
btrfs subvolume create /mnt/@games
btrfs subvolume create /mnt/@libvirt
btrfs subvolume create /mnt/@VMs
btrfs subvolume create /mnt/@docker
btrfs subvolume create /mnt/@flatpak
btrfs subvolume create /mnt/@downloads
btrfs subvolume create /mnt/@documents
btrfs subvolume create /mnt/@pictures
btrfs subvolume create /mnt/@videos
btrfs subvolume create /mnt/@cache_home

chattr +C /mnt/@libvirt
chattr +C /mnt/@VMs
chattr +C /mnt/@docker
umount /mnt
```
>**Note** : Esse subvolumes serão utilizados após a criação do usuário, pois nela tem pastas que irão dentro do diretório $HOME.

Último estágio, as pastas devem ser criadas antes de montar os subvolumes que devem ser montadas nos seus devidos locais:
```
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@ /dev/mapper/root /mnt

mkdir /mnt/efi
mkdir /mnt/home
mkdir -p /mnt/var/{log,cache} # swap
mkdir -p /mnt/var/lib/{libvirt,containerd,docker,machines,flatpak}

mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@home /dev/mapper/root /mnt/home
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@log /dev/mapper/root /mnt/var/log
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@cache /dev/mapper/root /mnt/var/cache
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@libvirt /dev/mapper/root /mnt/var/lib/libvirt
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@machines /dev/mapper/root /mnt/var/lib/machines
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@docker /dev/mapper/root /mnt/var/lib/docker
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@containerd /dev/mapper/root /mnt/var/lib/containerd
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@flatpak /dev/mapper/root /mnt/var/lib/flatpak
# mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@swap /dev/mapper/root /mnt/var/swap

mount /dev/nvme0n1p1 /mnt/efi
```

## Instalação
### Conteúdo:
* Instalar os pacotes essenciais

Instalação dos pacotes essenciais no novo diretório raiz especificado utilizando o [pacstrap](https://wiki.archlinux.org/title/Pacstrap):
```
pacstrap /mnt linux linux-headers linux-firmware base base-devel intel-ucode zstd btrfs-progs vim
```
## Configurar o sistema
### Conteúdo:
* Fstab
* Chroot
* Initramfs
* UKI (Unified kernel image)
* Systemd-boot
* Secure Boot

### Fstab
Para criar um [FSTAB](https://wiki.archlinux.org/title/Fstab_(Portugu%C3%AAs)) (tabela de partições de disco) utilize a ferramenta genfstab:
```
genfstab -U /mnt >> /mnt/etc/fstab
```
### Chroot
Para permitir transformar o diretório da instação no seu diretório raiz atual utilize o comando [chroot](https://wiki.archlinux.org/title/Chroot):
```
arch-chroot /mnt
```
Após entrar com chroot no diretório, será executado pequenas configurações e a instalação de pacotes para prosseguir com essa etapa. 


Em um primeiro momento será configurado o [fuso horário](https://wiki.archlinux.org/title/Time_zone):
```
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
```

Seguido pela configuração de idioma:
```
sed -i  '/en_US_BR/,+1 s/^#//' /etc/locale.gen
# sed -i  '/pt_BR/,+1 s/^#//' /etc/locale.gen

locale-gen

echo "LANG=en_US.UTF-8" >> /etc/locale.conf
# echo "LANG=pt_BR.UTF-8" >> /etc/locale.conf
```

Configuração do layout do teclado:
```
echo "KEYMAP=us" >> /etc/vconsole.conf
# echo "KEYMAP=br-abnt2" >> /etc/vconsole.conf
```

Para configuração do host e da rede:
```
cho "archbtw" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 archbtw.localdomain archbtw" >> /etc/hosts
```
Instação de alguns pacotes para o funcionamento do sistema e inicialização:
```
pacman -S networkmanager inetutils reflector acpid acpi acpi_call sof-firmware snapper bash-completion sbctl

systemctl enable acpid
systemctl enable NetworkManager
```

>**Note** : A partir desse momento será utilizado parte do conteúdo descrito no tópico [Criptografar um sistema inteiro](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system) em especial o conteúdo mencionado em [Encriptação simples da raiz com TPM2 e Secure](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#Simple_encrypted_root_with_TPM2_and_Secure_Boot). Partes desse tópico já foi mencionado quando foi realizado o particionamento e formatação de discos.

### Initramfs
Alterando os hooks do arquivo /etc/mkinitcpio.conf para aceitar as configurações de disco encriptado com btrfs e o UKI:

```
HOOKS=(base systemd autodetect modconf kms keyboard sd-vconsole block sd-encrypt filesystems fsck)
```
Adicione também btrfs aos BINARIES:
```
BINARIES=(btrfs)
```

### UKI
Primeiro, deverá ser criado o /etc/kernel/cmdline com os devidos parâmetros do kernel:

```
vim /etc/kernel/cmdline

rd.luks.uuid={$UUID-nvme0n1p2} rd.luks.name={UUID-nvme0n1p2}=root rd.luks.options=password-echo=no rootflags=subvol=@ rw quiet bgrt_disable nmi_watchdog=0 nowatchdog
```

Em seguida, será feito a modificação do arquivo .preset:
```
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
```

Nessa etapa os comandos são utilizados para construir a UKI ou as UKIs:
```
mkdir -p esp/EFI/Linux
mkinitcpio -p linux
```

### Sytemd-boot
A instalação do systemd-boot com o uki só precisa de um comando de instalaão:
```
bootctl install
```

### Secure Boot
A assinatura do arquivo UKI com [sbctl](https://archlinux.org/packages/?name=sbctl) para funcionamento do secure boot. Verifica o status do secure boot:
```
sbctl status
```
Cria chavs customizadas:
```
sbctl create-keys
```
Para registrar as chaves é necessário o seguinte comando:
```
sbctl enroll-keys -m
# sbctl enroll-keys
```
>**Warning** : "Alguns firmwares são assinados e verificados com as chaves da Microsoft quando a inicialização segura (secure boot) está habilitada. A não validação de dispositivos pode bloqueá-los." - Arch Wiki. Por esse motivo utilizo o primeiro comando.

Verifique o Secure Boot novamente:
```
sbctl status
```

Verificação para saber quais arquivos devem ser assinados para que o secure boot funcione:
```
sbctl verify
```

Agora basta assinar os arquivos com o seguinte comando:
```
sbctl sign -s /local/arquivo
```

