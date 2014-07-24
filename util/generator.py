#!/usr/bin/env python
#
# Generate method and test skeletons from Redis command documentation.

from __future__ import print_function

import argparse
import json
import sys

import jinja2

GROUPS = [
    'connection',
    'generic',
    'hash',
    'hyperloglog',
    'list',
    'pubsub',
    'scripting',
    'server',
    'set',
    'sorted_set',
    'string',
    'transactions',
]

TEMPLATES = {
    'method': """# {{ summary }}
redis::{{ method }}() {
  redis::redis '{{ command }}'{% if has_args %} "${@:1}"{% endif %}
}""",
    'test': """@test '{{ command }}' {
  run redis::{{ method }}
  fail 'test not defined yet'
}""",
}


def parse_args(argv):
    parser = argparse.ArgumentParser(
        description='Generate methods and tests from Redis command documentation.'
    )
    parser.add_argument('filename',
        help='Redis command documentation (commands.json)',
    )
    parser.add_argument('-t', '--type', choices=TEMPLATES.keys(), metavar='',
            required=True,
            help="Type of function to generate. Choose from: {0}.".format(', '.join(TEMPLATES.keys()))
    )
    parser.add_argument('-g', '--groups', choices=GROUPS, metavar='',
            nargs='*',
            help="Space-separated list of commands to reference. Choose from: {0}. Default: all command groups.".format(', '.join(GROUPS))
    )
    args = parser.parse_args(argv)
    return args


def main(argv=None):
    if not argv:
        argv = sys.argv[1:]
    args = parse_args(argv)
    with open(args.filename, 'r') as f:
        data = json.load(f)

    # Restrict commands to specified groups.
    if args.groups:
        commands = dict((k, v) for k, v in data.iteritems() if v['group'] in args.groups)
    else:
        commands = data

    # Generate output.
    template = jinja2.Template(TEMPLATES[args.type])
    for k, v in iter(sorted(commands.iteritems())):
        params = {
            'command': k,
            'method': k.lower().replace(' ', '_'),
            'summary': v['summary'],
            'group': v['group'],
            'has_args': ('arguments' in v),
        }
        print(template.render(params), "\n")

if __name__=='__main__':
    main()
