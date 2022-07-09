$LBC_VERSION = "v2.4.1"
$LBC_CHART_VERSION = "1.4.1"
$AWS_REGION = "ap-southeast-2"
$CLUSTER_NAME = "dav-cluster"
$ACCOUNT_ID = "289410895629"

eksctl utils associate-iam-oidc-provider `
    --region $AWS_REGION `
    --cluster $CLUSTER_NAME `
    --approve

aws iam create-policy `
    --policy-name AWSLoadBalancerControllerIAMPolicy `
    --policy-document file://./iam_policy.json

eksctl create iamserviceaccount `
    --cluster $CLUSTER_NAME `
    --namespace kube-system `
    --name aws-load-balancer-controller `
    --attach-policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy `
    --override-existing-serviceaccounts `
    --approve

kubectl apply -k https://raw.githubusercontent.com/aws/eks-charts/master/stable/aws-load-balancer-controller/crds/crds.yaml
kubectl get crd


helm repo add eks https://aws.github.io/eks-charts

helm upgrade -i aws-load-balancer-controller `
    eks/aws-load-balancer-controller `
    -n kube-system `
    --set clusterName=eksworkshop-eksctl `
    --set serviceAccount.create=false `
    --set serviceAccount.name=aws-load-balancer-controller `
    --set image.tag="${LBC_VERSION}" `
    --version="${LBC_CHART_VERSION}"

kubectl -n kube-system rollout status deployment aws-load-balancer-controller    