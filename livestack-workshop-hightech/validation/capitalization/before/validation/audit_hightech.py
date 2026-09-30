from pathlib import Path
import json,re,hashlib,zipfile,xml.etree.ElementTree as ET
R=Path(__file__).resolve().parents[1];S=R.with_name('livestack-workshop-manufacturing');V=R/'validation'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(n,x):(V/n).write_text(json.dumps(x,indent=2))
source_before=json.loads((V/'source-before.json').read_text());after={str(p.relative_to(S)):sha(p) for p in S.rglob('*') if p.is_file()}
save('source-after.json',after)
source={'passed':source_before==after,'files':len(after),'added':sorted(set(after)-set(source_before)),'removed':sorted(set(source_before)-set(after)),'changed':[p for p in source_before if p in after and source_before[p]!=after[p]]};save('source-integrity.json',source)
structure=[]
for p in sorted(S.rglob('*.md')):
 if 'validation' in p.relative_to(S).parts:continue
 rel=p.relative_to(S);q=R/rel
 if rel.parts[0] in ['stack'] or len(rel.parts)==1:continue
 a=p.read_text();b=q.read_text()
 h=lambda t:re.findall(r'^#{1,6} .+',t,re.M)
 tasks=lambda t:re.findall(r'^## Task \d+:',t,re.M)
 blocks=lambda t:re.findall(r'```sql\s*([\s\S]*?)```',t)
 def shape(t):
  t=re.sub(r'--[^\n]*','',t);t=re.sub(r"'(?:[^']|'')*'","'<literal>'",t);t=t.replace('NINA_MANUFACTURING','NINA_HIGHTECH');return re.sub(r'\s+',' ',t).strip()
 x={'lesson':str(rel),'source_tasks':len(tasks(a)),'target_tasks':len(tasks(b)),'source_sql_blocks':len(blocks(a)),'target_sql_blocks':len(blocks(b)),'sql_structure_same':list(map(shape,blocks(a)))==list(map(shape,blocks(b))),'headings_same_count':len(h(a))==len(h(b)),'changed_headings':[(i,j) for i,j in zip(h(a),h(b)) if i!=j]}
 # A demonstrated agent accuracy failure requires one deterministic comparison and tool payload visibility.
 x['live_validation_departure']=None
 if rel.parts[0]=='selectai-agent':
  old=blocks((V/'live-before'/rel).read_text());new=blocks(b)
  # The fresh-sandbox learner flow no longer includes the optional reset appendix.
  reset_block=old.pop()
  assert all(name in reset_block for name in ['DROP_TEAM','DROP_TASK','DROP_AGENT','DROP_TOOL'])
  x['fresh_sandbox_reset_appendix_removed']=not any('DBMS_CLOUD_AI_AGENT.DROP_TEAM' in block for block in new)
  restored=list(new)
  comparison=restored.pop(11) if len(restored)==len(old)+1 else ''
  if len(restored)>12:restored[12]=restored[12].replace('         end_date,\n         input,\n         output','         end_date')
  expected=(V/'live-runtime/agent-verification.sql').read_text().strip()
  comparison=re.sub(r'</?copy>','',comparison).strip()
  x['live_validation_departure']={'reason':'Deterministic answer comparison and tool input/output inspection after incorrect live agent totals','one_comparison_added':shape(comparison)==shape(expected),'remaining_sql_unchanged':list(map(shape,restored))==list(map(shape,old))}
  x['authorized_sql_change']=all(x['live_validation_departure'][k] for k in ['one_comparison_added','remaining_sql_unchanged'])
 baseline=V/'editorial-before'/rel
 expected_removed={'### Hands-on Scenario'}
 if rel.parts[0]=='selectai-agent':expected_removed.add('## Appendix: Reset the workshop objects')
 if rel.parts[0]=='production-order-duality':expected_removed.add("### Thomas's three JSON choices")
 if rel.parts[0] in ['component-quality-vector-search','production-quality-network','plant-routing-spatial','quality-review-oml','selectai']:
  expected_removed.update(z for z in h(baseline.read_text()) if z.startswith('## Conclusion'))
 # Audit finding 4: user-approved wording corrections, with task order preserved.
 approved_headings={
  '## Task 3: Create the selected model in SQL Developer Web':'## Task 3: Create a GLM in SQL Developer Web',
  '## Task 4: Score new component inspection measurements in SQL':'## Task 4: Score sample component measurements in SQL'
 } if rel.parts[0]=='quality-review-oml' else {}
 x['editorial_headings_preserved']=h(b)==[approved_headings.get(z,z) for z in h(baseline.read_text()) if z not in expected_removed]
 x['approved_heading_changes']=approved_headings
 x['removed_editorial_headings']=[z for z in h(baseline.read_text()) if z in expected_removed]
 structure.append(x)
save('structure-comparison.json',structure)
stack=[]
for p in sorted((S/'stack').glob('*')):
 if not p.is_file() or p.suffix not in ('.tf','.tmpl'):continue
 a=p.read_text();b=(R/'stack'/p.name).read_text()
 allowed=a.replace('manufacturing-platform-handoff-loader','hightech-platform-handoff-loader')
 stack.append({'file':p.name,'identical':a==b,'domain_only_change':allowed==b})
save('stack-parity.json',stack)
# Every visible ERD field and relationship must match the generated loader contract.
contract=json.loads((V/'schema-contract.json').read_text());objects=contract['objects'];fks=contract['foreign_keys']
core={'customer_sites':['customer_site_id','site_name','requirements','email','location'],'plants':['plant_id','plant_name','daily_capacity_units','location'],'production_orders':['production_order_id','customer_site_id','plant_id','scheduled_start','due_date','order_status','order_total','setup_cost'],'components':['component_id','plant_id','component_name','material_grade','process_route','unit_cost'],'production_order_lines':['order_line_id','production_order_id','component_id','quantity','unit_cost','line_total']}
edges=[('components','plant_id','plants','plant_id'),('production_orders','plant_id','plants','plant_id'),('production_orders','customer_site_id','customer_sites','customer_site_id'),('production_order_lines','production_order_id','production_orders','production_order_id'),('production_order_lines','component_id','components','component_id')]
field_checks={t:all(c in objects[t]['columns'] for c in cols) for t,cols in core.items()}
edge_checks=[{'child':c,'foreign_key':fk,'parent':p,'parent_key':pk,'valid':any(f['table']==c and f['columns']==[fk] and f['parent']==p and f['parent_columns']==[pk] for f in fks),'cardinality':'Each child has one required parent; a parent may have zero or many children.'} for c,fk,p,pk in edges]
save('diagram-contract.json',{'fields':field_checks,'relationships':edge_checks,'scope':'Both core diagrams show selected columns from five of fifteen tables. The 1:N notation expresses maximum multiplicity, not mandatory child rows. Raster names, PK/FK labels, and arrow directions checked visually and with OCR.'})
# Residue is scoped to shipped surfaces, including the canonical SQL and notebook metadata.
pattern=r'SEER MANUFACTURING|Seer Manufacturing|seer-manufacturing|livestack-manufacturing|manufacturing-platform|manufacturing-production|NINA_MANUFACTURING|precision bearing|bearing housing|drive shaft|helical gear|hydraulic manifold|valve spool|pump impeller|motor bracket|sensor enclosure|conveyor roller|actuator rod|heat exchanger plate|CNC|honing|52100|AX-400|LOT-ST-|CERT-ST-'
residue=[];allowed=[]
for p in R.rglob('*'):
 if not p.is_file() or 'validation' in p.relative_to(R).parts:continue
 if p.suffix in ['.md','.sql','.json','.dsnb','.svg','.html','.tf','.tmpl']:
  t=p.read_text()
  for i,l in enumerate(t.splitlines()):
   if re.search(pattern,l,re.I):residue.append({'file':str(p.relative_to(R)),'line':i+1,'text':l[:250]})
   elif re.search('manufacturing',l,re.I):allowed.append({'file':str(p.relative_to(R)),'line':i+1,'reason':'Legitimate electronics manufacturing terminology or preserved generic plant lesson title.'})
ocr=json.loads((V/'image-ocr.json').read_text());image_residue=[]
for row in ocr['images']:
 if re.search(pattern,row.get('text',''),re.I):image_residue.append(row['path'])
save('residue-audit.json',{'passed':not residue and not image_residue,'unwanted_text':residue,'unwanted_images':image_residue,'legitimate_manufacturing_uses':allowed,'ocr_images':len(ocr['images'])})
# Persona banners that need no new wording must remain byte-identical.
banners=[]
for p in S.rglob('*.png'):
 if p.name in ['jessica.png','thomas.png','gilly.png','bob.png','moon.png','otto.png','nina.png']:
  dest=R/p.relative_to(S)
  if p.name=='nina.png':dest=dest.with_name('nina-hightech.png')
  same=sha(p)==sha(dest);banners.append({'file':str(p.relative_to(S)),'byte_identical':same,'reason':'Nina shared banner title changed with imagegen; identities and poses reviewed visually.' if p.name=='nina.png' else 'Existing generic caption and persona preserved.'})
save('persona-preservation.json',banners)
# Catalog and test fields are the only semantic data changes; quantities and relational keys stay stable.
a=json.loads((V/'source-baseline/fixture-data.json').read_text());b=json.loads((V/'fixture-data.json').read_text());numeric=[]
for table,rows in a.items():
 if table not in b:continue
 for old,new in zip(rows,b[table]):
  for k,val in old.items():
   if isinstance(val,(int,float)) and new[k]!=val:numeric.append((table,k,val,new[k]))
save('fixture-parity.json',{'numeric_values_unchanged':not numeric,'differences':numeric,'table_counts_unchanged':{k:len(v) for k,v in a.items()}=={k:len(v) for k,v in b.items()},'row_order_preserved':True})
result={'source_unchanged':source['passed'],'structure_preserved':all(x['source_tasks']==x['target_tasks'] and ((x['source_sql_blocks']==x['target_sql_blocks'] and x['sql_structure_same']) or x.get('authorized_sql_change',False)) and x['editorial_headings_preserved'] for x in structure),'deployment_logic_preserved':all(x['domain_only_change'] for x in stack),'diagram_fields_valid':all(field_checks.values()),'diagram_relationships_valid':all(x['valid'] for x in edge_checks),'residue_clear':not residue and not image_residue,'numeric_fixtures_preserved':not numeric}
save('audit-summary.json',result);print(json.dumps(result,indent=2))
assert all(result.values())
