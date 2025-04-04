helm install gitlab-runner gitlab/gitlab-runner \
  --namespace gitlab-runner \
  --set gitlabUrl="https://gitlab.com" \
  --set runnerRegistrationToken="yourtoken" \
  --set runners.executor="kubernetes" \
  --set runners.namespace="gitlab-runner"