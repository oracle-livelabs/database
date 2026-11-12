#!/usr/bin/env python3
"""Prepare public learner files from the separately obtained Oracle sample."""
import argparse
import copy
import json
from pathlib import Path
import re
from urllib.parse import urlsplit

LEARNER_SPACE = 'Brokerage Lab'
SOURCE_ORIGIN = 'http://localhost:8000'


def build(sample, assets, website, origin, website_path=''):
    parts = urlsplit(origin)
    if (parts.scheme not in {'http', 'https'} or not parts.hostname
            or parts.username or parts.password or parts.path or parts.query or parts.fragment):
        raise ValueError('Expected only the browser-reachable website origin.')
    if website_path and not re.fullmatch(r'(?:/[A-Za-z0-9_-]+)+', website_path):
        raise ValueError('Expected a plain website subdirectory path without query strings or traversal.')
    website_base = origin + website_path
    targets = json.loads((sample / 'search_target.json').read_text())
    sets = json.loads((sample / 'target_value_set.json').read_text())
    questions = json.loads((assets / 'brokerage-quick-check.json').read_text())
    if len(targets) != 20 or len(sets) != 5 or len(questions) != 5:
        raise ValueError('Expected the reviewed twenty-target/five-set sample and five evaluation questions.')
    if any(t['title'] == 'Open Stock Orders' for t in targets) or any(s['name'] == 'LAB_ORDER_SIDE' for s in sets):
        raise ValueError('Learner-created configuration must not be preloaded.')
    names = {s['name'] for s in sets}
    titles = {t['title'] for t in targets}
    targets = copy.deepcopy(targets)
    for target in targets:
        action = target['target_action']
        url = action['url']
        if not url.startswith(SOURCE_ORIGIN + '/'):
            raise ValueError('Unexpected sample URL; refusing an unreviewed origin rewrite.')
        action['url'] = website_base + url[len(SOURCE_ORIGIN):]
        if any(i['target_value_set'] not in names for i in action.get('target_inputs', [])):
            raise ValueError('A target references a missing value set.')
    # The final benchmark question refers to the report learners create later.
    # Permit only this exact reviewed expectation; validate the original four
    # against the installed sample as before.
    learner_check = {
        'test_query': 'Review unexecuted equity trades.',
        'ground_truth': [{'search_target_title': 'Open Stock Orders',
                          'target_inputs': [{':ORDER_SIDE': 'ALL'}]}],
    }
    if questions[-1] != learner_check:
        raise ValueError('Expected the reviewed Open Stock Orders benchmark question with ALL.')
    for question in questions[:-1]:
        if any(truth['search_target_title'] not in titles for truth in question['ground_truth']):
            raise ValueError('An evaluation question references a missing sample target.')
    index = website / 'index.html'
    html = index.read_text()
    updated, count = re.subn(r'data-search-space="[^"]*"', f'data-search-space="{LEARNER_SPACE}"', html)
    if count != 1:
        raise ValueError('Expected exactly one widget search-space attribute.')
    if not (website / 'open-stock-orders' / 'index.html').is_file():
        raise ValueError('Deploy the supplied report before preparing learner downloads.')
    output = website / 'lab-files'
    if output.exists():
        raise ValueError('Workshop downloads already exist; refusing to overwrite a prepared environment.')
    # A same-origin rehearsal may be mounted under a subdirectory. Keep report
    # navigation and root-relative assets within that copy as well as its URLs.
    pages = {index: updated}
    if website_path:
        for page in website.rglob('*.html'):
            content = pages.get(page, page.read_text())
            pages[page] = re.sub(r'((?:href|src)=[\"\'])/(?!/)',
                                 lambda match: match[1] + website_path + '/', content)
    output.mkdir()
    for name, value in [('search-targets.json', targets), ('target-value-sets.json', sets),
                        ('brokerage-quick-check.json', questions)]:
        (output / name).write_text(json.dumps(value, indent=2) + '\n')
    (output / 'index.html').write_text('''<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Demo Brokerage — Workshop Files</title>
<style>body{font:17px/1.6 system-ui,sans-serif;color:#222;background:#f5f4f1;margin:0}
main{max-width:760px;margin:48px auto;padding:32px;background:white;border-radius:8px}
h1{line-height:1.2}a{color:#245e64}li{margin:18px 0}code{background:#f3f2ef;padding:2px 5px}</style>
</head><body><main><p>Oracle Trusted Answer Search · Demo Brokerage</p>
<h1>Workshop Files</h1><p>Download these three files before starting. Keep their contents unchanged.</p>
<ul><li><a href="search-targets.json" download>search-targets.json</a> — 20 existing report destinations.</li>
<li><a href="target-value-sets.json" download>target-value-sets.json</a> — five sets of report input values.</li>
<li><a href="brokerage-quick-check.json" download>brokerage-quick-check.json</a> — five queries and expected results (run after creating your search target).</li></ul>
<h2>Open Stock Orders</h2><p><a href="../open-stock-orders/" target="_blank" rel="noopener">Open the report</a> you will make searchable.</p>
<p>All report data is fictional. This page cannot place or change orders.</p>
<p>The brokerage search widget uses your <code>Brokerage Lab</code> space after you publish it.</p>
</main></body></html>\n''')
    for page, content in pages.items():
        page.write_text(content)
    return {'download_targets': len(targets), 'download_value_sets': len(sets),
            'download_evaluation_queries': len(questions), 'widget_space': LEARNER_SPACE}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--sample', required=True, type=Path)
    parser.add_argument('--assets', required=True, type=Path)
    parser.add_argument('--website', required=True, type=Path)
    parser.add_argument('--origin', required=True)
    parser.add_argument('--website-path', default='', help='Optional subdirectory for an isolated same-origin rehearsal.')
    args = parser.parse_args()
    print(json.dumps(build(args.sample, args.assets, args.website, args.origin, args.website_path), sort_keys=True))


if __name__ == '__main__':
    main()
