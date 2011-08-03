#!/usr/bin/env python

'''\
Run 'fab --list' to see what commands you can run.

Requires Fabric from www.fabfile.org
'''

import os
import getpass

from fabric.api import env, local, run, sudo
from fabric.context_managers import cd
from fabric.utils import puts
from fabric import colors


env.hosts = ('isbn.net.in:30247',)
LOCAL_DIR = os.getcwd()
REMOTE_DIR = '/home/' + getpass.getuser() + '/web/isbn.net.in/private/isbn.net.in'


def _transfer_files(src, dst, port=22):
    '''Sync from local directory to remote directory'''
    assert os.getenv('SSH_AUTH_SOCK') is not None # Ensure ssh-agent is running
    if not src.endswith('/'):
        src = src + '/'
    if dst.endswith('/'):
        dst = dst[:-1]
    local('rsync -avh --delete-before --copy-unsafe-links --exclude "log/*" --exclude ".*.sw*" --exclude "tmp/*" -e "ssh -p {0}" {1} {2}'.format(port, src, dst), capture=False)


def push():
    '''Push code to server'''
    global LOCAL_DIR, REMOTE_DIR

    _transfer_files(LOCAL_DIR, env.host + ':' + REMOTE_DIR, env.port) # transfer the code

    with cd(REMOTE_DIR):
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

    puts(colors.magenta('Success! The {0} server has been updated.'.format(env.host_string)))


def clear_cache():
    '''Clear cache on server'''
    global REMOTE_DIR

    with cd(REMOTE_DIR):
        run("rake cache:clear")
