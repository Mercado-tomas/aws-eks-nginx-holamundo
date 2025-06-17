# aws-eks-nginx-holamundo
DevOps Hola Mundo en AWS EKS con Terraform y GitOps 🌐

Bienvenido a mi primer proyecto DevOps, donde despliego una aplicación "Hola Mundo" en Nginx sobre un clúster Amazon EKS, gestionada con Terraform, ArgoCD para GitOps, y monitoreada con Prometheus y Grafana. Este repositorio muestra cómo construir una infraestructura moderna en AWS Free Tier, incluyendo una VPC, subredes, AWS Load Balancer, y un Horizontal Pod Autoscaler (HPA), todo desde un entorno WSL con Visual Studio Code. 🚀

Aunque la app es simple, la infraestructura es robusta, y el proceso de aprendizaje fue inmenso: enfrenté y resolví errores como timeouts de Helm, límites de pods en nodos t3.micro, y configuraciones de kubeconfig rotas. Este proyecto refleja mi pasión por DevOps, Cloud, y GitOps, y mi capacidad para superar desafíos técnicos.

📋 Descripción

Este proyecto crea una infraestructura en AWS para desplegar una aplicación web "Hola Mundo" en Nginx sobre un clúster EKS (Elastic Kubernetes Service). La infraestructura se define como código con Terraform, se despliega automáticamente con ArgoCD, y se monitorea con Prometheus y Grafana. La app se expone públicamente a través de un Application Load Balancer (ALB), con escalado automático mediante un HPA.

Características principales:

Infraestructura como Código: Terraform gestiona una VPC, subredes públicas/privadas, NAT Gateway, y un clúster EKS.

Kubernetes en AWS: Clúster EKS con nodos t3.micro (optimizado para Free Tier).

GitOps: ArgoCD sincroniza manifests YAML desde este repositorio.

Monitoreo: Stack Prometheus/Grafana para métricas del clúster.

Escalado automático: HPA escala los pods de Nginx según la carga de CPU.

Resolución de errores: Superé timeouts de Helm, límites de pods, y problemas de kubeconfig.

🛠️ Tecnologías Utilizadas

AWS (EKS, EC2, VPC, ALB, IAM)
IaC
Terraform (~5.79.0), Helm (~2.17.0)
Orquestación
Kubernetes (EKS v1.29), AWS Load Balancer Controller
GitOps
ArgoCD
Monitoreo
Prometheus, Grafana (kube-prometheus-stack)
Aplicación
Nginx (despliegue de "Hola Mundo")
Entorno
WSL (Ubuntu), Visual Studio Code, AWS CLI

🏗️ Arquitectura

La infraestructura se compone de:
VPC: Red personalizada con subredes públicas y privadas en 3 zonas de disponibilidad (us-west-2a, b, c).
EKS: Clúster Kubernetes con 3 nodos t3.micro, gestionado por Terraform.
ALB: Application Load Balancer para exponer la app Nginx, configurado vía Ingress.
ArgoCD: Despliega los manifests YAML (namespace, deployment, service, ingress, hpa) desde este repositorio.
Prometheus/Grafana: Monitorea métricas del clúster y la app.
HPA: Escala los pods de Nginx entre 3 y 6 réplicas según el uso de CPU (70%).

+-------------------+       +-------------------+       +-------------------+
|   GitHub Repo     | ----> |      ArgoCD       | ----> |      EKS Cluster  |
| (manifests YAML)  |       | (GitOps Sync)     |       | (Nginx, ALB, HPA) |
+-------------------+       +-------------------+       +-------------------+
                                    |                           |
                                    v                           v
+-------------------+       +-------------------+       +-------------------+
|    Terraform      | ----> |       VPC         |       |  Prometheus/Grafana|
| (EKS, VPC, IAM)   |       | (Subnets, NAT)    |       | (Monitoring)      |
+-------------------+       +-------------------+       +-------------------+

🚀 Instalación

Prerrequisitos
AWS CLI configurado con credenciales válidas (aws configure).
Terraform (~5.79.0).
kubectl compatible con EKS v1.29.
Helm (~2.17.0).
Git para clonar este repositorio.
Entorno WSL (Ubuntu recomendado) o sistema compatible.
Cuenta AWS con permisos para crear EKS, VPC, EC2, IAM, y ALB.
Pasos
Clona el repositorio:

git clone https://github.com/<tu-usuario>/devops-hola-mundo.git
cd devops-hola-mundo

Inicializa Terraform:

cd infraestructura/ambientes/dev
terraform init

Aplica la infraestructura:

terraform validate
terraform plan
terraform apply
Esto crea la VPC, el clúster EKS, y los charts de Helm (aws-load-balancer-controller, kube-prometheus-stack, argo-cd).

Configura kubectl:

aws eks update-kubeconfig --name eks-dev --region us-west-2
kubectl get nodes

Despliega la app:

kubectl apply -f aplicacion/

Incluye namespace, deployment, service, ingress, y hpa para la app Nginx.
Accede a la app:

kubectl get ingress -n hola-mundo
Abre la URL del ALB en tu navegador para ver "Hola Mundo".

Configura ArgoCD:
Accede a la UI de ArgoCD:
kubectl port-forward svc/argocd-server -n argocd 8080:443

Obtén la contraseña inicial:
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

Conecta este repositorio en ArgoCD para sincronizar los manifests YAML.
Destruye los recursos (para evitar costos):

cd infraestructura/ambientes/dev
terraform destroy

⚠️ Desafíos y Soluciones

Este proyecto no estuvo exento de desafíos. A continuación, detallo los errores enfrentados y cómo los resolví:
Error
Causa

Solución
Timeout de Helm
Recursos limitados en nodos t3.micro causaban que los charts (aws-load-balancer-controller, kube-prometheus-stack, argo-cd) no se instalaran a tiempo.
Aumenté el timeout a 900s, optimicé recursos de Helm, y añadí 3 nodos t3.micro.
"Too many pods"
Nodos t3.micro tenían un límite de 4 pods, todos ocupados por pods del sistema (aws-node, coredns, kube-proxy).
Habilité delegación de prefijos en el CNI (ENABLE_PREFIX_DELEGATION), aumentando el límite a ~10-20 pods por nodo.
Kubeconfig roto
kubectl apuntaba a 127.0.0.1:32769 (residuo de un clúster local).
Actualicé el kubeconfig con aws eks update-kubeconfig --name eks-dev --region us-west-2.
Un solo nodo activo
Solo un nodo t3.micro se creó en lugar de tres, posiblemente por límites de capacidad en us-west-2a.
Añadí zonas de disponibilidad (us-west-2b, c) y verifiqué el grupo de nodos con aws eks describe-nodegroup.

Estos errores me enseñaron a depurar problemas en Kubernetes, optimizar recursos en Free Tier, y entender la importancia de la configuración de red y permisos IAM.

📈 Aprendizajes
Terraform: Cómo estructurar módulos para entornos (dev, prod) y gestionar recursos AWS.
EKS y Kubernetes: Configuración de clústeres, Ingress, HPA, y gestión de nodos.
GitOps con ArgoCD: Automatización de despliegues desde Git.
Monitoreo: Uso de Prometheus/Grafana para métricas en tiempo real.
Resolución de problemas: Depuración de errores en AWS, Kubernetes, y Helm.
AWS Free Tier: Optimización de costos usando t3.micro y minimizando recursos.

🔮 Próximos Pasos
Configurar un pipeline CI/CD con GitHub Actions para automatizar despliegues.
Añadir un dominio con Route 53 para la app.
Implementar un WAF (Web Application Firewall) con Terraform.
Explorar RDS o Lambda para extender la funcionalidad.
Optimizar costos con Spot Instances en EKS.

🤝 Contribuciones
¡Las contribuciones son bienvenidas! Si quieres mejorar el proyecto, abre un issue o envía un pull request. Algunas ideas:
Añadir tests para Terraform con Terratest.
Mejorar los manifests YAML con Helm charts personalizados.
Documentar más errores y soluciones.

📬 Contacto

Si te interesa charlar sobre DevOps, AWS, o Kubernetes, conectá conmigo en LinkedIn o abrí un issue en este repositorio. ¡Estoy abierto a colaborar y aprender más! 😄

🙏 Agradecimientos
A la comunidad de Terraform, Kubernetes, y AWS por la documentación y recursos.
A mis mentores y colegas que me inspiraron a sumergirme en DevOps.
