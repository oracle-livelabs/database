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
coverage=json.loads((V/'screenshot-coverage.json').read_text());pending=[x for x in coverage if x['status'].startswith('awaiting')];app_captures=[x for x in coverage if x['status']=='authentic_hightech_application_capture']
cap=['# HighTech capture record','','Forty-eight database, Graph Studio and AutoML placements and six related LiveStack application views use authentic page-only shared-browser screenshots. The application captures were resized to 1280 pixels; none include browser tabs or an address bar. Obsolete source captures remain in validation/source-captures and are excluded from the learner archive.','','| Lesson | Scene | Application capture |','| --- | --- | --- |']
for x in app_captures:cap.append('| '+x['lesson'].split('/')[0]+' | '+x['alt']+' | `'+x['image']+'` |')
cap+=['','## Remaining validation','','- Fresh SQLcl invocation and supplied stack API-key bootstrap.','- Terraform CLI validation, plan/apply and LiveLabs green-button reservation/login workflow.','- One revised agent run matched the deterministic comparison; repeat-run reliability and narration table formatting remain unqualified.','', 'See live-validation-report.md for the manual database, Graph Studio, PGX and AutoML results.','']
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
 package={'path':str(zip_path),'sha256':digest,'entries':len(files),'integrity':'passed','entry_names':'passed','byte_for_byte_target_agreement':'passed','included':[{'path':str(p.relative_to(R)),'sha256':sha(p)} for p in files],'excluded':excluded,'release_readiness':'Manual database/Graph Studio/AutoML validation, 48 worksheet and six related application captures complete; one revised agent accuracy retest passed. Repeated-run reliability and fresh bootstrap/green-button validation remain unqualified.'}
(V/'package-verification.json').write_text(json.dumps(package,indent=2))
counts=collections.Counter(x['lesson'].split('/')[0] for x in pending)
report=f'''# SEER HIGHTECH conversion and validation

The Seer HighTech workshop has been converted, shortened, tested against the supplied Autonomous AI Database and updated with 48 authentic worksheet captures and six related application captures. The learner archive has been rebuilt. The focused instruction changes produced one correct agent retest and a narration with all requested totals; narration format compliance and repeated-run reliability remain unqualified. The deterministic SQL comparison remains in the lesson. The six application captures are complete; fresh provisioning validation remains outstanding.

## Scenario and preserved structure

Seer HighTech assembles and tests electronic control modules using purchased packaged semiconductors. An electrical leakage-current concern leads the team through test observations, semiconductor lot SEMI-91A7, test station ATE-017, affected build commitments and fulfillment options. This is electronics assembly and testing, not wafer fabrication.

All 136 immutable Manufacturing source files still match the initial hashes. Both manifests retain eleven lessons and forty tasks. There are 63 SQL blocks: one deterministic agent-answer verification query was added and the optional reset appendix was removed. Both notebooks retain eight and 43 paragraphs. The data model retains fifteen tables, eighteen foreign keys and unchanged numeric fixtures. Terraform deployment logic and authentication are preserved; the loader filename references reflect HighTech.

The second editorial pass reduced learner prose from 8,873 to 6,817 words (23.2%). It shortened definitions, repeated setup and result summaries while preserving every task, objective, code block and screenshot. The earlier pass reduced 11,863 to 8,819 words before runtime additions. See SEER-HighTech-editorial-sweep.md for that comparison.

The subsequent jargon/antislop follow-up applied only approved findings 4–7: corrected the OML objective and two task headings, split the training-label explanation, clarified notebook prose, and made Select AI checks and Agent model restoration easier to follow. All executable code and images remain unchanged. See anti-slop/follow-up-001-2026-09-29.md for the approved scope and checks; interface findings 1–3 remain open.

A later learner-facing correction rewrote all five Lab 7 prompts as business questions, removing SQL expressions and schema identifiers from the prompt text. Tasks 3/4 share the same question; Task 5 adds category and planned units; Task 6 retains the table and exact-totals requirements in plain language. Technical correctness checks remain in the review steps. These new prompts have not been rerun against Oracle: the existing test database returned HTTP 571 (Database Connection Error). Existing screenshots are labeled as example outputs. See SEER-HighTech-Select-AI-natural-language-update.md for checks and the live-retest boundary.

## Validation

The learner instructions assume a new database provisioned by the LiveLabs green button. Repeat-run advice in Labs 2, 3, and 8 and the Agent reset appendix have been removed. The supporting README follows the same lifecycle, and the loader's missing-role diagnostic no longer instructs a rerun. Model restoration and checks within the same exercise remain. See SEER-HighTech-fresh-sandbox-update.md for the sweep and verification.

- All {len(static['checks'])} static checks and the source/structure/domain audit pass. Fixture constraints and relational arithmetic were first checked in SQLite, then exercised in Oracle during the manual live run.
- Canonical SQL and the single-entry loader ZIP agree byte-for-byte. All 1,024 customer requirement documents parse and generated strings fit declared column sizes.
- Manual loader assertions passed before lesson mutations. Dashboard, JSON duality, vector search, SQL property graph, Spatial and SQL OML exercises completed; guarded JSON/vector reruns behaved as intended.
- Primary Graph Studio notebook completed and displayed the table and graph results. All 43 optional PGX paragraphs exported with SUCCESS, including 24 executable paragraphs. Graph Studio switched four scalar outputs to Graph despite their saved Table defaults; concise Table-selection guidance was added and code was preserved.
- AutoML completed five candidate models. The synthetic fixture's high scores do not establish predictive quality on future data.
- Initial Select AI narration omitted totals and the initial agent answer was incorrect. After focused instruction changes, one agent run matched all five verified rows and narration included all ten numeric totals. Narration returned a list instead of a table. Successful execution remains separate from answer correctness; repeated-run reliability is not claimed.
- {len([x for x in coverage if x['status']=='authentic_hightech_capture'])} database/Graph Studio/AutoML placements and {len(app_captures)} related application views use authentic shared-browser page-only captures. Application captions use the approved scene-name format. Persona artwork was preserved or narrowly adapted; no screenshots were fabricated.
- Raster OCR was rerun after captures. Text, SQL, notebooks, metadata and diagram residue checks pass.
- Local LiveLabs renderer and quiz checks are documented separately in browser-results.json and browser-live-update.json. These are local preview checks, not a green-button provisioning test.
- ZIP integrity, exact entries and byte-for-byte agreement with {len(files)} intended learner files pass.

See SEER-HighTech-screenshot-update.md for the latest captures and focused instruction retest, and SEER-HighTech-live-validation-report.md for the earlier runtime observations and execution boundaries.

## Image and link sweep

The prior browser sweep checked all eleven lesson pages and 63 image placements, including 23 lazy images. The six newly added application captures are checked separately in this update. The earned quiz badge, linked schema SVG, and all six images in Oracle’s shared help page also load. The quiz reached 7/7 with its badge visible.

The prior sweep found all existing local references resolving. The six new application images were verified in the current package and local preview. Eight authored lesson links, generated navigation anchors, both workshop launchers, the notebook and loader downloads, and external documentation/footer destinations were checked. The stale Ad Choices footer redirected to a contracts page; both launchers now link to [Oracle’s current cookie and advertising-choice guidance](https://www.oracle.com/legal/privacy/privacy-policy/#11).

One upstream content issue remains: Oracle’s shared help page links database password restrictions to [Responsys password guidance](https://docs.oracle.com/en/cloud/saas/marketing/responsys-user/Account_PasswordRestrictions.htm). That destination loads, but is the wrong product; the externally hosted page was not modified. No missing local images or broken local links remain. Evidence is in `validation/image-link-audit/`. This sweep did not rerun Oracle exercises or send support email.

## Remaining work and limits

All six application capture placements now show the linked live HighTech demo. Fresh SQLcl invocation, supplied stack API-key bootstrap, Terraform validation/plan/apply and LiveLabs green-button reservation/login remain unrun. No learner package was published; notebook imports were limited to the authorized test database. AI model output remains variable. The initial agent failure is retained as historical evidence; one revised run passed the SQL comparison, without establishing repeated-run reliability. Narration table formatting and the optional PGX repeat-session property mismatch remain open.

## Package

SHA-256: `{digest}`

Archive: `{O/zip_path.name}`

The archive contains all {len(files)} current learner files, both notebooks, launchers/manifests and complete supporting stack. It excludes maintainer validation/history, obsolete source captures, the archive itself and macOS metadata. Current evidence remains in `{V}`. Historical Manufacturing evidence under source-baseline never establishes a HighTech pass. The production filename follows the request and does not imply completed provisioning qualification.
'''
(V/'conversion-report.md').write_text(report)
shutil.copyfile(zip_path,O/zip_path.name)
shutil.copyfile(V/'conversion-report.md',O/'SEER-HighTech-conversion-report.md')
shutil.copyfile(V/'capture-checklist.md',O/'SEER-HighTech-capture-checklist.md')
shutil.copyfile(V/'live-validation-report.md',O/'SEER-HighTech-live-validation-report.md')
(O/(zip_path.name+'.sha256')).write_text(digest+'  '+zip_path.name+'\n')
assert sha(O/zip_path.name)==digest
print(json.dumps({'archive':str(zip_path),'deliverable_copy':str(O/zip_path.name),'sha256':digest,'entries':len(files),'pending_captures':len(pending)},indent=2))
