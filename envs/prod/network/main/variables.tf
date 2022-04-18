variable "vpc_cidr" {
  type    = string
  # cidrの決め方
  # 第1オクテット〜第2オクテットまで0〜255の範囲で自由に決めて第3と第4オクテットは0でいい
  # ブロックサイズ(/スラッシュ)の後ろの2桁の数字は、16~28の間を入力。20、24だと計算しやすいからおすすめ
  default = "171.32.0.0/16"
}

/*
ax毎にサブネットのcidr変数を定義
*/
variable "azs" {
  type = map(object({
    public_cidr  = string
    private_cidr = string
  }))
  default = {
    a = {
      public_cidr  = "171.32.0.0/20"
      private_cidr = "171.32.48.0/20"
    },
    c = {
      public_cidr  = "171.32.16.0/20"
      private_cidr = "171.32.64.0/20"
    }
  }
}

/*
 * NATゲートウェイ関連の変数の宣言
 * NATゲートウェイを作成するかどうかのフラグ変数
 * terrafomr apply -var='enable_nat_gateway=false'
*/
variable "enable_nat_gateway" {
  type    = bool
  default = true
}

/*
 * NATゲートウェイ関連の変数の宣言
 * NATゲートウェイの数を1つ作成で固定するかどうかのフラグ変数
*/
variable "single_nat_gateway" {
  type    = bool
  default = true
}