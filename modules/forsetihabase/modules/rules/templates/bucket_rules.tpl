#
#  Copyright 2019 Google LLC.
#
#  This software is provided as is, without warranty
#  or representation for any use or purpose. Your use
#  of it is subject to your agreement with Google.
#

rules:
  - name: Bucket acls rule to search for public buckets
    bucket: '*'
    entity: allUsers
    email: '*'
    domain: '*'
    role: '*'
    resource:
        - resource_ids:
          - ${org_id}
  - name: Bucket acls rule to search for exposed buckets
    bucket: '*'
    entity: allAuthenticatedUsers
    email: '*'
    domain: '*'
    role: '*'
    resource:
        - resource_ids:
          - ${org_id}
