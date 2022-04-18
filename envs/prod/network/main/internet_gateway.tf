/*
 * インターネットゲートウェイの作成
 * 
 * VPCが外部のネットワークと接続する為に必要となるAWSのコンポーネントです。
 * そもそも、VPC内のインスタンスは、このインターネットゲートウェイが無ければ、同じVPC内のインスタンスとしかやりとりができない。
 * インターネットゲートウェイと直接やりとりができるのは、パブリックサブネットのみ
*/
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = aws_vpc.this.tags.Name
  }
}