#
#  Copyright 2019 Google LLC.
#
#  This software is provided as is, without warranty
#  or representation for any use or purpose. Your use
#  of it is subject to your agreement with Google.
#

 rules:
   - name: all networks covered in whitelist
     project: '*'
     network: '*'
     is_external_network: True
     whitelist:
${whitelist}
