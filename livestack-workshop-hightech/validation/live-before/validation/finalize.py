from pathlib import Path
import json,re,hashlib,zipfile,shutil,collections
R=Path(__file__).resolve().parents[1];V=R/'validation';O=Path('/Users/mkowalik/Documents/Codex/2026-09-29/files-pasted-by-the-user-convert/outputs')
O.mkdir(exist_ok=True)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
static=json.loads((V/'static-results.json').read_text());audit=json.loads((V/'audit-summary.json').read_text())
assert static['passed'] and all(audit.values())
fixtures=json.loads((V/'fixture-data.json').read_text());contract=json.loads((V/'schema-contract.json').read_text())
length_errors=[]
for tab,rows in fixtures.items():
 for row in rows:
  for col,value in row.items():
   definition=contract['objects'][tab]['columns'].get(col,'')
   limit=re.search(r'VARCHAR2\((\d+)\)',definition)
   if limit and isinstance(value,str) and len(value)>int(limit[1]):length_errors.append([tab,col])
requirements=[json.loads(r['requirements'][6:-2]) for r in fixtures['customer_sites']]
assert not length_errors and all(set(x)=={'lotCertificate','electricalTestReport','deliveryWindow'} for x in requirements)
(V/'json-and-length-checks.json').write_text(json.dumps({'varchar_lengths_pass':not length_errors,'customer_requirement_documents':len(requirements),'required_keys':['lotCertificate','electricalTestReport','deliveryWindow'],'passed':True},indent=2))
coverage=json.loads((V/'screenshot-coverage.json').read_text());pending=[x for x in coverage if x['status'].startswith('awaiting')]
cap=['# HighTech capture checklist','', 'These are outstanding authentic captures. No HighTech database or application execution is claimed. Source images are preserved under `validation/source-captures/`; do not relabel them.','', 'After database access and phase authorization are supplied, run the loader on a fresh schema, execute the labs in sequence, verify the results, and replace each image beside its matching instruction. The six separate application views also require a HighTech application, which is not included in the source stack.','', '| Lesson | Instruction | Required capture |','| --- | --- | --- |']
for x in pending:cap.append('| '+x['lesson'].split('/')[0]+' | '+x['section'].lstrip('# ')+' | `'+x['image']+'` |')
cap+=['','## Live validation still required','','- Fresh SQLcl loader invocation, prerequisites, model loading, vectors, geometry and graph assertions.','- All nine labs and Getting Started in sequence, including reruns and cleanup.','- Graph Studio import, all three primary notebook SQL paragraphs, and optional PGX setup and algorithms.','- AutoML, SQL GLM creation/scoring, Select AI generated SQL/results, agent execution history and model restoration.','- Actual LiveLabs green-button provisioning and reservation/login flow, including the deployed quiz.','- HighTech application source/environment and six application captures. No app server was present in the supplied source.','']
(V/'capture-checklist.md').write_text('\n'.join(cap))
browser={'scope':'Local HTTP preview using Oracle hosted LiveLabs renderer, not sandbox provisioning or Oracle execution.','primary_lesson_pages':11,'alternate_tenancy_launcher':True,'all_present_learner_images_load':True,'image_note':'Expanded task images plus five lazy images opened directly; intro illustrations and changed Nina banner refreshed. Technical SVG and quiz badge loaded separately.','sql_copy_buttons':{'getting-started':1,'production-operations-dashboard':1,'production-order-duality':14,'component-quality-vector-search':8,'production-quality-network':6,'plant-routing-spatial':4,'quality-review-oml':5,'selectai':9,'selectai-agent':15},'getting_started_task2_crosslink':'Opened requested task and expanded its content.','quiz':{'correct':7,'total':7,'score_percent':100,'hightech_badge_loaded':True},'limitations':['No cloud reservation was created.','No Oracle database commands were run.','External destination links were preserved; external destinations were not comprehensively retested.','Responsive layouts and full accessibility audit were not run.']}
if not (V/'browser-results.json').exists(): (V/'browser-results.json').write_text(json.dumps(browser,indent=2))
# Explicitly separate new validation from copied historical source claims.
(V/'README.md').write_text('# HighTech maintainer evidence\n\nCurrent reports are in this directory. `source-baseline/` contains unchanged Manufacturing history and does not establish a HighTech pass. `source-captures/` retains obsolete source screenshots for the capture checklist. Neither directory is shipped.\n\nRun `validate.py` for static/SQLite checks and `audit_hightech.py` for source, structure, stack, diagram and residue checks. Run `ocr.swift` against the target after image changes. `convert_hightech.py` records the one-time conversion and is not a rerun command for an already converted target. `finalize.py` verifies and builds the archive. No script provisions cloud resources.\n')
# Save tool identity and actual asset choices outside the learner flow.
if not (V/'illustration-edits.json').exists(): (V/'illustration-edits.json').write_text(json.dumps({'tool':'built-in image_gen.imagegen','assets':[{'target':'introduction/images/seer-hightech-introduction.png','request':'Preserve Jessica and Thomas, poses, clothing, natural anatomy, Redwood palette and static Powtoon composition. Change SEER MANUFACTURING to SEER HIGHTECH; replace bearings, CNC mill and calipers with circuit modules, electrical test equipment and probes. Keep board headings and subtitle.'},{'target':'introduction/images/seer-hightech-erd-illustrated.png','request':'Preserve Jessica and the five-table ERD, exact field names, primary/foreign key labels and five 1:N relationships. Change organization title and replace machined-part illustrations with electronic modules, chips and test probes.'},{'target':'selectai/images/nina-hightech.png and selectai-agent/images/nina-hightech.png','request':'Change only top heading to Labs 7 & 8: Ask HighTech Questions and Build an AI Agent. Preserve Jessica, Nina, poses, clothing, roles, middle text and static Powtoon style.'}],'verification':'Visual review and macOS Vision OCR; diagram fields and relationships checked against loader. Other six persona banners byte-identical. No database/UI screenshot generated or relabeled.'},indent=2))
# The requested production filename does not imply completed live validation.
zip_path=R/'SEER-HighTech-LiveLabs-production.zip'
files=[];excluded=[]
for p in sorted(R.rglob('*')):
 if not p.is_file():continue
 rel=p.relative_to(R)
 reason=None
 if rel.parts[0]=='validation':reason='maintainer evidence, scripts, historical reports, or obsolete source captures'
 elif p==zip_path:reason='archive itself'
 elif any(x=='.DS_Store' or x=='__MACOSX' or x=='.AppleDouble' or x.startswith('._') for x in rel.parts):reason='macOS metadata'
 if reason:excluded.append({'path':str(rel),'reason':reason})
 else:files.append(p)
with zipfile.ZipFile(zip_path,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
 for p in files:
  info=zipfile.ZipInfo(R.name+'/'+str(p.relative_to(R)),date_time=(2026,9,29,0,0,0));info.compress_type=zipfile.ZIP_DEFLATED;info.external_attr=0o100644<<16
  z.writestr(info,p.read_bytes())
with zipfile.ZipFile(zip_path) as z:
 assert z.testzip() is None
 expected={R.name+'/'+str(p.relative_to(R)):p for p in files}
 assert set(z.namelist())==set(expected) and len(z.namelist())==len(expected)
 assert all(z.read(n)==p.read_bytes() for n,p in expected.items())
 assert not any('/validation/' in n or '.DS_Store' in n or '__MACOSX' in n or '/._' in n for n in z.namelist())
 digest=sha(zip_path)
 package={'path':str(zip_path),'sha256':digest,'entries':len(files),'integrity':'passed','entry_names':'passed','byte_for_byte_target_agreement':'passed','included':[{'path':str(p.relative_to(R)),'sha256':sha(p)} for p in files],'excluded':excluded,'release_readiness':'Awaiting 44 authentic captures and live database/green-button validation.'}
(V/'package-verification.json').write_text(json.dumps(package,indent=2))
counts=collections.Counter(x['lesson'].split('/')[0] for x in pending)
report=f'''# SEER HIGHTECH conversion evidence

The authorized static conversion and package are prepared. Live release readiness remains open: **44 authentic captures and all HighTech database/green-button checks are outstanding**. No resources were provisioned and nothing was published or uploaded.

## Scenario and model

SEER HIGHTECH assembles and tests electronic control modules using purchased packaged semiconductors. An electrical leakage-current concern in a power control module leads the team through test observations, semiconductor lot SEMI-91A7, test station ATE-017, affected customer-backed build commitments, and fulfillment options. Wafer fabrication and software-service operations are outside this model.

The existing COMPONENTS, PLANTS and PRODUCTION_ORDERS names remain appropriate. The conversion changes all 192 module descriptions, board material grades, assembly/test routes, categories, test observation text, customer delivery requirements, trace entity names, regional labels, vector prompts and agent identity together. The 15 tables, 18 foreign keys, 3,739 orders, 4,985 order lines, numeric fixtures and cost arithmetic remain intact. Customer JSON uses lotCertificate, electricalTestReport and deliveryWindow. Order-document keys remain aligned with the duality view.

## Passed

- All 136 source file hashes match the before snapshot; no additions, removals or changed bytes.
- Both manifests preserve the 11-lesson order; all 40 tasks and 63 SQL blocks are preserved. The editorial pass removes repeated scenario and recap headings; task headings and order remain intact. Heading changes are recorded in structure-comparison.json.
- All {len(static['checks'])} static checks pass: local links, manifests, balanced fences and copy tags, schema references, fixture/loader equality, table constraints and foreign keys, order totals, plant alignment, reserved exercise IDs, and 96 REVIEW / 96 STABLE labels. Relational calculations were checked in SQLite, not Oracle.
- Loader and lab graph DDL match; duality definitions differ only by the intended lab INSERT permission. Both notebooks parse, with 8 and 43 paragraphs; all five Python paragraphs parse. Cached results are cleared. The blank line after the final primary %sql directive was removed to preserve Graph Studio tokenization.
- The canonical loader SQL and single-entry ZIP are byte-identical. Terraform execution order, dependencies, authentication, templates and defaults are unchanged; only the loader filename references change in adb.tf.
- All 1,024 customer requirements documents parse; generated VARCHAR2 values fit their declared sizes.
- Text, filenames, SQL, notebooks, SVG text and 20 raster OCR checks find no unwanted prior-domain residue. Ordinary electronics manufacturing terms and the generic manufacturing-plant lesson title are retained deliberately.
- Six persona banners are byte-identical to source. The shared Nina banner heading, introduction illustration and illustrated ERD were adapted with built-in ImageGen, preserving recognizable personas, poses and Redwood/static Powtoon style. Both ERDs' displayed fields, keys and five relationships agree with the loader; they show selected columns from the core five tables.
- Local LiveLabs rendering: all 11 lesson pages opened, both launch variants loaded, existing image assets loaded, SQL copy controls matched the 63 blocks, and the Getting Started Task 2 cross-link opened its task. The local quiz scored 7/7 and loaded the HighTech badge. This was not a sandbox test.
- Production ZIP integrity, exact entry names and byte-for-byte agreement with {len(files)} intended target files pass.

## Outstanding captures

{len(pending)} placements need authentic HighTech captures: 38 database/Graph Studio/AutoML results or data-specific screens, plus 6 separate application views. Fifteen generic Oracle UI images/diagrams are retained unchanged. Obsolete screenshots are preserved only in validation/source-captures and are excluded from learner content. No screenshots were fabricated or relabeled. See capture-checklist.md for each filename and instruction.

| Lesson | Pending |
| --- | ---: |
'''+''.join(f'| {k} | {v} |\n' for k,v in sorted(counts.items()))+f'''
## Not run

Oracle loader execution, all lab SQL/PLSQL, actual vector rankings, SQL/PGQ results, Graph Studio and PGX execution, Oracle Spatial calculations, AutoML, SQL model training/scoring, Select AI, agent calls/history and live rerun/cleanup behavior. Terraform CLI validation/plan/apply and the LiveLabs green-button learner workflow were not run. No HighTech database connection was supplied; provisioning requires explicit phase authorization. The source contains no application server to convert or launch for the six application views. Current regional model availability and external destination links were not comprehensively retested.

No unresolved failures remain in the checks executed. Missing runtime evidence and captures are unrun work, not passes.

## Package and locations

Target: `{R}`

Primary archive: `{zip_path}`

SHA-256: `{digest}`

The ZIP includes all current learner files, 27 images/diagrams, both notebooks, both manifests/launchers and the complete supporting stack, including synchronized SQL and loader ZIP. It excludes validation/review material, the archive itself and macOS metadata. No other current target content is excluded. The excluded source captures are explicitly listed in the capture checklist. The archive filename follows the request; it is not a claim of completed live release qualification.

The deliverable copy is at `{O/zip_path.name}`.

## Scope and functional departures

No deployment or executable SQL logic was refactored. Rerun guidance was clarified for the JSON setup tables and vector-column creation. Source-only AutoML scores and live-application claims were removed because they are not HighTech results. Application-example positions remain, describing how the workshop data can support those screens. The optional graph setup now links to the included loader rather than referring learners to a maintainer schema contract. Nina's changed banner has a new asset filename to prevent the preview from reusing cached Manufacturing text.

Maintainer evidence stays in `{V}`. Original reports under source-baseline are historical Manufacturing evidence and are never counted as HighTech validation. Image edit requests and asset paths are recorded in illustration-edits.json.
'''
report += '\n## Editorial sweep\n\nSee editorial-report.md for the full-workshop prose reduction and byte-preservation checks. This pass changes learner prose only, including Markdown paragraphs in the two notebooks.\n'
(V/'conversion-report.md').write_text(report)
shutil.copyfile(zip_path,O/zip_path.name)
shutil.copyfile(V/'conversion-report.md',O/'SEER-HighTech-conversion-report.md')
shutil.copyfile(V/'capture-checklist.md',O/'SEER-HighTech-capture-checklist.md')
(O/(zip_path.name+'.sha256')).write_text(digest+'  '+zip_path.name+'\n')
assert sha(O/zip_path.name)==digest
print(json.dumps({'archive':str(zip_path),'deliverable_copy':str(O/zip_path.name),'sha256':digest,'entries':len(files),'pending_captures':len(pending)},indent=2))
