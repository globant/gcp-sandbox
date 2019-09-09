#
#  Copyright 2019 Google LLC.
#
#  This software is provided as is, without warranty
#  or representation for any use or purpose. Your use
#  of it is subject to your agreement with Google.
#

rules:
  # The max allowed age of user managed service account keys (in days)
  - name: Service account keys not rotated
    resource:
      - type: organization
        resource_ids:
          - '*'
    max_age: 90 # days
