from pathlib import Path
import json,re,zipfile,shutil
R=Path(__file__).resolve().parents[1]
assert R.name=='livestack-workshop-hightech'
V=R/'validation'
D=json.loads((V/'source-baseline/fixture-data.json').read_text())
catalog=[
('Power control module','High-Tg FR-4 / lead-free','SMT assembly and electrical test','Power electronics','MOSFET switching stability and low leakage current'),
('Gate driver module','High-Tg FR-4 / lead-free','SMT assembly and isolation test','Power electronics','Gate timing and switching noise control'),
('Motor control module','High-Tg FR-4 / lead-free','SMT assembly and load test','Motor control','Current sensing and stable motor control'),
('Encoder interface module','FR-4 / lead-free','SMT assembly and signal test','Motor control','Pulse timing and position signal integrity'),
('Sensor interface module','FR-4 / lead-free','SMT assembly and calibration','Sensing','Low-noise analog input and measurement accuracy'),
('Temperature monitor module','FR-4 / lead-free','SMT assembly and thermal test','Sensing','Temperature measurement and thermal drift'),
('Pressure interface module','FR-4 / lead-free','SMT assembly and calibration','Sensing','Bridge excitation and pressure signal accuracy'),
('Digital input module','FR-4 / lead-free','SMT assembly and functional test','Industrial I/O','Input isolation and logic threshold integrity'),
('Communication module','FR-4 / lead-free','SMT assembly and communication test','Communications','Bus signal integrity and communication reliability'),
('Digital output module','FR-4 / lead-free','SMT assembly and load test','Industrial I/O','Output switching and short-circuit detection'),
('Servo interface module','High-Tg FR-4 / lead-free','SMT assembly and signal test','Motor control','Command timing and feedback signal accuracy'),
('Power supply module','High-Tg FR-4 / lead-free','SMT assembly and burn-in','Power electronics','Voltage regulation and thermal stability')]
name_map={r['component_name'].split(' P01')[0]:catalog[i][0] for i,r in enumerate(D['components'][:12])}
mapping=[
('SEER MANUFACTURING','SEER HIGHTECH'),('SEER_MANUFACTURING','SEER_HIGHTECH'),('Seer Manufacturing','Seer HighTech'),('NINA_MANUFACTURING','NINA_HIGHTECH'),
('seer-manufacturing','seer-hightech'),('livestack-manufacturing','livestack-hightech'),('manufacturing-platform-handoff-loader','hightech-platform-handoff-loader'),('manufacturing-production-quality-graph-studio','hightech-production-quality-graph-studio'),
('Connected Manufacturing Solutions','Connected HighTech Solutions'),('Ask Manufacturing Questions','Ask HighTech Questions'),('Build a Manufacturing Agent','Build a HighTech Agent'),
('New York Manufacturing Region','New York Electronics Region'),('Chicago Manufacturing Region','Chicago Electronics Region'),
('LOT-ST-91A7','LOT-SEMI-91A7'),('LOT-ST-220','LOT-SEMI-220'),('CERT-ST-91A7','CERT-SEMI-91A7'),('Material lot ST-91A7','Semiconductor lot SEMI-91A7'),('Steel lot ST-220','Semiconductor lot SEMI-220'),('Material certificate ST-91A7','Lot certificate SEMI-91A7'),
('MACHINE-CNC-017','MACHINE-ATE-017'),('CNC machine 017','Electrical test station 017'),('MACHINE-GR-003','MACHINE-SMT-003'),('Grinding machine 003','SMT placement machine 003'),('Steel supplier 044','Semiconductor supplier 044'),('Dimensional inspection 0199','Electrical inspection 0199'),
('precision bearing wear and dimensional defects requiring quality review','power control module leakage current and switching faults requiring quality review'),
('precision bearing with low vibration and tight dimensional tolerance','power control module with stable MOSFET switching and low leakage current'),
('machining capacity and material availability','electronics assembly capacity and semiconductor availability'),
('bearing dimensional-tolerance concern','power-module leakage-current concern'),('bearing-quality concern','power-module quality concern'),
('Dimensional inspection found out-of-tolerance parts; isolate the material lot and inspect machine setup.','Electrical test found out-of-spec modules; isolate the semiconductor lot and check test-station calibration.'),
('Inspection measurements are within tolerance; continue routine sampling.','Electrical test measurements are within limits; continue routine sampling.'),
('Industrial Customer Site','Electronics Customer Site'),('materialCertificate','lotCertificate'),('inspectionReport','electricalTestReport'),
('material certificates','lot certificates'),('material certificate','lot certificate'),('material-certificate','lot-certificate'),
('Work center','Work center'),(': machining',': SMT assembly'),(': inspection',': electrical test'),(': assembly',': module integration'),(': dispatch',': packing and fulfillment'),
]
mapping+=list(name_map.items())
def convert(t):
 for a,b in mapping:t=t.replace(a,b)
 # Business identity in prose, while keeping ordinary manufacturing terms legitimate.
 for a,b in [('manufacturing schema','HighTech schema'),('manufacturing tables','HighTech tables'),('manufacturing data','HighTech data'),('manufacturing objects','HighTech objects'),('manufacturing labs','HighTech labs'),('manufacturing notebook','HighTech notebook'),('Manufacturing notebook','HighTech notebook'),('manufacturing question','HighTech question'),('Manufacturing question','HighTech question'),('manufacturing workshop','HighTech workshop'),('manufacturing result','HighTech result'),('manufacturing lab banner','HighTech lab banner'),('manufacturing-region','electronics-region'),('Manufacturing assistant','HighTech assistant'),('manufacturing assistant','HighTech assistant'),('manufacturing decision','electronics production decision'),('manufacturing agent','HighTech agent'),('Manufacturing agent','HighTech agent'),('manufacturing production-quality-network','HighTech production-quality-network')]:t=t.replace(a,b)
 return t
# Convert all learner text surfaces; keep copied historical evidence unchanged.
for p in list(R.rglob('*')):
 if not p.is_file() or V in p.parents:continue
 if p.suffix in ('.md','.json','.dsnb','.svg','.html','.tf','.tmpl'):
  p.write_text(convert(p.read_text()))
 if any(a in p.name for a in ['manufacturing-production','seer-manufacturing','livestack-manufacturing']):p.rename(p.with_name(convert(p.name)))
# Domain catalog: change each complete record, preserving IDs and costs.
sql=convert((V/'source-loader.sql').read_text())
for row in D['components']:
 i=(row['component_id']-1)%12
 name,grade,route,cat,sub=catalog[i]
 fields=dict(row)
 fields.update(component_name=f'{name} P{row["plant_id"]:02d} Rev A',material_grade=grade,process_route=route,category=cat,subcategory=sub)
 def literal(x):return "'"+x.replace("'","''")+"'" if isinstance(x,str) else str(x)
 line='INSERT INTO components ('+', '.join(fields)+') VALUES ('+', '.join(literal(x) for x in fields.values())+');'
 sql=re.sub(r'^INSERT INTO components .*? VALUES \('+str(row['component_id'])+r', .*?;$',lambda m:line,sql,flags=re.M)
# Schema comments clarify scope and reuse the existing schema contract.
sql=sql.replace('Fictional manufacturing plants.','Fictional electronics assembly and test plants.')
sql=sql.replace('Plant-specific component revision, material grade and process route.','Plant-specific electronic module revision, board material grade and assembly/test route. Purchased packaged semiconductors are traced as material lots.')
sql=sql.replace('Synthetic industrial customer sites and their production contacts.','Synthetic electronic-device customer sites and their fulfillment contacts.')
sql=sql.replace('Inspection counts, defect percentages, rework and downtime measured for synthetic component runs.','Electrical test counts, rejected module percentages, rework and test downtime measured for synthetic module runs.')
sql=sql.replace('PROMPT Creating manufacturing','PROMPT Creating HighTech').replace('for manufacturing','for HighTech').replace('Checking manufacturing','Checking HighTech').replace('Invalid manufacturing','Invalid HighTech').replace('Manufacturing data,','HighTech data,').replace('Manufacturing objects','HighTech objects')
load=R/'stack/load_data';(load/'manufacturing-platform-handoff-loader.zip').unlink()
p=load/'hightech-platform-handoff-loader.sql';p.write_text(sql)
with zipfile.ZipFile(load/'hightech-platform-handoff-loader.zip','w',zipfile.ZIP_DEFLATED) as z:z.writestr(p.name,p.read_bytes())
# Parse fixture from canonical SQL with the source's balanced SQL value parser.
parser=(V/'source-baseline/validate.py').read_text(); code=parser[parser.index('def split_values'):parser.index("fixture=json.loads")]
ns={'sql':sql,'re':re,'check':lambda *a:None};exec(code,ns)
(V/'fixture-data.json').write_text(json.dumps(ns['D'],indent=2))
(V/'domain-map.json').write_text(json.dumps({'scenario':'Electronic module assembly and electrical test using purchased packaged semiconductor lots; no wafer fabrication or software-service business.','catalog':catalog,'text_mapping':mapping,'schema_policy':'Keep 15 tables and 18 foreign keys; generic component/plant/order names remain. Components are sellable electronic module revisions. Production orders are customer-backed build commitments, not a second sales-order table. Trace entities record purchased semiconductor lots, test equipment, suppliers and lot certificates.'},indent=2))
# Rewrite the opening around a single coherent model.
p=R/'introduction/introduction.md';t=p.read_text().replace('An inspection has flagged a dimensional concern in a precision bearing.','Electrical testing has flagged excessive leakage current in a power control module assembled with a purchased semiconductor lot.').replace('a manufacturing planning board','an electronics assembly planning board')
t=t.replace('SEER HIGHTECH is a fictional manufacturer. This diagram shows how customer sites, plants, component revisions, production orders, and order lines connect.','SEER HIGHTECH assembles and tests electronic control modules using purchased packaged semiconductors. It does not fabricate wafers. `COMPONENTS` holds plant-specific module revisions; `PRODUCTION_ORDERS` records customer-backed build commitments for those modules. Test observations flag modules for review, and the graph traces shared semiconductor lots, suppliers, test equipment, and lot certificates before fulfillment.\n\nThis diagram shows how customer sites, plants, module revisions, production orders, and order lines connect.')
t=t.replace('specifies a material grade and process route','specifies a board material grade and assembly/test route')
t=re.sub(r'## Running the manufacturing demo[\s\S]*?(?=## Acknowledgements)','## Running the HighTech demo\n\nA HighTech application can use these queries to review module test failures, trace affected build commitments, and assess fulfillment options. The supporting stack provisions the workshop database and services; it does not deploy a separate application server.\n\n',t)
p.write_text(t)
# Remove claims about the source-only AX-400 application while retaining the existing example positions.
p=R/'production-operations-dashboard/production-operations-dashboard.md';t=p.read_text();t=re.sub(r'The live SEER HIGHTECH application presents[^\n]+','An operations application can show module test alerts, customer build commitments, and candidate assembly plants using the queries in this workshop.',t);p.write_text(t)
p=R/'production-quality-network/production-quality-network.md';t=p.read_text();t=re.sub(r'The live SEER HIGHTECH application shows[^\n]+','An application can display the shared semiconductor lot, electrical test station, and customer build commitments as a quality-review network.',t).replace('The application also exposes the graph query and supporting records.','The same application can expose the graph query and supporting records.').replace('described in the schema contract','provided in the final comment of the [loader SQL](../stack/load_data/hightech-platform-handoff-loader.sql)');p.write_text(t)
p=R/'plant-routing-spatial/plant-routing-spatial.md';t=p.read_text();t=re.sub(r'The live SEER HIGHTECH application shows[^\n]+','An application can map the electronics assembly plants and customer delivery points used in these queries.',t);p.write_text(t)
# Source-only measured AutoML results are not HighTech results.
p=R/'quality-review-oml/quality-review-oml.md';t=p.read_text();t=re.sub(r'The example leaderboard shows[^\n]+','Compare the models and their balanced accuracy in your run. Otto also checks whether each model identifies the business outcome he cares about. Open the model details and inspect the confusion matrix.',t);t=re.sub(r'The example GLM confusion matrix shows[^\n]+','Read the confusion matrix and evaluation metrics from your run. The labels are generated from the same test measurements used for training, so a high score does not demonstrate future predictive quality. The next task creates a separate GLM using SQL.',t);t=t.replace('inspection measurements behind each score','electrical-test measurements behind each score');p.write_text(t)
# Preserve notebook structure and clear cached outputs; prevent blank SQL first line.
for p in R.rglob('*.dsnb'):
 d=json.loads(p.read_text())
 for n in d:
  for a in n['paragraphs']:
   a['result']=None
   if a['message'] and a['message'][0].strip()=='%sql':
    while len(a['message'])>1 and not a['message'][1].strip():a['message'].pop(1)
 p.write_text(json.dumps(d,indent=2))
# Map every screenshot to the original instruction; retain only generic compatible UI.
keep={'sql-connection.jpg','sql-embedding-model.jpg','graph-launch.jpg','graph-studio-overview.png','graph-import-dialog.png','oml-launch.jpg','oml-home.jpg','sql-duality-contract.png','sql-oml-model.png','sql-ai-object-list.png'}
personas={'jessica.png','thomas.png','gilly.png','bob.png','moon.png','otto.png','nina.png'}
coverage=[]
for p in R.rglob('*.md'):
 if V in p.parents:continue
 t=p.read_text();out=[];heading=''
 for line in t.splitlines():
  if line.lstrip().startswith('#'):heading=line.strip()
  m=re.search(r'!\[([^\]]*)\]\((images/[^ )]+)',line)
  if m:
   im=p.parent/m[2]
   if im.name not in personas and not im.name.startswith('seer-hightech'):
    status='retained_generic' if im.suffix=='.svg' or im.name in keep else 'awaiting_authentic_hightech_capture'
    coverage.append({'lesson':str(p.relative_to(R)),'section':heading,'image':str(im.relative_to(R)),'alt':m[1],'original_markdown':line,'status':status})
    if status.startswith('awaiting'):
     if im.exists():
      dst=V/'source-captures'/im.relative_to(R);dst.parent.mkdir(parents=True,exist_ok=True);shutil.move(im,dst)
     continue
  out.append(line)
 p.write_text('\n'.join(out)+'\n')
# Any unused old domain captures are evidence, not learner content.
for p in list(R.rglob('*')):
 if V in p.parents or not p.is_file() or p.suffix not in ('.jpg','.png'):continue
 if p.name not in personas and not p.name.startswith('seer-hightech') and p.name not in keep:
  dst=V/'source-captures'/p.relative_to(R);dst.parent.mkdir(parents=True,exist_ok=True);shutil.move(p,dst)
(V/'screenshot-coverage.json').write_text(json.dumps(coverage,indent=2))
# Reuse the source's validation logic, scoped entirely to target evidence.
validator=convert((V/'source-baseline/validate.py').read_text())
(V/'validate.py').write_text(validator)
print('Converted catalog, observations, graph keys, JSON requirements, prompts, notebooks and loader.')
print('Screenshot placements:',len(coverage),'pending:',sum(x['status'].startswith('awaiting') for x in coverage))
