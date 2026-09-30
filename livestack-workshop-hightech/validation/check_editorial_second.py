from pathlib import Path
import json,re,hashlib
R=Path('/Users/mkowalik/Documents/GitHub/oracle-livelabs/database/livestack-workshop-hightech');V=R/'validation';B=V/'editorial-second-before'
fence=r'(?m)^ *```[^\n]*\n[\s\S]*?^ *```[^\n]*$'
def prose(s):
 s=re.sub(fence,'',s);s=re.sub(r'!\[[^\]]*\]\([^\n]*?\)','',s);s=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',s);s=re.sub(r'<[^>]+>','',s)
 return len(re.findall(r"\b[\w’]+\b",s))
def objectives(s):
 m=re.search(r'### Objectives\n(.*?)(?=\n(?:#{1,3} |Estimated Time))',s,re.S)
 return re.findall(r'^- .+',m[1],re.M) if m else []
rows=[];checks=[];unchanged=[];code=tasks=imgs=0
for p in sorted(B.rglob('*')):
 if not p.is_file():continue
 rel=p.relative_to(B);a=p.read_bytes();b=(R/rel).read_bytes()
 if len(rel.parts)==2 and p.suffix=='.md' and rel.parts[0]!='stack':
  aa=a.decode();bb=b.decode();changed=a!=b
  rows.append({'lesson':rel.parts[0],'before':prose(aa),'after':prose(bb),'changed':changed})
  checks.append({'file':str(rel),'code_identical':re.findall(fence,aa)==re.findall(fence,bb),'headings_identical':re.findall(r'^#{1,6} .+',aa,re.M)==re.findall(r'^#{1,6} .+',bb,re.M),'objectives_identical':objectives(aa)==objectives(bb),'images_identical':re.findall(r'!\[[^\]]*\]\([^\n]*?\)',aa)==re.findall(r'!\[[^\]]*\]\([^\n]*?\)',bb)})
  tasks+=len(re.findall(r'^## Task ',bb,re.M));code+=len(re.findall(r'^ *```sql',bb,re.M));imgs+=len(re.findall(r'!\[[^\]]*\]\([^\n]*?\)',bb))
 else:
  unchanged.append({'file':str(rel),'identical':a==b})
assert all(all(v for k,v in x.items() if k!='file') for x in checks),checks
assert all(x['identical'] for x in unchanged),[x for x in unchanged if not x['identical']]
before=sum(x['before'] for x in rows);after=sum(x['after'] for x in rows)
data={'passed':True,'lesson_words_before':before,'lesson_words_after':after,'reduction_percent':round((before-after)/before*100,1),'task_count':tasks,'sql_blocks':code,'image_references':imgs,'lessons':rows,'preservation':checks,'all_other_files_identical':unchanged,'method':'Words excluding fenced code, image markup, HTML tags, and link destinations; includes headings and instructions.'}
(V/'editorial-second-results.json').write_text(json.dumps(data,indent=2))
print(json.dumps({k:v for k,v in data.items() if k not in ['preservation','all_other_files_identical']},indent=2))
