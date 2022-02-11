
data "aws_iam_role" "ecs_task_execution_role" {
    name = "ecsTaskExecutionRole"
  }
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}
//crear balanceador 
resource "aws_default_subnet" "default_subnet" {
  availability_zone = "us-east-1a"
}
resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_default_subnet.default_subnet.id]
}
//crea target group
resource "aws_lb_target_group" "ip-external" {
    name        = "tfTG"
    port        = 5000
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = aws_default_vpc.default.id
    depends_on = [aws_lb.test] 
  }
//crear cluster
resource "aws_ecs_cluster" "tfCluster" {
    name = "tfCluster"  
    setting {
      name  = "containerInsights"
      value = "enabled"
    }
  }
 //crear tarea 
resource "aws_ecs_task_definition" "tftask" {
    family = "service"
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
    cpu                      = 512
    memory                   = 1024
    execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
    container_definitions = jsonencode([
        {
        name      = "tfImage"
        image     = "119461359170.dkr.ecr.us-east-1.amazonaws.com/testdevops:98965f3"
        cpu       = 10
        memory    = 256
        essential = true
        portMappings = [
            { 
            containerPort = 5000
            hostPort      = 5000
            }
        ]
        }
    ])
    
}
//crear servicio
resource "aws_ecs_service" "tfService" {
  name            = "tfService"
  cluster         = aws_ecs_cluster.tfCluster.id
  task_definition = aws_ecs_task_definition.tftask.arn
  desired_count   = 1

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ip-external.arn
    container_name   = "tfImage"
    container_port   = 5000
  }
  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-east-1a, us-east-1b]"
  }
}
