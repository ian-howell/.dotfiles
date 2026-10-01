import json
import os
from pathlib import Path
import subprocess
import threading
import time
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

ROOT = Path(os.environ['REMINDER_TEST_OUTPUT']).resolve()
PLUGIN = str(Path(__file__).resolve().parents[1]/'plugins/stable-mode-reminders.ts')
captures = []

class Mock(BaseHTTPRequestHandler):
    def log_message(self, *args): pass
    def do_POST(self):
        data = json.loads(self.rfile.read(int(self.headers['Content-Length'])))
        captures.append(data)
        payload = {'id': 'chatcmpl-test', 'object': 'chat.completion.chunk', 'created': 1, 'model': 'fixture',
                   'choices': [{'index': 0, 'delta': {'role': 'assistant', 'content': 'OK'}, 'finish_reason': None}]}
        done = {**payload, 'choices': [{'index': 0, 'delta': {}, 'finish_reason': 'stop'}],
                'usage': {'prompt_tokens': 2000, 'completion_tokens': 1, 'total_tokens': 2001}}
        content=data['messages'][-1]['content']
        text=content if isinstance(content,str) else ''.join(p.get('text','') for p in content)
        if data['messages'][-1]['role']=='user' and text.startswith('TOOL_STEP:'):
            payload['choices'][0]['delta']={'role':'assistant','tool_calls':[{'index':0,'id':'call_fixture','type':'function','function':{'name':'read','arguments':json.dumps({'filePath':str(ROOT/'fixture.txt')})}}]}
            done['choices'][0]['finish_reason']='tool_calls'
        body = ('data: '+json.dumps(payload)+'\n\ndata: '+json.dumps(done)+'\n\ndata: [DONE]\n\n').encode()
        self.send_response(200); self.send_header('Content-Type','text/event-stream')
        self.send_header('Content-Length',str(len(body))); self.end_headers(); self.wfile.write(body)

def api(base, path, data=None, timeout=120):
    req = urllib.request.Request(base+path, data=None if data is None else json.dumps(data).encode(),
                                 headers={'Content-Type':'application/json'})
    with urllib.request.urlopen(req,timeout=timeout) as r: return json.load(r)

def environment(directory, config):
    cfg = directory/'config'; cfg.mkdir(parents=True, exist_ok=True)
    (cfg/'opencode.json').write_text(json.dumps(config))
    env = os.environ.copy()
    for name in ['OPENCODE_CONFIG', 'OPENCODE_CONFIG_CONTENT', 'OPENCODE_SERVER_PASSWORD', 'OPENCODE_SERVER_USERNAME']:
        env.pop(name,None)
    env.update(XDG_CONFIG_HOME=str(directory/'xdg'), OPENCODE_CONFIG_DIR=str(cfg),
               OPENCODE_DISABLE_PROJECT_CONFIG='1', OPENCODE_DISABLE_EXTERNAL_SKILLS='1',
               OPENCODE_DISABLE_CLAUDE_CODE='1', OPENCODE_EXPERIMENTAL_PLAN_MODE='false',
               OPENCODE_NOTIFY='0', NO_COLOR='1')
    return env

def start(directory, config):
    env=environment(directory,config)
    import socket
    with socket.socket() as sock: sock.bind(('127.0.0.1',0)); port=sock.getsockname()[1]
    log=(directory/'server.log').open('a')
    p=subprocess.Popen(['opencode','serve','--hostname','127.0.0.1','--port',str(port)],cwd=directory,env=env,stdout=log,stderr=log)
    base=f'http://127.0.0.1:{port}'
    for _ in range(120):
        try:
            api(base,'/global/health',timeout=2); return p,base,log
        except Exception:
            if p.poll() is not None: raise RuntimeError(f'server exited {p.returncode}')
            time.sleep(.25)
    raise TimeoutError('startup')

def stop(p,log):
    p.terminate()
    try: p.wait(timeout=15)
    except subprocess.TimeoutExpired: p.kill(); p.wait()
    log.close()

def config(fixed, mock_url=None):
    result={'$schema':'https://opencode.ai/config.json','autoupdate':False,'share':'disabled','snapshot':False,
            'plugin':[PLUGIN] if fixed else [],'permission':{'*':'deny','read':'allow','external_directory':'allow'},'compaction':{'auto':False},
            'agent':{'plan':{'prompt':'Answer with OK only.'},'build':{'prompt':'Answer with OK only.'}}}
    if mock_url:
        result.update(model='fixture/fixture',small_model='fixture/fixture',enabled_providers=['fixture'],
            provider={'fixture':{'npm':'@ai-sdk/openai-compatible','name':'fixture','options':{'baseURL':mock_url,'apiKey':'fixture'},
                                 'models':{'fixture':{'name':'fixture','limit':{'context':100000,'output':1000}}}}})
    return result

def prompt(base,sid,agent,text,model=None):
    body={'agent':agent,'parts':[{'type':'text','text':text}]}
    if model: body['model']=model
    r=api(base,f'/session/{sid}/message',body)
    if r.get('info',{}).get('error'): raise RuntimeError(r['info']['error'])
    return r

def main():
    ROOT.mkdir(parents=True,exist_ok=True)
    (ROOT/'fixture.txt').write_text('Inert fixture for the reminder integration test.\n')
    mock=ThreadingHTTPServer(('127.0.0.1',0),Mock)
    threading.Thread(target=mock.serve_forever,daemon=True).start()
    results={}
    for fixed in [False,True]:
        name='fixed' if fixed else 'control'; directory=ROOT/name; directory.mkdir(exist_ok=True)
        cfg=config(fixed,f'http://127.0.0.1:{mock.server_port}/v1')
        p,base,log=start(directory,cfg)
        try:
            sid=api(base,'/session',{'title':f'Reminder regression {name}'})['id']
            records=[]
            for n,agent in enumerate(['plan','plan','build','build']):
                print(name,'turn',n+1,flush=True)
                prompt(base,sid,agent,f'Turn {n+1}: say OK.')
                records.append(captures[-1]['messages'])
            # Restart the actual server and resume the stored session.
            stop(p,log); p,base,log=start(directory,cfg)
            print(name,'restart ready',flush=True)
            # Let the restarted process's wall clock advance beyond the old
            # process's monotonic ID clock before creating another message.
            time.sleep(2)
            prompt(base,sid,'build','After restart: say OK.'); records.append(captures[-1]['messages'])
            fork=api(base,f'/session/{sid}/fork',{})['id']
            prompt(base,fork,'build','After fork: say OK.'); records.append(captures[-1]['messages'])
            messages=api(base,f'/session/{fork}/message')
            stable=[records[i+1][:len(records[i])]==records[i] for i in range(len(records)-1)]
            saved=[len([p for p in m['parts'] if p.get('synthetic') and p['type']=='text' and '<system-reminder>' in p['text']]) for m in messages if m['info']['role']=='user']
            results[name]={'session':sid,'fork':fork,'stable_prefix_transitions':stable,'saved_reminders_per_user':saved}
            (directory/'requests.json').write_text(json.dumps(records,indent=2))
            (directory/'messages.json').write_text(json.dumps(messages,indent=2))
            if fixed: assert all(stable),stable; assert saved==[1]*6,saved
            else: assert not all(stable); assert saved==[0]*6
            if fixed:
                print(name,'tool continuation',flush=True)
                before=len(captures)
                prompt(base,fork,'build','TOOL_STEP: read the fixture then say OK.')
                tool_requests=captures[before:]
                assert len(tool_requests)==2,len(tool_requests)
                assert tool_requests[1]['messages'][:len(tool_requests[0]['messages'])]==tool_requests[0]['messages']
                results[name]['tool_continuation_stable']=True
                print(name,'compaction',flush=True)
                api(base,f'/session/{fork}/summarize',{'providerID':'fixture','modelID':'fixture','auto':False})
                prompt(base,fork,'plan','After compaction: say OK.')
                compacted=captures[-1]['messages']
                prompt(base,fork,'plan','After compaction followup: say OK.')
                assert captures[-1]['messages'][:len(compacted)]==compacted
                results[name]['post_compaction_stable']=True
                print(name,'embedded CLI',flush=True)
                embedded=subprocess.run(['opencode','run','--agent','plan','--model','fixture/fixture',
                    '--format','json','--title','Reminder embedded CLI regression','Say OK.'],
                    cwd=directory,env=environment(directory,cfg),capture_output=True,text=True,timeout=120)
                (directory/'embedded.jsonl').write_text(embedded.stdout)
                (directory/'embedded.stderr').write_text(embedded.stderr)
                assert embedded.returncode==0,embedded.stderr
                events=[json.loads(line) for line in embedded.stdout.splitlines() if line.startswith('{')]
                assert any(e['type']=='text' for e in events),events
                assert not any(e['type']=='error' for e in events),events
                results[name]['embedded_cli_passed']=True
        finally: stop(p,log)
    mock.shutdown()
    (ROOT/'integration-results.json').write_text(json.dumps(results,indent=2))
    print(json.dumps(results,indent=2))

if __name__=='__main__': main()
