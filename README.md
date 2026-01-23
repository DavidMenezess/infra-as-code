# Projeto Terraform - Infra AWS

Este repositório provisiona uma infraestrutura simples na AWS usando Terraform
e um workflow de GitHub Actions para aplicar e destruir a infra sob demanda.

## O que este projeto cria

- 1 instancia EC2 (Ubuntu 22.04) com profile IAM.
- 1 Security Group com regras de entrada (SSH/HTTP/HTTPS) e saida total.
- 1 repositório ECR privado.
- 1 role IAM + instance profile para a EC2.
- Backend remoto S3 para o state do Terraform.

## Estrutura

- `provider.tf`: provider AWS (regiao us-east-1).
- `backend.tf`: backend S3 do state.
- `ec2.tf`: EC2 + Security Group + regras.
- `iam.tf`: role e instance profile.
- `ecr.tf`: repositorio ECR privado.
- `.github/workflows/terraform.yaml`: pipeline CI/CD.

## Pré-requisitos

- Conta AWS com permissões para EC2, ECR e IAM.
- AWS CLI configurado localmente (se for executar local).
- Terraform instalado.
- Bucket S3 existente para o backend.
- Chave SSH existente na AWS (para `key_name`).
- Role com OIDC para GitHub Actions (para o workflow).

## Entenda antes de mudar

Este projeto cria recursos na AWS. Para funcionar na sua conta, voce precisa
ajustar alguns valores que sao especificos do seu ambiente. Abaixo explico
o que mudar, por que mudar e como encontrar o valor certo.

## O que voce precisa ajustar (e por que)

- `ec2.tf`
  - `ami`
    - **Por que mudar:** AMI e especifica por regiao/conta.
    - **Como achar:** Console AWS > EC2 > AMIs. Filtre por "Ubuntu 22.04".
  - `key_name`
    - **Por que mudar:** a instancia precisa da sua chave para SSH.
    - **Como achar:** Console AWS > EC2 > Key Pairs.
  - `vpc_id`
    - **Por que mudar:** o SG precisa existir na sua VPC.
    - **Como achar:** Console AWS > VPC > Your VPCs.
  - `cidr_ipv4` (regra SSH)
    - **Por que mudar:** libera SSH apenas para o seu IP (seguranca).
    - **Como achar:** descubra seu IP publico em um site de "meu IP".
- `backend.tf`
  - `bucket`
    - **Por que mudar:** o state remoto precisa de um bucket real na sua conta.
    - **Como achar:** Console AWS > S3.
  - `key`
    - **Por que mudar:** define o caminho do arquivo de state no bucket.
    - **Como definir:** escolha um caminho unico por ambiente.
- `provider.tf`
  - `region`
    - **Por que mudar:** todos os recursos serao criados nessa regiao.
    - **Como definir:** use a mesma regiao do seu AMI e VPC.

## Como o fluxo funciona (bem direto)

1) `terraform init` prepara o backend S3 (state remoto).
2) `terraform plan` mostra o que vai ser criado.
3) `terraform apply` cria os recursos.
4) `terraform plan -destroy` gera o plano de destruicao.
5) `terraform apply` com o plano destrói tudo.

## Execucao local

Na pasta do projeto:

```bash
terraform init
terraform plan -out=tfplan
terraform apply -auto-approve tfplan
```

Para destruir:

```bash
terraform plan -destroy -out=tfplan.destroy
terraform apply -auto-approve tfplan.destroy
```

Se o Terraform acusar "Backend configuration changed", rode:

```bash
terraform init -reconfigure
```

## Workflow (GitHub Actions)

O workflow é manual (`workflow_dispatch`) e aceita os inputs:

- `apply`: aplica a infra.
- `plan_destroy`: gera o plano de destruicao.
- `destroy`: aplica o plano de destruicao.

Observacao: para destruir tudo, execute o workflow com
`plan_destroy = true` e `destroy = true` na mesma execucao.
O `destroy` precisa do plano gerado nesse mesmo run.

## Possiveis erros comuns

- **AccessDenied (ECR/IAM):** a role assumida pelo GitHub Actions precisa
  permitir `ecr:CreateRepository` e `iam:CreateRole` (entre outras).
- **Arquivo de plano nao encontrado:** o `plan_destroy` nao foi executado
  ou o nome do arquivo nao bate com o `apply`.

## Custos

Este projeto cria recursos na AWS. Lembre-se de destruir tudo ao final
para evitar cobranças.

## Proximos passos sugeridos

- Adicionar outputs (IP publico da EC2, URL do ECR).
- Criar variaveis (`variables.tf`) para AMI, VPC e IP.
- Separar ambientes (dev/staging/prod) com workspaces.
