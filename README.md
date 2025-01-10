- first commitでリソースを構築
- ブルーグリーンを有効化
  ```
    blue_green_update = {
    enabled = true
  }
  ```
- 差分は以下になる
```
Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the last "terraform apply" which may have affected this plan:

  # module.postgresql.module.db_instance.aws_db_instance.this[0] has changed
  ~ resource "aws_db_instance" "this" {
      + domain_dns_ips                        = []
        id                                    = "db-P63BNRFIN4XZX4ZLUEJNFMGQII"
        tags                                  = {
            "Name" = "postgresql"
        }
        # (70 unchanged attributes hidden)

        # (1 unchanged block hidden)
    }


Unless you have made equivalent changes to your configuration, or ignored the relevant attributes using ignore_changes, the following plan may include actions to undo or respond to these changes.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_db_parameter_group.default will be updated in-place
  ~ resource "aws_db_parameter_group" "default" {
        id           = "default"
        name         = "default"
        tags         = {}
        # (6 unchanged attributes hidden)

      - parameter {
          - apply_method = "pending-reboot" -> null
          - name         = "shared_preload_libraries" -> null
          - value        = "pg_stat_statements" -> null
        }
      + parameter {
          + apply_method = "immediate"
          + name         = "shared_preload_libraries"
          + value        = "pg_stat_statements"
        }
    }

  # module.postgresql.module.db_instance.aws_db_instance.this[0] will be updated in-place
  ~ resource "aws_db_instance" "this" {
      ~ backup_retention_period               = 0 -> 1
        id                                    = "db-P63BNRFIN4XZX4ZLUEJNFMGQII"
        tags                                  = {
            "Name" = "postgresql"
        }
        # (71 unchanged attributes hidden)

      + blue_green_update {
          + enabled = true
        }

        # (1 unchanged block hidden)
    }

Plan: 0 to add, 2 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.
```


# 2400111 memo追加
- 以下のパラメータでは切り替えまですべて進んでしまう
- 以下を試す
- https://github.com/hashicorp/terraform-provider-aws/blob/6e4dc6ce181532441147db471dae10a26de83211/docs/design-decisions/rds-bluegreen-deployments.md
