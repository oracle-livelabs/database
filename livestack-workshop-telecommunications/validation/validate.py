#!/usr/bin/env python3
"""Offline workshop checks. No Oracle connection and no provisioning operations."""
from pathlib import Path
import ast,collections,datetime,hashlib,json,re,sqlite3,sys,xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1]
SQL=ROOT/'stack/load_data/telecommunications-platform-handoff-loader.sql'
checks=[]
def check(name,condition,detail=''):
 checks.append({'check':name,'passed':bool(condition),'detail':detail})
def split_sql(text):
 out=[];start=0;depth=0;quote=False;i=0
 while i<len(text):
  c=text[i]
  if c=="'":
   if quote and i+1<len(text) and text[i+1]=="'":i+=2;continue
   quote=not quote
  elif not quote:
   if c=='(':depth+=1
   elif c==')':depth-=1
   elif c==',' and depth==0:out.append(text[start:i].strip());start=i+1
  i+=1
 out.append(text[start:].strip());return out

def value(s):
 if not isinstance(s,str):return s
 if s=='NULL':return None
 if s.startswith("'") and s.endswith("'"):return s[1:-1].replace("''", "'")
 try:return int(s)
 except ValueError:
  try:return float(s)
  except ValueError:return s

def analyze():
 sql=SQL.read_text();tables={};fks=[];pks={}
 for m in re.finditer(r'CREATE TABLE (\w+) \((.*?)\n\);',sql,re.S|re.I):
  name=m[1].lower();cols={}
  for d in split_sql(m[2]):
   if d.upper().startswith('CONSTRAINT'):
    pk=re.search(r'PRIMARY KEY \((.*?)\)',d,re.I)
    if pk:pks[name]=[x.strip().lower() for x in pk[1].split(',')]
    fk=re.search(r'FOREIGN KEY \((.*?)\) REFERENCES (\w+) \((.*?)\)',d,re.I)
    if fk:fks.append({'child':name,'columns':fk[1].lower().split(', '),'parent':fk[2].lower(),'parent_columns':fk[3].lower().split(', ')})
   else:
    a=d.split(None,1);cols[a[0].lower()]=a[1]
  tables[name]=cols
 data=collections.defaultdict(list)
 for m in re.finditer(r'^INSERT INTO (\w+) \((.*?)\) VALUES \((.*)\);$',sql,re.M):
  if m[1].lower() not in tables:continue
  cols=split_sql(m[2]);vals=split_sql(m[3]);check('insert_arity',len(cols)==len(vals),m[1])
  data[m[1].lower()].append(dict(zip(cols,map(value,vals))))
 check('15_loader_tables',len(tables)==15,str(len(tables)))
 check('18_foreign_keys',len(fks)==18,str(len(fks)))
 for t,rs in data.items():
  keys=[tuple(row[k] for k in pks[t]) for row in rs]
  check('unique_primary_keys',len(set(keys))==len(keys),t)
  check('insert_columns_exist',all(set(row)<=set(tables[t]) for row in rs),t)
 for fk in fks:
  parent_keys={tuple(row[k] for k in fk['parent_columns']) for row in data[fk['parent']]}
  missing=[row for row in data[fk['child']] if all(row[k] is not None for k in fk['columns']) and tuple(row[k] for k in fk['columns']) not in parent_keys]
  check('foreign_key_fixture',not missing,f"{fk['child']} -> {fk['parent']}")
 fixture=json.loads((ROOT/'validation/fixture.json').read_text())
 fixture={t:[{k:value(v) for k,v in row.items()} for row in rs] for t,rs in fixture.items()}
 check('fixture_matches_every_seed_insert',fixture=={t:rs for t,rs in data.items() if rs},str(sum(map(len,data.values()))))
 orders={x['order_id']:x for x in data['service_orders']};plans={x['plan_id']:x for x in data['service_plans']}
 totals=collections.defaultdict(float);accepted=collections.defaultdict(float);charges=collections.defaultdict(float)
 for row in data['service_order_lines']:
  order=orders[row['order_id']];plan=plans[row['plan_id']];qty=row['connection_count'];fee=row['monthly_fee']
  check('order_line_site',order['site_id']==plan['site_id'])
  check('order_line_quantity_price',qty>0 and qty==int(qty) and fee>=0)
  totals[row['order_id']]+=qty*fee
  if order['order_status'] in ('confirmed','active','completed'):
   accepted[row['plan_id']]+=qty;charges[row['plan_id']]+=qty*fee
 check('order_totals',all(totals[k]+row['activation_fee']==row['order_total'] for k,row in orders.items()),str(len(orders)))
 check('one_month_fixture',all(x['period_start']=="DATE '2026-09-01'" and x['period_end']=="DATE '2026-10-01'" for x in orders.values()))
 check('reserved_ids_absent',900001 not in orders and 990001 not in {x['order_line_id'] for x in data['service_order_lines']})
 check('lab2_plan',plans[1]['site_id']==1 and plans[1]['monthly_fee']==125)
 reports={x['report_id']:x for x in data['subscriber_reports']};busy=collections.Counter()
 for row in data['report_plan_mentions']:
  if reports[row['report_id']]['utilization_pct']>=60:busy[row['plan_id']]+=1
 labels=collections.Counter('SURGE' if accepted[k]>=45 and busy[k]>=2 else 'STABLE' for k in plans)
 check('oml_classes',labels=={'SURGE':96,'STABLE':96},str(dict(labels)))
 check('support_features_bounded',all(-1<=x['sentiment']<=1 and 0<=x['utilization_pct']<=100 and 0<=x['severity_score']<=100 and x['dropped_sessions']>=0 and x['outage_minutes']>=0 and x['data_volume_gb']>=0 for x in reports.values()))
 check('technology_variants',set(x['access_technology'] for x in plans.values())=={'5G','GPON','NB-IoT'})
 # Geometry constructor checks are numeric checks, not Oracle geometry validation.
 geometries=[]
 for t in ('network_sites','subscribers'):
  for row in data[t]:
   m=re.fullmatch(r'MDSYS.SDO_GEOMETRY\(2001,8307,MDSYS.SDO_POINT_TYPE\(([-\d.]+),([-\d.]+),NULL\),NULL,NULL\)',row['location'])
   check('wgs84_point',bool(m),t)
   if m:
    lon,lat=map(float,m.groups());check('point_bounds',-180<=lon<=180 and -90<=lat<=90)
    if t=='network_sites':check('point_columns',lon==row['longitude'] and lat==row['latitude'])
 for row in data['network_regions']:
  m=re.search(r'SDO_ORDINATE_ARRAY\((.*?)\)',row['boundary']);v=list(map(float,m[1].split(',')))
  check('region_ring_closed',v[:2]==v[-2:] and len(v)==10)
 # Graph reachability and required shared identifiers.
 entities={x['entity_id']:x for x in data['activation_entities']};adj=collections.defaultdict(set)
 for x in data['activation_relationships']:adj[x['from_entity']].add(x['to_entity'])
 check('shared_device',all(4 in adj[x] for x in (1,2,3)))
 pairs=[]
 for a in entities:
  for b in entities:
   if a>=b or entities[a]['entity_type']!='service_order' or entities[b]['entity_type']!='service_order':continue
   if max(entities[a]['risk_score'],entities[b]['risk_score'])<70:continue
   for e in adj[a]&adj[b]:
    if entities[e]['entity_type'] in ('device','ip_address','phone','email'):pairs.append((a,e,b))
 check('shared_identifier_pairs',len(pairs)==6,str(len(pairs)))
 frontier={1}
 for hops in range(1,5):frontier={b for a in frontier for b in adj[a]};check('graph_hop_fixture',bool(frontier),str(hops))
 air=collections.defaultdict(set)
 for x in data['airtime_transfers']:air[x['from_account_id']].add(x['to_account_id'])
 frontier={934}
 for hops in range(1,7):
  frontier={b for a in frontier for b in air[a]}
  if hops in (4,5):check('airtime_cycle',934 in frontier,str(hops))
  if hops==6:check('airtime_six_hop',bool(frontier))
 check('fresh_schema_guard',sql.index('Use a fresh workshop schema')<sql.index('CREATE TABLE network_sites') and not re.search(r'\bDROP TABLE\b',sql,re.I))
 check('separate_vector_column',not re.search(r'plan_embedding VECTOR',sql[:sql.index('PROMPT Loading NETWORK_SITES')],re.I))
 # Package flow includes precisely the designated loader.
 adb=(ROOT/'stack/adb.tf').read_text();check('deployment_loader_path','@load_data/'+SQL.name in adb)
 # Lesson content and structure.
 manifests=[json.loads(p.read_text()) for p in ROOT.glob('workshops/*/manifest.json')]
 check('manifest_variants_match',len(manifests)==2 and manifests[0]==manifests[1])
 lessons=[ROOT/'workshops/sandbox'/x['filename'] for x in manifests[0]['tutorials'] if not x['filename'].startswith('http')]
 blocks=[];tasks=0;links=0
 for path in lessons:
  check('manifest_target',path.is_file(),path.name)
  if not path.is_file():continue
  text=path.read_text();tasks+=len(re.findall(r'^## Task ',text,re.M))
  check('balanced_fences',len(re.findall(r'^\s*```',text,re.M))%2==0,path.name)
  check('copy_wrappers',text.count('<copy>')==text.count('</copy>'),path.name)
  check('details_tags',text.count('<details>')==text.count('</details>'),path.name)
  for i,block in enumerate(re.findall(r'```sql\s*\n(.*?)```',text,re.S)):blocks.append((str(path.resolve().relative_to(ROOT)),i+1,block.replace('<copy>','').replace('</copy>','').strip()))
 for p in ROOT.rglob('*.md'):
  for ref in re.findall(r'!?\[[^\]]*\]\(([^\n)]+)\)',p.read_text()):
   dest=ref.split(' "')[0]
   if dest.startswith(('http','mailto:','#')):continue
   if dest.startswith('?lab='):
    lab=dest.split('=')[1].split('#')[0];check('lab_link',lab in {p.parent.name for p in lessons},f'{p.name}: {dest}');continue
   links+=1;check('local_link',(p.parent/dest.split('#')[0]).exists(),f'{p.name}: {dest}')
 check('11_lessons',len(lessons)==11,str(len(lessons)));check('40_task_headings',tasks==40,str(tasks));check('60_sql_blocks',len(blocks)==60,str(len(blocks)))
 quiz=(ROOT/'final-quiz/final-quiz.md').read_text();check('seven_quiz_answers',len(re.findall(r'^\s*\* ',quiz,re.M))-3==7)
 # Notebook JSON and embedded JSON, Python syntax, no cached results.
 paragraphs=0;python_paragraphs=0;nested=0
 def walk(x):
  nonlocal nested
  if isinstance(x,dict):
   for k,v in x.items():
    if k in ('result','results','error','errors'):check('notebook_outputs_clear',not v,k)
    walk(v)
  elif isinstance(x,list):
   for v in x:walk(v)
  elif isinstance(x,str) and x[:1] in '[{':
   try:j=json.loads(x)
   except json.JSONDecodeError:return
   nested+=1;walk(j)
 for p in ROOT.rglob('*.dsnb'):
  j=json.loads(p.read_text());walk(j)
  for book in j:
   for para in book['paragraphs']:
    paragraphs+=1;lines=para.get('message',[])
    if lines and lines[0].strip()=='%python-pgx':
     ast.parse('\n'.join(lines[1:]));python_paragraphs+=1
 check('51_notebook_paragraphs',paragraphs==51,str(paragraphs));check('5_python_paragraphs',python_paragraphs==5,str(python_paragraphs))
 for p in ROOT.rglob('*.svg'):ET.parse(p)
 # Qualified columns on directly named tables/views, limited to aliases unique within a block.
 views={'service_plans_v':{'plan_id','plan_name','site_id','plan_category'},'network_sites_v':{'site_id','site_name','city','state_province'},'service_alerts_v':{'alert_id','severity_score','affected_subscribers','service_cases_opened'},'service_orders_dv':{'data'}}
 cols={t:set(c) for t,c in tables.items()};cols.update(views);cols['service_plans'].add('plan_embedding');refs=0
 for file,index,block in blocks:
  aliases=collections.defaultdict(set)
  for table,alias in re.findall(r'\b(?:FROM|JOIN|UPDATE)\s+(\w+)\s+(\w+)',block,re.I):
   if table.lower() in cols:aliases[alias.lower()].add(table.lower())
  for alias,col in re.findall(r'\b(\w+)\.(\w+)\b',block):
   if alias.lower() in aliases and len(aliases[alias.lower()])==1:
    table=next(iter(aliases[alias.lower()]));refs+=1;check('qualified_column',col.lower() in cols[table],f'{file} block {index}: {table}.{col}')
 # Lab and loader duality definitions agree apart from the teaching write permissions.
 dual=re.search(r'CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW.*?;',sql,re.S)[0]
 labdual=next(b for _,_,b in blocks if 'CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW' in b)
 norm=lambda s:re.sub(r'\s+','',s.lower().replace('with insert update','with update'))
 check('duality_ddl_matches',norm(dual)==norm(labdual))
 graph=re.search(r'CREATE PROPERTY GRAPH activation_fraud_network.*?;',sql,re.S)[0]
 labgraph=next(b for _,_,b in blocks if b.startswith('CREATE PROPERTY GRAPH'))
 check('graph_ddl_matches',norm(graph)==norm(labgraph))
 (ROOT/'validation/lab-sql.json').write_text(json.dumps([{'lesson':f,'block':i,'sql':b} for f,i,b in blocks],indent=2))
 contract={'owner':'LLUSER','tables':tables,'foreign_keys':fks,'primary_keys':pks,'fixture_counts':{t:len(v) for t,v in data.items()},'views':{k:sorted(v) for k,v in views.items()},'oml_classes':dict(labels),'qualified_column_references_checked':refs,'nested_notebook_json':nested}
 (ROOT/'validation/schema-contract.json').write_text(json.dumps(contract,indent=2))
 # Compact repeated checks, retaining every failure and aggregate evidence.
 summary=[]
 for name in dict.fromkeys(x['check'] for x in checks):
  group=[x for x in checks if x['check']==name];bad=[x['detail'] for x in group if not x['passed']]
  summary.append({'check':name,'passed':not bad and all(x['passed'] for x in group),'instances':len(group),'failures':bad,'detail':group[0]['detail'] if len(group)==1 else ''})
 report={'scope':'Offline only; does not compile Oracle SQL or execute database APIs.','checks':summary,'passed':all(x['passed'] for x in checks),'seed_rows':sum(map(len,data.values())),'sql_blocks':len(blocks),'task_headings':tasks,'local_links_checked':links,'columns_checked':refs}
 (ROOT/'validation/static-results.json').write_text(json.dumps(report,indent=2))
 print(json.dumps(report,indent=2));return report['passed']
if __name__=='__main__':sys.exit(0 if analyze() else 1)
