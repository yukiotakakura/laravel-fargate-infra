data "aws_route53_zone" "this" {
  name = "takacube.link"
}

resource "aws_route53_record" "certificate_validation" {
  for_each = {
    for dvo in aws_acm_certificate.root.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = data.aws_route53_zone.this.id
}

/*
 * ALIASレコードの作成
 *
 * 「http(s)://appfoobar.link」 にアクセスしたときにALBへ名前解決されるよう、ALIASレコードを追加
*/
resource "aws_route53_record" "root_a" {
  count = var.enable_alb ? 1 : 0

  name    = data.aws_route53_zone.this.name

  # ALIASレコードの場合は、「A」を指定
  type    = "A"
  zone_id = data.aws_route53_zone.this.zone_id

  # ALIASレコードの場合は、aliasブロックを指定する。ここでは、ALBのDNS名やゾーンIDを指定する
  alias {
    evaluate_target_health = true
    name                   = aws_lb.this[0].dns_name
    zone_id                = aws_lb.this[0].zone_id
  }
}