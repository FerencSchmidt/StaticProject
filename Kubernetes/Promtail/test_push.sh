kubectl run curl --image=curlimages/curl --rm -it --restart=Never --command -- /bin/sh -c "curl -XPOST -H 'Content-Type: application/json' http://loki:3100/loki/api/v1/push -d '{
  \"streams\": [
    {
      \"stream\": {
        \"label\": \"test\"
      },
      \"values\": [
        [ \"$(date +%s)000000000\", \"hello world from kubernetes curl pod\" ]
      ]
    }
  ]
}'"