#Task Definition :
#The ecs_task_definition is the most important unit the ECS ecosystem. It contains memory and cpu allocations, the container definitions etc. 
#The container definition has port mappings for the container and host, and most importantly the image from ECR.

#Service :
#This defines the how many instances of the task_definition we want to run, we provide this with the desired_count attribute. 
#Each instance of a task_definition is called a Task. The service also requires network configuration for subnet(s). 
#The launch_type attribute for the service is very crucial. Only two types exist ie FARGATE or EC2. 
#Using FARGATE means you dont have to worry about managing a cluster and/or its services, FARGATE does that for you. 
#With EC2 launch type, you would have to be responsible for managing the cluster with its EC2 instances. 
#This is why we have a launch_type of FARGATE for the aws_ecs_service resource.

#Cluster :
#This is ultimate component for ECS. A cluster can contain multiple ecs_services, with each service running multiple instances of the task_definition. 
#Having a service of launch_type FARGATE means ECS gets to manage for you cluster and service optmization and resource utilization. 
#In case one of the tasks fails within a cluster, ECS will automatically spin up a new task with same cpu and memory allocation defined in the task_definition


resource "aws_ecs_cluster" "demo-ecs-cluster" {
  name = "ecs-cluster-for-demo"
}

resource "aws_ecs_service" "demo-ecs-service-two" {
  name            = "demo-app"
  cluster         = aws_ecs_cluster.demo-ecs-cluster.id
  task_definition = aws_ecs_task_definition.demo-ecs-task-definition.arn
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = ["subnet-09ac854d62790ec7a"]
    assign_public_ip = true
  }
  desired_count = 1
}

# data "aws_iam_policy_document" "ecs-assume-role-policy" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ecs-tasks.amazonaws.com"]
#     }
#   }
# }


# resource "aws_iam_role" "ecsTaskExecutionRole" {
#   name               = "ecsTaskExecutionRole"
#   assume_role_policy = data.aws_iam_policy_document.ecs-assume-role-policy.json
# }

# resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
#   role       = aws_iam_role.ecsTaskExecutionRole.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }

resource "aws_ecs_task_definition" "demo-ecs-task-definition" {
  family                   = "ecs-task-definition-demo"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = "1024"
  cpu                      = "512"
  execution_role_arn       = "arn:aws:iam::197631382959:role/ecsTaskExecutionRole"
  #   execution_role_arn    = aws_iam_role.ecsTaskExecutionRole.arn
  container_definitions = <<EOF
[
  {
    "name": "demo-container",
    "image": "197631382959.dkr.ecr.ap-southeast-1.amazonaws.com/demoecr/dev/nginx:latest",
    "memory": 1024,
    "cpu": 512,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000
      }
    ]
  }
]
EOF
}
