#!/usr/bin/env python

'''\
Run 'fab --list' to see what commands you can run.

Requires Fabric from www.fabfile.org
'''

import os
from getpass import getuser

from fabric.api import env, hosts, local, run, sudo
from fabric.context_managers import cd
from fabric.utils import puts
from fabric.colors import magenta

def _transfer_files(src, dst, port=22):
    '''Sync from local directory to remote directory'''
    assert os.getenv('SSH_AUTH_SOCK') is not None # Ensure ssh-agent is running
    if not src.endswith('/'):
        src = src + '/'
    if dst.endswith('/'):
        dst = dst[:-1]
    local('rsync -avh --delete-before --copy-unsafe-links --exclude "log/*" --exclude ".*.sw*" --exclude "tmp/*" -e "ssh -p {0}" {1} {2}'.format(port, src, dst), capture=False)

@hosts('isbn.net.in:30247')
def push():
    local_dir = os.getcwd()
    remote_dir = '/home/' + getuser() + '/web/isbn.net.in/private/isbn.net.in'

    _transfer_files(local_dir, env.host + ':' + remote_dir, env.port) # transfer the code

    with cd(remote_dir):
        #run("env RAILS_ENV=production rake cache:clear")  # clear memcache
        run("rm -vf public/index.html public/about.html") # remove page caches on disk
        run("touch tmp/restart.txt")                      # restart passenger
        try:
            sudo("stop isbn.net.in")                      # stop workers
        except:
            pass
        sudo("cp -v upstart/* /etc/init/")                # copy latest upstart files
        run("rm -f tmp/pids/delayed_job*")                # remove pids
        sudo("start isbn.net.in")                         # start workers

    puts(magenta('Success! The {0} server has been updated.'.format(env.host_string)))
