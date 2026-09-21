#!/usr/bin/env python3
"""Offline contract and workshop-reference checks. This does not execute Oracle SQL."""
import argparse,ast,hashlib,json,re,struct,sys,zlib,xml.etree.ElementTree as ET
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--source',type=Path);p.add_argument('--reference-evidence',type=Path,help='External directory containing reference hashes and path mapping');a=p.parse_args()
if a.source and not a.reference_evidence:p.error('--source requires --reference-evidence; keep provenance outside this workshop')
root=Path(__file__).resolve().parents[1];v=root/'validation';errors=[];checks={}
def require(ok,msg):
 if not ok:errors.append(msg)
contract=json.loads((v/'schema-contract.json').read_text());objects=contract['objects'];columns={n:set(o['columns']) for n,o in objects.items()}
for n,cols in contract['lab_added_columns'].items():columns[n].update(cols)
for fk in contract['foreign_keys']:
 require(fk['column'] in columns[fk['table']] and fk['key'] in columns[fk['references']],f'Invalid FK: {fk}')
checks['foreign_key_contracts']=len(contract['foreign_keys'])
if (v/'erd-contract.json').is_file():
 erd=json.loads((v/'erd-contract.json').read_text())
 require((root/erd['asset']).is_file(),'ERD image missing')
 for name in erd['entities']:require(name in objects,f'ERD entity missing from schema: {name}')
 for fk in erd['relationships']:require(fk in contract['foreign_keys'],f'ERD relationship differs from schema: {fk}')
 checks['erd_relationships']=len(erd['relationships'])

manifests=[];labpaths=[]
for f in sorted((root/'workshops').rglob('manifest.json')):
 d=json.loads(f.read_text());manifests.append(d)
 for t in d['tutorials']:
  if not t['filename'].startswith('http'):
   file=(f.parent/t['filename']).resolve();require(file.is_file(),f'Missing manifest target {file}');labpaths.append(file)
require(manifests[0]==manifests[1],'Sandbox and tenancy navigation differ')
labpaths=sorted(set(labpaths));slugs={f.stem:f for f in labpaths};checks['local_labs']=len(labpaths);checks['navigation_variants']=len(manifests)
links=0;sqlblocks=[];tasks={}
for f in labpaths+list(v.glob('*.md'))+[root/'PHASE1.md']:
 s=f.read_text();require(s.count('<copy>')==s.count('</copy>'),f'Copy wrapper imbalance {f.name}')
 require(len(re.findall(r'^\s*```',s,re.M))%2==0,f'Fence imbalance {f.name}')
 require(s.count('<details>')==s.count('</details>'),f'Details imbalance {f.name}')
 tasks[f.stem]=len(re.findall(r'^## Task \d+:',s,re.M))
 for url in re.findall(r'!?\[[^\]]*\]\(([^\s)]+)(?:\s+"[^"]*")?\)',s):
  if url.startswith(('http','mailto:','#')):continue
  if url.startswith('?lab='):
   slug=url[5:].split('#')[0];require(slug in slugs,f'Unknown lab link {url} in {f.name}')
   if '#' in url and slug in slugs:
    anchor=url.split('#',1)[1].lower().replace(':','').replace(' ','')
    headings=[re.sub(r'[^a-z0-9]','',x.lower()) for x in re.findall(r'^#+ (.*)',slugs[slug].read_text(),re.M)]
    require(re.sub(r'[^a-z0-9]','',anchor) in headings,f'Unknown task anchor {url}')
  else:require((f.parent/url.split('#')[0]).is_file(),f'Broken local link {f.name}: {url}')
  links+=1
 if f in labpaths:
  for i,block in enumerate(re.findall(r'```sql\s*(.*?)```',s,re.S)):sqlblocks.append((str(f.relative_to(root)),i+1,block.replace('<copy>','').replace('</copy>','')))
checks['local_links']=links;checks['task_counts']=tasks;checks['sql_blocks']=len(sqlblocks)
# Keep source lab order, task counts and SQL exercise counts; numbering fix is allowed.
if a.source:
 source=a.source.resolve();before=json.loads((a.reference_evidence/'source-sha256.json').read_text());now={str(f.relative_to(source)):hashlib.sha256(f.read_bytes()).hexdigest() for f in source.rglob('*') if f.is_file()}
 require(now==before,'Source file content or inventory changed');checks['source_files_unchanged']=len(before)
 mapping=json.loads((a.reference_evidence/'source-map.json').read_text())
 for f in source.rglob('*.md'):
  dest=root/mapping[str(f.relative_to(source))];require(dest.is_file(),f'Missing transformed lab {dest}')
  old=f.read_text();new=dest.read_text()
  require(len(re.findall(r'^## Task \d+:',old,re.M))==len(re.findall(r'^## Task \d+:',new,re.M)),f'Task count changed {f.name}')
  require(len(re.findall(r'```sql',old))==len(re.findall(r'```sql',new)),f'SQL exercise count changed {f.name}')
 old=json.loads((source/'workshops/sandbox/manifest.json').read_text())
 expected=[mapping[str((source/'workshops/sandbox'/x['filename']).resolve().relative_to(source))] for x in old['tutorials'] if not x['filename'].startswith('http')]
 actual=[str((root/'workshops/sandbox'/x['filename']).resolve().relative_to(root)) for x in manifests[0]['tutorials'] if not x['filename'].startswith('http')]
 require(actual==expected,'Lab order changed')
# Domain detection rules are the only intentional prohibited vocabulary in this file.
# Exempt only this assignment's literal value, never a directory or the whole validator.
legacy_pattern = r'harbor|finance|financial|retail|bank(?:ing|s)?(?![a-z])|seer.?bank|peakgear|mortgage|payee|fulfillment|shipping(?:_cost|Cost)?|money.?launder|\b(?:aml|kyc|acct|sku|treasury|loans?|lending|merchants?|municipal|government|counties|citizens?|customers?|products?|order_items|orders_dv|risk_signals|financial_institutions)\b|(?<![a-z0-9])(?:bank_accounts|bank_graph|product_id|customer_id|shipping_cost)(?![a-z0-9])'
legacy=re.compile(legacy_pattern,re.I)
review=json.loads((v/'raster-review.json').read_text())
text_files=0;png_files=0;exception_uses=[]
def scan_text(value,where):
 match=legacy.search(value)
 require(not match,f'Domain residue {where}: {match.group() if match else ""}')
def scan_json(value,where):
 if isinstance(value,dict):
  for k,item in value.items():scan_text(k,where);scan_json(item,where)
 elif isinstance(value,list):
  for item in value:scan_json(item,where)
 elif isinstance(value,str):
  scan_text(value,where)
  # Notebook styles/forms may be JSON encoded inside a JSON string.
  if value.lstrip().startswith(('{','[')):
   try:nested=json.loads(value)
   except (ValueError,RecursionError):return
   scan_json(nested,where)
for f in sorted(root.rglob('*')):
 rel=str(f.relative_to(root));scan_text(rel,'path '+rel)
 if not f.is_file():continue
 raw=f.read_bytes()
 if f.suffix in ['.png','.jpg','.jpeg']:
  png_files+=1
  require(rel in review['images'],f'Image needs visual review: {rel}')
  require(review['images'].get(rel,{}).get('sha256')==hashlib.sha256(raw).hexdigest(),f'Image changed since visual review: {rel}')
  if f.suffix in ['.jpg','.jpeg']:
   require(raw.startswith(b'\xff\xd8'),f'Invalid JPEG: {rel}')
   continue
  require(raw.startswith(b'\x89PNG\r\n\x1a\n'),f'Invalid PNG: {rel}')
  pos=8
  while pos+12<=len(raw):
   n=struct.unpack('>I',raw[pos:pos+4])[0];kind=raw[pos+4:pos+8];chunk=raw[pos+8:pos+8+n];pos+=12+n
   if kind==b'tEXt':scan_text(chunk.decode('latin1'),rel+' metadata')
   elif kind==b'zTXt':
    key,data=chunk.split(b'\0',1);scan_text(key.decode('latin1'),rel+' metadata');scan_text(zlib.decompress(data[1:]).decode('latin1'),rel+' metadata')
   elif kind==b'iTXt':
    key,data=chunk.split(b'\0',1);flag=data[0];language,translated,value=data[2:].split(b'\0',2)
    scan_text((key+b' '+translated).decode('utf8'),rel+' metadata');scan_text((zlib.decompress(value) if flag else value).decode('utf8'),rel+' metadata')
  continue
 try:content=raw.decode('utf8')
 except UnicodeDecodeError:
  require(False,f'Unreviewed binary file: {rel}');continue
 text_files+=1
 if f.resolve()==Path(__file__).resolve():
  tree=ast.parse(content)
  assignments=[n for n in tree.body if isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='legacy_pattern' for t in n.targets)]
  require(len(assignments)==1,'Expected exactly one detection-rule assignment')
  for n in assignments:
   lines=content.splitlines(keepends=True);start=sum(map(len,lines[:n.value.lineno-1]))+n.value.col_offset;end=sum(map(len,lines[:n.value.end_lineno-1]))+n.value.end_col_offset
   content=content[:start]+'""'+content[end:];exception_uses.append('Detection regex literal in validation/validate.py')
 # Exact official footer and author credit phrases only; no broad word exemption.
 for phrase in ['Products A-Z','Oracle Database Product Management','Oracle Product Management']:
  if phrase in content:
   content=content.replace(phrase,'');exception_uses.append(rel+': official platform label')
 scan_text(content,rel)
 if f.suffix in ['.json','.dsnb']:
  try:scan_json(json.loads(content),rel+' decoded JSON')
  except ValueError:require(False,f'Invalid JSON: {rel}')
require(set(review['images'])=={str(f.relative_to(root)) for f in (p for p in root.rglob('*') if p.suffix in ['.png','.jpg','.jpeg'])},'Raster review inventory differs')
checks['domain_audit']={'text_files':text_files,'raster_files':png_files,'paths':'all files and directories','nested_json':'decoded recursively','raster_review':'hash-bound visual and OCR review','exceptions':exception_uses,'status':'failed' if any('Domain residue' in x or 'Image changed' in x for x in errors) else 'passed'}
for f in root.rglob('*.svg'):ET.parse(f)
checks['svg_xml_files']=len(list(root.rglob('*.svg')))
# Validate notebook export structure, embedded configuration JSON, source Python, and absence of cached results.
paragraphs=0;python_cells=0
for f in root.rglob('*.dsnb'):
 for b in json.loads(f.read_text()):
  if b.get('templateConfig'):json.loads(b['templateConfig'])
  for pp in b['paragraphs']:
   paragraphs+=1;require(pp.get('result') is None,f'Cached result in {f.name}')
   for k in ['forms','visualizationConfig','dynamicFormParams']:
    if pp.get(k):json.loads(pp[k])
   msg='\n'.join(pp['message'])
   if msg.lstrip().startswith('%python-pgx'):
    ast.parse('\n'.join(msg.splitlines()[1:]));python_cells+=1
checks['notebook_paragraphs']=paragraphs;checks['python_cells_parsed']=python_cells
# Static object/qualified-column checks are deliberately bounded, not an Oracle syntax parser.
oracle={'ALL_MINING_MODELS','USER_MINING_MODELS','USER_JSON_DUALITY_VIEWS','USER_CLOUD_AI_PROFILES','USER_CLOUD_AI_PROFILE_ATTRIBUTES','USER_AI_AGENTS','USER_AI_AGENT_TOOLS','USER_AI_AGENT_TEAM_HISTORY','USER_AI_AGENT_TOOL_HISTORY'}
qualified=0;refs=set();unknown=[]
for file,num,block in sqlblocks:
 clean=re.sub(r'--[^\n]*','',block);clean=re.sub(r"'(?:''|[^'])*'",' ',clean)
 ctes=set(re.findall(r'\b(\w+)\s+AS\s*\(',clean,re.I));ctes={x.upper() for x in ctes}
 aliases={}
 for m in re.finditer(r'\b(?:FROM|JOIN)\s+(\w+)\b(?:\s+(\w+))?',clean,re.I):
  name=m[1].upper();alias=(m[2] or m[1]).upper()
  if name=='GRAPH_TABLE':continue
  refs.add(name)
  if name not in objects and name not in oracle and name not in ctes:unknown.append(f'{file} SQL {num}: {name}')
  if name in objects:
   aliases[name]=name
   if alias not in {'WHERE','WITH','JOIN','ORDER','CROSS','LEFT','FETCH','GROUP','ON'}:aliases[alias]=name
 for alias,col in re.findall(r'\b(\w+)\.(\w+)\b',clean):
  if alias.upper() in aliases:
   qualified+=1;name=aliases[alias.upper()]
   require(col.upper() in columns[name],f'{file} SQL {num}: unknown {name}.{col}')
require(not unknown,'Unknown FROM/JOIN objects: '+str(unknown))
checks['referenced_objects']=sorted(refs);checks['qualified_columns_checked']=qualified
# JSON contract and fixture arithmetic.
dual=(root/'reservation-duality/reservation-duality.md').read_text();dash=(root/'guest-operations-dashboard/guest-operations-dashboard.md').read_text()
for key in ['guestId','propertyId','checkIn','checkOut','nightLineId','offerId','roomNights','nightlyRate']:
 require(key in dual,f'Missing duality key {key}')
for key in ['offerId','roomNights']:
 require('$.%s'%key in dash,f'Missing dashboard JSON path {key}')
for raw in re.findall(r"SELECT JSON\(\s*'(\{.*?\})'\s*\)",dual,re.S):
 payload=json.loads(raw);require(sum(x['roomNights']*x['nightlyRate'] for x in payload['items'])+payload['serviceFee']==payload['total'],'JSON fixture arithmetic')
checks['json_fixture_contract']='passed'
# All source images accounted for; only approved generic PNGs may remain.
assets=json.loads((v/'screenshot-inventory.json').read_text());actual_png={str(f.relative_to(root)) for f in (p for p in root.rglob('*') if p.suffix in ['.png','.jpg','.jpeg'])}
allowed={x['target_asset'] for x in assets if x['status'] in ['retained_generic','regenerated_local_capture','generated_illustration'] and x['target_asset'].endswith(('.png','.jpg','.jpeg'))}
require(actual_png==allowed,'Unclassified or missing raster assets')
checks['source_assets_accounted_for']=sum(x['asset_id'].startswith('A') for x in assets)
checks['new_image_assets']=sum(not x['asset_id'].startswith('A') for x in assets)
checks['limits']=['No Oracle SQL execution or compilation','No live DDL, grants, loader, AI-provider, or notebook-import validation','Static SQL checks cover FROM/JOIN objects and qualified base columns; unqualified columns, expression types and PL/SQL semantics need live checks']
result={'status':'PASS' if not errors else 'FAIL','checks':checks,'errors':errors}
saved=result if not errors else {'status':'FAIL','errors':['Validation failed; rerun for current diagnostics.']}
(v/'static-results.json').write_text(json.dumps(saved,indent=2)+'\n');print(json.dumps(result,indent=2));sys.exit(bool(errors))
