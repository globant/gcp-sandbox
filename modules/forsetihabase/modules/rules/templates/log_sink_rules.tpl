#
#  Copyright 2019 Google LLC.
#
#  This software is provided as is, without warranty
#  or representation for any use or purpose. Your use
#  of it is subject to your agreement with Google.
#

 rules:
   - name: 'Require PubSub Audit Log sinks in all projects.'
     mode: required
     resource:
       - type: organization
         applies_to: children
         resource_ids:
           - ${org_id}
     sink:
       destination: 'pubsub.googleapis.com/*'
       filter: '*'
       include_children: '*'
