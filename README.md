#### Step 1
edit [Terraform/env.hcl](Terraform/env.hcl)

### Step 2 ( Create Backend State )
```shell
cd backend
```
```shell
terraform init
```
```shell
terraform plan --var-file=../env.hcl
```
```shell
terraform apply --var-file=../env.hcl
```
### Step 3 ( Create EKS Cluster)
```shell
cd eks-setup
```
```shell
terraform init --backend-config=../backend/backend.hcl
```
```shell
terraform plan --var-file=../env.hcl
```
```shell
terraform apply --var-file=../env.hcl
```
### Setp 4 ( Deploy Addon Services)

```bash
cd addons
```
```shell
terraform init --backend-config=../backend/backend.hcl
```
```shell
terraform plan --var-file=../env.hcl
```
```shell
terraform apply --var-file=../env.hcl
```


REF : https://medium.com/devops-mojo/terraform-provision-amazon-eks-cluster-using-terraform-deploy-create-aws-eks-kubernetes-cluster-tf-4134ab22c594]