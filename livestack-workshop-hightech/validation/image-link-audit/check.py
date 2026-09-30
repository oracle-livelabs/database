from pathlib import Path
from urllib.parse import urlsplit,unquote,parse_qs,quote
from urllib.request import urlopen
from html.parser import HTMLParser
from concurrent.futures import ThreadPoolExecutor
import json,re,hashlib
R=Path('/Users/mkowalik/Documents/GitHub/oracle-livelabs/database/livestack-workshop-hightech');W=Path(__file__).parent
pkg=json.loads((R/'validation/package-verification.json').read_text())
refs=[]
class Links(HTMLParser):
 def handle_starttag(self,tag,attrs):
  a=dict(attrs)
  for k in ('src','href'):
   if k in a:refs.append({'source':self.source,'url':a[k],'kind':tag})
for e in pkg['included']:
 p=R/e['path'];ext=p.suffix
 if ext=='.md':texts=[p.read_text()]
 elif ext=='.dsnb':texts=['\n'.join(x['message'][1:]) for n in json.loads(p.read_text()) for x in n['paragraphs'] if x['message'][0].strip()=='%md']
 else:texts=[]
 for s in texts:
  for image,url in re.findall(r'(!?)\[[^\]]*\]\(([^)]+)\)',s):refs.append({'source':e['path'],'url':url.split(' "')[0].strip(),'kind':'image' if image else 'link'})
  for url in re.findall(r'^badge:\s*(\S+)',s,re.M):refs.append({'source':e['path'],'url':url,'kind':'badge'})
 if ext in ('.html','.svg'):
  h=Links();h.source=e['path'];h.feed(p.read_text())
 if p.name=='manifest.json':
  for t in json.loads(p.read_text())['tutorials']:refs.append({'source':e['path'],'url':t['filename'],'kind':'manifest'})
local=[];external=[];anchors=[];errors=[]
for ref in refs:
 u=urlsplit(ref['url'])
 if u.scheme in ('https','http','mailto','javascript'):external.append(ref);continue
 if u.query.startswith('lab='):
  lab=parse_qs(u.query)['lab'][0];p=R/lab/(lab+'.md')
  ok=p.is_file()
  if u.fragment:
   # LiveLabs navigation strips whitespace and punctuation except colons/parentheses/question marks.
   titles=re.findall(r'^## (.+)',p.read_text(),re.M) if ok else []
   norm=lambda x:re.sub(r'[^a-z0-9]','',unquote(x).lower())
   ok=ok and any(norm(t)==norm(u.fragment) for t in titles)
  anchors.append(dict(ref,exists=ok));continue
 if not u.path:continue
 p=(R/ref['source']).parent/unquote(u.path);p=p.resolve()
 ok=p.is_file() and p.is_relative_to(R)
 row=dict(ref,target=str(p.relative_to(R)) if ok else str(p),exists=ok)
 local.append(row)
 if not ok:errors.append(row)
def fetch(path):
 try:
  with urlopen('http://127.0.0.1:8765/'+quote(path),timeout=15) as res: data=res.read();status=res.status
  return {'path':path,'status':status,'bytes_match_disk':data==(R/path).read_bytes()}
 except Exception as e:return {'path':path,'error':str(e)}
paths=sorted({x['target'] for x in local if x['exists']})
with ThreadPoolExecutor(max_workers=8) as pool:http=list(pool.map(fetch,paths))
assert not errors and all(x['exists'] for x in anchors)
assert all(x.get('status')==200 and x.get('bytes_match_disk') for x in http),http
result={'passed':True,'local_references':local,'internal_lesson_links':anchors,'local_http':http,'external_references':external}
(W/'static.json').write_text(json.dumps(result,indent=2))
print(json.dumps({'local_references':len(local),'unique_local_targets':len(paths),'internal_links':len(anchors),'external_urls':len(set(x['url'] for x in external)),'errors':errors},indent=2))
