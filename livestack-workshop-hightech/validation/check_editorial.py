from pathlib import Path
import re,json,hashlib,copy,shutil
R=Path('/Users/mkowalik/Documents/GitHub/oracle-livelabs/database/livestack-workshop-hightech');V=R/'validation';B=V/'editorial-before';O=Path('/Users/mkowalik/Documents/Codex/2026-09-29/files-pasted-by-the-user-convert/outputs')
fence=r'(?m)^ *```[^\n]*\n[\s\S]*?^ *```[^\n]*$'
def prose(s):
 s=re.sub(fence,'',s);s=re.sub(r'!\[[^\]]*\]\([^\n]*?\)','',s);s=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',s);s=re.sub(r'<[^>]+>','',s)
 return len(re.findall(r"\b[\w’]+\b",s))
checks=[];rows=[]
for p in sorted(B.rglob('*.md')):
 rel=p.relative_to(B);a=p.read_text();b=(R/rel).read_text()
 checks.append({'file':str(rel),'code_identical':re.findall(fence,a)==re.findall(fence,b),'task_headings_identical':re.findall(r'^## Task .+',a,re.M)==re.findall(r'^## Task .+',b,re.M),'images_identical':re.findall(r'!\[[^\]]*\]\([^\n]*?\)',a)==re.findall(r'!\[[^\]]*\]\([^\n]*?\)',b),'objectives_identical':re.findall(r'### Objectives\n.*?(?=\n(?:#{1,3} |Estimated Time))',a,re.S)==re.findall(r'### Objectives\n.*?(?=\n(?:#{1,3} |Estimated Time))',b,re.S)})
 if len(rel.parts)==2 and rel.parts[0]!='stack':rows.append({'lesson':rel.parts[0],'before':prose(a),'after':prose(b),'changed':a!=b})
notebooks=[]
for p in B.rglob('*.dsnb'):
 rel=p.relative_to(B);a=json.loads(p.read_text());b=json.loads((R/rel).read_text());aa=copy.deepcopy(a);bb=copy.deepcopy(b);words=[0,0]
 for idx,data in enumerate([aa,bb]):
  for n in data:
   for par in n['paragraphs']:
    if par['message'][0].strip()=='%md':
     words[idx]+=prose('\n'.join(par['message'][1:]));par['message']=['%md','EDITORIAL PROSE OMITTED FOR COMPARISON']
 notebooks.append({'file':str(rel),'all_non_markdown_content_identical':aa==bb,'before':words[0],'after':words[1]})
manifest=json.loads((V/'editorial-package-before.json').read_text());nonprose=[]
for entry in manifest['included']:
 p=R/entry['path']
 if p.suffix in ['.md','.dsnb']:continue
 nonprose.append({'file':entry['path'],'identical':hashlib.sha256(p.read_bytes()).hexdigest()==entry['sha256']})
assert all(all(v for k,v in row.items() if k!='file') for row in checks)
assert all(x['all_non_markdown_content_identical'] for x in notebooks)
assert all(x['identical'] for x in nonprose)
before=sum(x['before'] for x in rows);after=sum(x['after'] for x in rows)
result={'passed':True,'method':'Word tokens from lesson Markdown after removing fenced code, image markup, HTML tags, and link destinations; includes headings and instructions. Quiz code is excluded but verified byte-identical.','lesson_words_before':before,'lesson_words_after':after,'reduction_percent':round((before-after)/before*100,1),'lessons':rows,'preservation':checks,'notebooks':notebooks,'other_shipped_files':nonprose}
(V/'editorial-results.json').write_text(json.dumps(result,indent=2))
report=f'''# HighTech workshop editorial sweep

Reviewed all 11 lessons, both notebooks, and the learner/supporting README files. Tightened 10 lessons and both notebooks; the quiz and already concise READMEs needed no changes.

Lesson prose decreased from **{before:,} to {after:,} words ({result['reduction_percent']}%)**. Counts exclude fenced code, image markup, HTML tags, and link destinations; headings and instructions are included. This measures text reduction, not a measured reduction in workshop completion time.

## What changed

- Removed repeated Hands-on Scenario summaries after persona-led introductions and objectives.
- Removed five recap-only conclusions; retained the JSON decision table and agent access guidance.
- Shortened repeated explanations of the same data appearing as JSON and relational rows, graph hops versus joins, and geometry versus map output.
- Kept the story in each persona’s question, task transitions, and decisions based on results.
- Made result review more direct: compare specific values, inspect a shared record, or check the customer contact before acting.
- Shortened the introduction’s team table and repeated notebook setup prose.

## Per-lesson prose counts

| Lesson | Before | After | Reduction |
| --- | ---: | ---: | ---: |
'''
for x in rows:report+=f"| {x['lesson']} | {x['before']:,} | {x['after']:,} | {(x['before']-x['after'])/x['before']*100:.1f}% |\n"
report+='''
## Preserved and checked

All 40 task headings and their sequence, 63 SQL blocks, every other fenced block (including the quiz), learning objectives, and image references are unchanged. Both notebooks retain every code paragraph, interpreter, visualization configuration, and other non-Markdown field. All other shipped files match the previous package hashes, including images, manifests, loader SQL/ZIP, Terraform, and templates. The Manufacturing source remains unchanged.

The result-interpretation boundaries, setup prerequisites, rerun instructions, model-restoration steps, and warnings about synthetic ML data remain beside the relevant work. The JSON comparison is retained because it helps learners choose an approach rather than merely recapping the lab.

Static validation passes. Local browser checks cover the edited introduction, JSON, graph, and spatial pages with expanded tasks; these are rendering checks, not Oracle execution. Live database validation and the 44 outstanding authentic captures remain outside this editorial pass.

The updated production ZIP is rebuilt from the revised learner files. Maintainer snapshots, reports, and validation scripts are excluded from it.
'''
(V/'editorial-report.md').write_text(report);shutil.copy2(V/'editorial-report.md',O/'SEER-HighTech-editorial-sweep.md')
print(json.dumps({k:v for k,v in result.items() if k in ['passed','lesson_words_before','lesson_words_after','reduction_percent']},indent=2))
