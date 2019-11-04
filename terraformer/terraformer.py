#!/usr/bin/python

import argparse
import os

copyright = "#Copyright 2019 Globant LLC\n#\n#\n#Licensed under the Apache License, Version 2.0 (the \"License\");\n#you may not use this file except in compliance with the License.\n#You may obtain a copy of the License at\n#\n#    http://www.apache.org/licenses/LICENSE-2.0\n#\n#Unless required by applicable law or agreed to in writing, software\n#distributed under the License is distributed on an \"AS IS\" BASIS,\n#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n#See the License for the specific language governing permissions and\n#limitations under the License.\n\n"

parser = argparse.ArgumentParser(description='Generate terraform template project')
parser.add_argument('--project', nargs=1, help='name of the project to be generated', required=True)
parser.add_argument('--subsystems', nargs='+', help='list of subsystem names included in the project', required=True)
parser.add_argument('--environments', nargs='+', help='list of environments to be deployed', required=True)

arguments = parser.parse_args()

try:
    os.mkdir(vars(arguments)['project'][0])
    os.mkdir(os.path.join(vars(arguments)['project'][0], 'modules'))
    open(os.path.join(vars(arguments)['project'][0], 'modules', 'README.md'), 'w').write(copyright + '#' + vars(arguments)['project'][0] + ' wide terraform modules goes here')
except:
    print 'ERROR: Folder name ' + vars(arguments)['project'][0] + ' already exists'
    exit(1)

for subsystem in vars(arguments)['subsystems']:
    try:
        os.mkdir(os.path.join(vars(arguments)['project'][0], subsystem))
        os.mkdir(os.path.join(vars(arguments)['project'][0], subsystem, 'environments'))
        os.mkdir(os.path.join(vars(arguments)['project'][0], subsystem, 'modules'))
        open(os.path.join(vars(arguments)['project'][0], subsystem, 'modules', 'README.md'), 'w').write(copyright + '#' + subsystem + ' terraform modules goes here')
        os.mkdir(os.path.join(vars(arguments)['project'][0], subsystem, 'shared'))
        open(os.path.join(vars(arguments)['project'][0], subsystem, 'shared', 'remotes.tf'), 'w').write(copyright + '#placeholder to export remote state definitions')
        for environment in vars(arguments)['environments']:
            os.mkdir(os.path.join(vars(arguments)['project'][0], subsystem, 'environments', environment))
            open(os.path.join(vars(arguments)['project'][0], subsystem, 'environments', environment, 'main.tf'), 'w').write(copyright + '#' + environment + ' terraform module instantiation')
            open(os.path.join(vars(arguments)['project'][0], subsystem, 'environments', environment, 'outputs.tf'), 'w').write(copyright + '#' + environment + ' terraform outputs definition')
            open(os.path.join(vars(arguments)['project'][0], subsystem, 'environments', environment, 'terraform.tfvars'), 'w').write(copyright + '#' + environment + ' variables assignment')
            open(os.path.join(vars(arguments)['project'][0], subsystem, 'environments', environment, 'variables.tf'), 'w').write(copyright + '#' + environment + ' variables definition')
            print 'Environment ' + environment + ' for subsystem ' + subsystem + ' initialized'
        print 'Subsystem ' + subsystem + ' initialized'
    except:
        pass

print 'Project ' + vars(arguments)['project'][0] + ' initialized'
exit(0)
