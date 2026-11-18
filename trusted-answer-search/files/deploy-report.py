#!/usr/bin/env python3
"""Copy the workshop report into an existing Trusted Answer Search Demo Brokerage website."""
import argparse
from pathlib import Path
import shutil
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--website-root',required=True,type=Path)
args=parser.parse_args()
website=args.website_root.resolve()
if not (website/'assets/css/brokerage-pages.css').is_file() or not (website/'index.html').is_file():
 parser.error('Expected the running Demo Brokerage website root, containing index.html and assets/css/brokerage-pages.css')
source=Path(__file__).resolve().parent/'open-stock-orders'
destination=website/source.name
if destination.exists():
 parser.error('Destination already exists. Review it before replacing an earlier workshop report.')
shutil.copytree(source,destination)
print('Report deployed at:',destination)
print('Use the website origin followed by /open-stock-orders/ as the report URL.')
