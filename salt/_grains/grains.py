#!/usr/bin/python

import os
import re

def custom_grains():
    grains = {}
    grains['roles'] = []

    grains['roles'].append('common')

    # use hostname for now
    hostname = os.uname()[1]
    if re.match('control', hostname, re.IGNORECASE):
        grains['roles'].append('control')
    elif re.match('submit', hostname, re.IGNORECASE):
        grains['roles'].append('submit')
        # submit is staging_site as well for now
        grains['roles'].append('staging')
    elif re.match('compute', hostname, re.IGNORECASE):
        grains['roles'].append('compute')
        # all computes are http_caches for now
        grains['roles'].append('http_cache')
        grains['site_http_proxy'] = hostname

    return grains

