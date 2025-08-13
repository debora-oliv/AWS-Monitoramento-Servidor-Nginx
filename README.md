![AWS](https://img.shields.io/badge/AWS-%23009639.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Nginx](https://img.shields.io/badge/nginx-%23009639.svg?style=for-the-badge&logo=nginx&logoColor=white)
![Bash Script](https://img.shields.io/badge/bash_script-%23009639.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)

# Objetivo
Criar uma VPC com com 2 sub-redes públicas e 2 privadas, uma instância EC2 com script userdata para instalar e configurar o servidor Nginx junto de uma página estática criada usando html e css, um serviço sytemd para verificar a disponibilidade do site a cada 30 segundos e um script bash configurado para enviar notificações ao Discord, graças à integração com um webhook, caso a aplicação não esteja disponível.

# Índice
- [Infraestrutura](#criação-da-infraestrutura)
- [Instância EC2](#criação-da-instância)
- [Script de bootstrap](#script-de-bootstrap-user-data)

# Criação da Infraestrutura

### VPC (Virtual Private Cloud)
Acesse o Console de Gerenciamento da AWS > VPC > Your VPCs > Create VPC.

![Passo 1 - Resources To Create](images/resources-to-create.PNG)

![Passo 2 - Name Tag](images/vpc-name-tag.PNG)
  
![Passo 3 - IPv4 CIDR Block](images/vpc-ipv4-cidr-block.PNG)

![Passo 4 - IPv4 CIDR](images/vpc-ipv4-cidr.PNG)
> Deixe todas as outras opções como padrão

### Internet Gateway
No painel esquerdo, clique em Internet Gateways > Create internet gateway.

![Internet Gateway Name Tag](images/ig-name-tag.PNG)

Selecione o Internet Gateway criado > clique em Actions > Attach to VPC > selecione a VPC criada.

### Sub-rede Pública
No painel esquerdo, clique em Subnets > Create subnet > selecione a VPC criada.

![Passo 1 - Subnet Name](images/sbn-subnet-name.PNG)

![Passo 2 - Availability Zone](images/sbn-availability-zone.PNG)

![Passo 3 - IPv4 VPC CIDR Block](images/sbn-ipv4-vpc-cidr-block.PNG)

![Passo 4 - IPv4 Subnet CIDR Block](images/sbn-ipv4-subnet-cidr-block.PNG)

> Repita o processo para criar a segunda sub-rede alterando apenas o IPv4 Subnet CIDR Block (ex. 10.0.**2**.0/24)

### Sub-rede Privada

> Repita o processo anterior alterando apenas o nome da subrede (ex. subnet-**privada**-01)

### Route Table Pública
No painel esquerdo, clique em Route Tables > clique em Create route table.

![Criar Rota Internet Gateway](images/rt-name.PNG)

Selecione a tabela criada, clique em Edit routes e crie uma nova rota com as informações a seguir:

![Criar Rota Internet Gateway](images/rt-rota-ig.PNG)

Na aba Subnet associations, clique em Edit subnet associations > selecione a(s) sub-rede(s) pública(s)

### Route Table Privada

> Repita o processo anterior alterando apenas o nome da tabela de rota (ex. **Private**-Route-Table") e associando à(s) sub-rede(s) privada(s)

### Security Group
No Console AWS, vá para EC2 > Security Groups > Create Security Group.

![Nomear Security Group](images/sg-name.PNG)

Agora adcione Regras de Entrada (Inbound Rules) para permitir tráfego HTTP e SSH (opcional).

![Regra de Entrada 1 - HTTP](images/sg-http.PNG)
![Regra de Entrada 2 - SSH](images/sg-ssh.PNG)

# Criação da Instância
No Console AWS, vá para EC2 > Instances > Launch Instances.

Crie as seguintes tags e preencha com as informações do seu projeto:

![Tag 1 - Name](images/ec2-tags-names.PNG) 
![Tag 2 - Project](images/ec2-tags-project.PNG) 
![Tag 3 - CostCenter](images/ec2-tags-costcenter.PNG) 

Selecione uma imagem (AMI) Linux e uma versão LTS

![AMI Ubuntu](images/ec2-ami.PNG)

![AMI Ubuntu](images/ec2-ami-version.PNG)

![Tipo de Instância EC2](images/ec2-instance-type.PNG)

![Key Pair](images/ec2-key-pair.PNG)
> Caso não tenha uma key pair, crie e armazene em C:\Users\seu_usuário\\.ssh


Em Network Settings, clique em edit no canto superior direito > selecione a sua VPC e altere para a sub-rede pública de sua preferência:

![Network Settings VPC](images/ec2-vpc.PNG)

![Network Settings Subnet](images/ec2-subnet.PNG)

![Auto Assign IP](images/ec2-auto-assign-public-ip.PNG)

![Security Group](images/ec2-security-group.PNG)

# Script de bootstrap (user-data)

>Para prosseguir faça o download do arquivo [init.sh](scripts/init.sh)

Na seção "Advanced Details", localize o campo "User data" > Choose file > selecione o arquivo init.sh:

![User Data](images/ec2-user-data.PNG)

⚠️ **Nota:** Lembre de alterar a variável DISCORD_WEBHOOK="LINK_DO_SEU_WEEBHOOK"!
