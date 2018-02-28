Note:

- service1.json shall only be used when creating new revision via AWS Console

- service1_new.json shall be used when creating new revision via CLI. Below is the correct usage

  e.g.    aws --region ap-northeast-1 --profile dev ecs register-task-definition --cli-input-json file://service1_new.json

- To get latest task definition as well as apply new task definition

  TASK_REVISION=`aws ecs describe-task-definition --task-definition melody-dfs-service1-dev-td | egrep "revision" | tr "/" " " | awk '{print $2}' | sed 's/"$//'`

  aws ecs update-service --cluster mobility-dfs-cluster-dev --service mobility-dfs-service1 --task-definition melody-dfs-service1-dev-td:3
