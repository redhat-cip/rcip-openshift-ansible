#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Author: Hugo Rosnet <hrosnet@redhat.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Requirments: python
#

import sys
import argparse
import subprocess
import requests

# Disable warning for insecure https
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

from requests.exceptions import ConnectionError

VERSION = '1.1'

PARSER = argparse.ArgumentParser(description='Openshift check pods')
PARSER.add_argument("-proto", "--protocol", type=str,
                    help='Protocol openshift (Default : https)',
                    default="https")
PARSER.add_argument("-api", "--base_api", type=str,
                    help='Url api and version (Default : /api/v1)',
                    default="/api/v1")
PARSER.add_argument("-H", "--host", type=str,
                    help='Host openshift (Default : 127.0.0.1)',
                    default="127.0.0.1")
PARSER.add_argument("-P", "--port", type=str,
                    help='Port openshift (Default : 8443)',
                    default=8443)
PARSER.add_argument("-u", "--username", type=str,
                    help='Username openshift (ex : sensu)')
PARSER.add_argument("-p", "--password", type=str,
                    help='Password openshift')
PARSER.add_argument("-to", "--token", type=str,
                    help='File with token openshift (like -t)')
PARSER.add_argument("-tf", "--tokenfile", type=str,
                    help='Token openshift (use token or user/pass')
PARSER.add_argument("--get_available_nodes", type=str,
                    help='Get the number of node Ready and Schedulable')
PARSER.add_argument("--check_node_scheduling", type=str,
                    help='Check if a nodes is in SchedulingDisabled state or not.')
PARSER.add_argument("--set_scheduling", type=str, nargs=2,
                    help='Set node as Schedulable or NotSchedulable.')
PARSER.add_argument("--check_node_readiness", type=str,
                    help='Check if a nodes is Ready or not.')
PARSER.add_argument("-v", "--version", action='store_true',
                    help='Print script version')
ARGS = PARSER.parse_args()


class Openshift(object):
    """
    A little object for use REST openshift v3 api
    """

    def __init__(self,
                 proto='https',
                 host='127.0.0.1',
                 port=8443,
                 username=None,
                 password=None,
                 token=None,
                 tokenfile=None,
                 debug=False,
                 verbose=False,
                 namespace='default',
                 base_api='/api/v1'):

        self.proto = proto
        self.host = host
        self.port = port
        self.username = username
        self.password = password
        self.debug = debug
        self.verbose = verbose
        self.namespace = namespace
        # Remove the trailing / to avoid user issue
        self.base_api = base_api.rstrip('/')

        if token:
            self.token = token
        elif tokenfile:
            self.token = self._tokenfile(tokenfile)
        else:
            self.token = self._auth()

    def _auth(self):
        cmd = ("oc login %s:%s -u%s -p%s --insecure-skip-tls-verify=True 2>&1 > /dev/null"
               % (self.host, self.port, self.username, self.password))
        subprocess.check_output(cmd, shell=True)

        cmd = "oc whoami -t"
        stdout = subprocess.check_output(cmd, shell=True)

        return stdout.strip()

    def _tokenfile(self, tokenfile):
        try:
            f = open(tokenfile, 'r')
            return f.readline().strip()
        except IOError:
            print('Error: File does not appear to exist')
            return "tokenfile-inaccessible"

    def _get_json(self, url):

        headers = {"Authorization": 'Bearer %s' % self.token}
        try:
            r = requests.get('https://%s:%s%s' % (self.host, self.port, url),
                             headers=headers,
                             verify=False)  # don't check ssl
            parsed_json = r.json()
        except ValueError:
            sys.exit(1)
        except ConnectionError as e:
            print("https://%s:%s%s - %s" % (self.host, self.port, url, e))
            sys.exit(1)

        return parsed_json

    def _patch_json(self, url, data):

        headers = {"Authorization": 'Bearer %s' % self.token, "Content-Type": 'application/strategic-merge-patch+json'}
        try:
            r = requests.patch('https://%s:%s%s' % (self.host, self.port, url),
                               data=data,
                               headers=headers,
                               verify=False)

        except ValueError as e:
            print("Patch json: value error %s" % e)
            sys.exit(1)
        except ConnectionError as e:
            print("https://%s:%s%s - %s" % (self.host, self.port, url, e))
            sys.exit(1)
        return True

    def set_scheduling(self, node_name=None, state=True):
        if node_name is None:
            print("Need a node name")
            return None

        if state not in ["True", "true", "False", "false"]:
            print("Need a state for the node")
            return None

        # need to lower case for JSON validity and inverse value because openshift takes 'unschedulable' parameter
        state = state.lower()
        state = "true" if state == "false" else "false"
        api_node = '%s/nodes/%s' % (self.base_api, node_name)
        data = '{"apiVersion": "v1", "kind": "Node", "metadata": {"name": "%s"}, "spec": {"unschedulable": %s}}' % (node_name, state)
        self._patch_json(url=api_node, data=data)

    def get_readiness(self, node_json=None, node_name=None):

        if node_json is None and node_name is None:
            return None
        elif node_name is not None:
            api_node = '%s/nodes/%s' % (self.base_api, node_name)
            node_json = self._get_json(api_node)

        try:
            if node_json["status"]["conditions"][0]["status"] != "True":
                return False
        except KeyError:
            pass
        return True

    def get_scheduling(self, node_json=None, node_name=None):

        if node_json is None and node_name is None:
            return None
        elif node_name is not None:
            api_node = '%s/nodes/%s' % (self.base_api, node_name)
            node_json = self._get_json(api_node)

        try:
            if node_json["spec"]["unschedulable"]:
                return False
        except KeyError:
            pass
        return True

    def get_available_nodes(self, region='primary', state='Ready', min_needed=2):
        node_count = 0
        api_nodes = '%s/nodes' % self.base_api
        parsed_json = self._get_json(api_nodes)

        if 'items' not in parsed_json:
            # Generate error
            return False

        for item in parsed_json["items"]:
            if item["metadata"]["labels"]["region"] == region and \
                    self.get_readiness(node_json=item) and \
                    self.get_scheduling(node_json=item):
                node_count += 1
            if node_count >= min_needed:
                return True
            # Generate error - count too low
        return False

if __name__ == "__main__":

    # https://docs.openshift.com/enterprise/3.0/rest_api/openshift_v1.html

    if ARGS.version:
        print("version: %s" % (VERSION))
        sys.exit(0)

    if not ARGS.token and not ARGS.tokenfile and not (ARGS.username and ARGS.password):
        PARSER.print_help()
        sys.exit(1)

    myos = Openshift(host=ARGS.host,
                     port=ARGS.port,
                     username=ARGS.username,
                     password=ARGS.password,
                     token=ARGS.token,
                     tokenfile=ARGS.tokenfile,
                     proto=ARGS.protocol,
                     base_api=ARGS.base_api)

    if ARGS.get_available_nodes:
        if myos.get_available_nodes(region=ARGS.get_available_nodes) is True:
            print("There is more than 2 nodes ready & schedulable in region %s" % ARGS.get_available_nodes)
        else:
            print("There is not more than 2 nodes ready & schedulable in region %s" % ARGS.get_available_nodes)

    if ARGS.check_node_readiness:
        if myos.get_readiness(node_name=ARGS.check_node_readiness) is True:
            print("%s is Ready" % ARGS.check_node_readiness)
        else:
            print("%s is NOT Ready" % ARGS.check_node_readiness)

    if ARGS.check_node_scheduling:
        if myos.get_scheduling(node_name=ARGS.check_node_scheduling) is True:
            print("%s is Schedulable" % ARGS.check_node_scheduling)
        else:
            print("%s is NotSchedulable" % ARGS.check_node_scheduling)

    if ARGS.set_scheduling:
        myos.set_scheduling(node_name=ARGS.set_scheduling[0], state=ARGS.set_scheduling[1])
