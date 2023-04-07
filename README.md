# Guia de Instalação do Meu Arch

>**Warning** :
As seguintes informações sobre instalação e configurações do Arch Linux foram criadas para serem MEUS GUIAS, ou seja, isso não é um tutorial e você não deve seguir esses passos cegamente (talvez você consiga tirar dúvidas com ele). Todas as informação que estiverem descritas aqui foram retiradas do Guia de Instalação do Arch e do manual das ferramentas, caso tenha dúvidas sobre instalação e configuração do Arch Linux, leia a https://wiki.archlinux.org/, procure por grupos (você pode me encontrar no grupo do telegram do Arch :v ) e fóruns.

## Pré-instalação

### Configuração:
* Conectar à internet
* Partição dos discos

> **Note**: Nessa etapa eu costumo a fazer somente essas duas configuração pois não tenho a necessidade de trocar o layout do teclado e nem definir o idioma do sistema, o teclado do meu notebook é padrão 'us' e utilizo o sistema em inglês, que é o padrão do livecd do archlinux. Para mais detalhesa acesse https://wiki.archlinux.org/title/Installation_guide_(Portugu%C3%AAs)#Pr%C3%A9-instala%C3%A7%C3%A3o.

#### Conectar à internet
Dica: Caso esteja conectado via cabo ethernet você pode pular essa etapa.

Primeiro verifique se dispositivo sem fio (Wi-Fi) da sua máquina está ativado:
```
rfkill
```


Caso esteja listado como bloqueado, faça: 
```
rfkill unblock device
```
> **Note**: troque 'device' pelo nome do seu dispositivo sem fio.


Para conectar-se ao seu dispositivo sem fio em uma rede:
```
iwctl --passphrase password station device connect SSID
```


Para saber o nome do seu 'device', digite:
```
device list
```


Utilize os seguintes comandos para exibir as redes disponíveis e seus nomes (SSID):
```
station device scan
station device get-networks
```
Obersevações: 'password' é a senha da rede que você deeseja conectar-se e se o SSID tiver espaços coloque entre aspas como "Wi-Fi do Vizinho". 


#### Partição dos discos

Essa é uma das partes que tudo vai depender dos seus dispositivos, tipo de BIOS e como você deseja separar as suas partições. Para esse guia irei utilizar um NVME 512GB e um SSD 512GB com seguinte layout:
   
| ############### UEFI com GPT ############# |
|                     :---:                  |

| Device |    Size    |  Code |          Name         |
|  :---: |    :---:   | :---: |         :---:         |
| nvme_1 |    512MB   |  EF00 |       EFI System      |
| nvme_2 |    16GB    |  8200 | Linux swap (em breve) |
| nvme_2 |  restante  |  8304 | Linux x86-64 root (/) |
| ssd_1  |   total    |  8309 |       Linux LUKS      |

Use alguma ferramenta como fdisk ou gdisk para modificar a tabela de partição. Exemplo:
```shell
gdisk /dev/nvme0n1

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

#### Formatar as partições

