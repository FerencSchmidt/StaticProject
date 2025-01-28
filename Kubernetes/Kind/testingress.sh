kubectl apply -f test-ingress.yaml

# should output "foo-app"
curl localhost/foo

# should output "bar-app"
curl localhost/bar