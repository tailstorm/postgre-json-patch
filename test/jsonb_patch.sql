SELECT jsonb_patch('{}'::jsonb, null) = '{}'
SELECT jsonb_patch('{}'::jsonb, '[]'::jsonb) = '{}'
SELECT jsonb_patch('{"foo":"bar"}'::jsonb, '[]'::jsonb) = '{"foo":"bar"}'
SELECT jsonb_patch('{"foo":1,"bar":2}'::jsonb, '[]'::jsonb) = '{"bar":2,"foo":1}'
SELECT jsonb_patch('[{"foo":1,"bar":2}]'::jsonb, '[]'::jsonb) = '[{"bar":2,"foo":1}]'
SELECT jsonb_patch('{"foo":{"foo":1,"bar":2}}'::jsonb, '[]'::jsonb) = '{"foo":{"bar":2,"foo":1}}'

SELECT jsonb_patch('{"foo":null}'::jsonb, '[{"op":"add","path":"/foo","value":1}]'::jsonb) = '{"foo":1}'
SELECT jsonb_patch('{"foo":{"bar":1}}'::jsonb, '[{"op":"add","path":"/foo/bar","value":2}]'::jsonb) = '{"foo":{"bar":2}}'
SELECT jsonb_patch('{"foo":{"bar":1}}'::jsonb, '[{"op":"add","path":"/baz/bar","value":2}]'::jsonb) -- 'Pointer references a nonexistent value'
SELECT jsonb_patch('[]'::jsonb, '[{"op":"add","path":"/0","value":"foo"}]'::jsonb) = '["foo"]'
SELECT jsonb_patch('{}'::jsonb, '[{"op":"add","path":"/foo","value":"1"}]'::jsonb) = '{"foo":"1"}'
SELECT jsonb_patch('{}'::jsonb, '[{"op":"add","path":"/foo","value":1}]'::jsonb) = '{"foo":1}'
SELECT jsonb_patch('{}'::jsonb, '[{"op":"add","path":"","value":[]}]'::jsonb) = '[]'
SELECT jsonb_patch('[]'::jsonb, '[{"op":"add","path":"","value":{}}]'::jsonb) = '{}'
SELECT jsonb_patch('{"foo":"bar"}'::jsonb, '[{"op":"add","path":"","value":{"baz":"qux"}}]'::jsonb) = '{"baz":"qux"}'
SELECT jsonb_patch('[]'::jsonb, '[{"op":"add","path":"/-","value":"hi"}]'::jsonb) = '["hi"]'
SELECT jsonb_patch('{}'::jsonb, '[{"op":"add","path":"/","value":1}]'::jsonb) = '{"":1}'
SELECT jsonb_patch('{"foo":{}}'::jsonb, '[{"op":"add","path":"/foo/","value":1}]'::jsonb) = '{"foo":{"":1}}'
SELECT jsonb_patch('{"foo":1}'::jsonb, '[{"op":"add","path":"/bar","value":[1,2]}]'::jsonb) = '{"foo":1,"bar":[1,2]}'
SELECT jsonb_patch('{"foo":1,"baz":[{"qux":"hello"}]}'::jsonb, '[{"op":"add","path":"/baz/0/foo","value":"world"}]'::jsonb) = '{"foo":1,"baz":[{"qux":"hello","foo":"world"}]}'
SELECT jsonb_patch('{"bar":[1,2]}'::jsonb, '[{"op":"add","path":"/bar/8","value":5}]'::jsonb) -- 'Array index out of bounds (upper)'
SELECT jsonb_patch('{"bar":[1,2]}'::jsonb, '[{"op":"add","path":"/bar/-1","value":5}]'::jsonb) -- 'Array index out of bounds (lower)'
SELECT jsonb_patch('{"foo":1}'::jsonb, '[{"op":"add","path":"/bar","value":true}]'::jsonb) = '{"foo":1,"bar":true}'
SELECT jsonb_patch('{"foo":1}'::jsonb, '[{"op":"add","path":"/bar","value":false}]'::jsonb) = '{"foo":1,"bar":false}'
SELECT jsonb_patch('{"foo":1}'::jsonb, '[{"op":"add","path":"/bar","value":null}]'::jsonb) = '{"foo":1,"bar":null}'
SELECT jsonb_patch('{"foo":1}'::jsonb, '[{"op":"add","path":"/0","value":"bar"}]'::jsonb) = '{"foo":1,"0":"bar"}'
SELECT jsonb_patch('["foo"]'::jsonb, '[{"op":"add","path":"/1","value":"bar"}]'::jsonb) = '["foo","bar"]'
SELECT jsonb_patch('["foo","sil"]'::jsonb, '[{"op":"add","path":"/1","value":"bar"}]'::jsonb) = '["foo","bar","sil"]'
SELECT jsonb_patch('["foo","sil"]'::jsonb, '[{"op":"add","path":"/0","value":"bar"}]'::jsonb) = '["bar","foo","sil"]'
SELECT jsonb_patch('["foo","sil"]'::jsonb, '[{"op":"add","path":"/2","value":"bar"}]'::jsonb) = '["foo","sil","bar"]'
SELECT jsonb_patch('["foo","sil"]'::jsonb, '[{"op":"add","path":"/3","value":"bar"}]'::jsonb) -- 'Array index out of bounds (upper)'
SELECT jsonb_patch('["foo","sil"]'::jsonb, '[{"op":"add","path":"/bar","value":"bar"}]'::jsonb) -- 'Array is referenced with a non-numeric token'
SELECT jsonb_patch('["foo","sil"]'::jsonb, '[{"op":"add","path":"/1e0","value":"bar"}]'::jsonb) -- 'Array is referenced with a non-numeric token'
SELECT jsonb_patch('["foo","sil"]'::jsonb, '[{"op":"add","path":"/1","value":["bar","baz"]}]'::jsonb) = '["foo",["bar","baz"],"sil"]'
SELECT jsonb_patch('["foo","sil"]'::jsonb, '[{"op":"add","path":"/-","value":{"foo":["bar","baz"]}}]'::jsonb) = '["foo","sil",{"foo":["bar","baz"]}]'
SELECT jsonb_patch('[1,2,[3,[4,5]]]'::jsonb, '[{"op":"add","path":"/2/1/-","value":{"foo":"bar"}}]'::jsonb) = '[1,2,[3,[4,5,{"foo":"bar"}]]]'
SELECT jsonb_patch('[1]'::jsonb, '[{"op":"add","path":"/-"}]'::jsonb) -- 'Patch "add" operation is missing "value" member'
SELECT jsonb_patch('{}'::jsonb, '[{"op":"spam","path":"/-"}]'::jsonb) -- 'Unsupported operation type'
SELECT jsonb_patch('{"foo":"bar"}'::jsonb, '[{"op":"add","path":"/FOO","value":"BAR"}]'::jsonb) = '{"foo":"bar","FOO":"BAR"}'

SELECT jsonb_patch('{"foo":1,"bar":[1,2,3,4]}'::jsonb, '[{"op":"remove","path":"/bar"}]'::jsonb) = '{"foo":1}'
SELECT jsonb_patch('{"foo":1,"baz":[{"qux":"hello"}]}'::jsonb, '[{"op":"remove","path":"/baz/0/qux"}]'::jsonb) = '{"foo":1,"baz":[{}]}'
SELECT jsonb_patch('{"foo":1,"baz":[{"qux":"hello"}]}'::jsonb, '[{"op":"remove","path":"/baz/1e0/qux"}]'::jsonb) -- 'Array is referenced with a non-numeric token'
SELECT jsonb_patch('{"foo":null}'::jsonb, '[{"op":"remove","path":"/foo"}]'::jsonb) = '{}'
SELECT jsonb_patch('[1,2,3,4]'::jsonb, '[{"op":"remove","path":"/0"}]'::jsonb) = '[2,3,4]'
SELECT jsonb_patch('[1,2,3,4]'::jsonb, '[{"op":"remove","path":"/1"},{"op":"remove","path":"/2"}]'::jsonb) = '[1,3]'
SELECT jsonb_patch('[1,2,3,4]'::jsonb, '[{"op":"remove","path":"/1e0"}]'::jsonb) -- 'Array is referenced with a non-numeric token'
SELECT jsonb_patch('{"foo":"bar"}'::jsonb, '[{"op":"remove","path":"/baz"}]'::jsonb) -- 'Patch "replace" operation "path" member does not reference an existing value'
SELECT jsonb_patch('["foo":"bar"]'::jsonb, '[{"op":"remove","path":"/2"}]'::jsonb) -- 'Array index out of bounds (upper)'

SELECT jsonb_patch('{"foo":1,"baz":[{"qux":"hello"}]}'::jsonb, '[{"op":"replace","path":"/foo","value":[1,2,3,4]}]'::jsonb) = '{"foo":[1,2,3,4],"baz":[{"qux":"hello"}]}'
SELECT jsonb_patch('{"foo":1,"baz":[{"qux":"hello"}]}'::jsonb, '[{"op":"replace","path":"/baz/0/qux","value":"world"}]'::jsonb) = '{"foo":1,"baz":[{"qux":"world"}]}'
SELECT jsonb_patch('["foo"]'::jsonb, '[{"op":"replace","path":"/0","value":"bar"}]'::jsonb) = '["bar"]'
SELECT jsonb_patch('[""]'::jsonb, '[{"op":"replace","path":"/0","value":0}]'::jsonb) = '[0]'
SELECT jsonb_patch('[""]'::jsonb, '[{"op":"replace","path":"/0","value":true}]'::jsonb) = '[true]'
SELECT jsonb_patch('[""]'::jsonb, '[{"op":"replace","path":"/0","value":false}]'::jsonb) = '[false]'
SELECT jsonb_patch('[""]'::jsonb, '[{"op":"replace","path":"/0","value":null}]'::jsonb) = '[null]'
SELECT jsonb_patch('["foo","sil"]'::jsonb, '[{"op":"replace","path":"/1","value":["bar","baz"]}]'::jsonb) = '["foo",["bar","baz"]]'
SELECT jsonb_patch('{"foo":"bar"}'::jsonb, '[{"op":"replace","path":"","value":{"baz":"qux"}}]'::jsonb) = '{"baz":"qux"}'
SELECT jsonb_patch('{"foo":null}'::jsonb, '[{"op":"replace","path":"/foo","value":"truthy"}]'::jsonb) = '{"foo":"truthy"}'
SELECT jsonb_patch('{"foo":"bar"}'::jsonb, '[{"op":"replace","path":"/foo","value":null}]'::jsonb) = '{"foo":null}'
SELECT jsonb_patch('[1]'::jsonb, '[{"op":"replace","path":"/1e0","value":0]'::jsonb) -- 'Array is referenced with a non-numeric token'
SELECT jsonb_patch('[1]'::jsonb, '[{"op":"replace","path":"/0"]'::jsonb) -- 'Patch "replace" operation is missing "value" member'

SELECT jsonb_patch('{"foo":null}'::jsonb, '[{"op":"move","from":"/foo","path":"/bar"}]'::jsonb) = '{"bar":null}'
SELECT jsonb_patch('{"foo":1}'::jsonb, '[{"op":"move","from":"/foo","path":"/foo"}]'::jsonb) = '{"foo":1}'
SELECT jsonb_patch('{"foo":1,"baz":[{"qux":"hello"}]}'::jsonb, '[{"op":"move","from":"/foo","path":"/bar"}]'::jsonb) = '{"baz":[{"qux":"hello"}],"bar":1}'
SELECT jsonb_patch('{"foo":1,"baz":[{"qux":"hello"}]}'::jsonb, '[{"op":"move","from":"/baz/0/qux","path":"/baz/1"}]'::jsonb) = '{"foo":1,"baz":[{},"hello"]}'
SELECT jsonb_patch('{"foo":1,"baz":[1,2,3,4]}'::jsonb, '[{"op":"move","from":"/baz/1e0","path":"/foo"}]'::jsonb) -- 'Array is referenced with a non-numeric token'
SELECT jsonb_patch('{"foo":1,"baz":[1,2,3,4]}'::jsonb, '[{"op":"move","path":"/foo"}]'::jsonb) -- 'Patch "move" operation is missing "from" member'

SELECT jsonb_patch('{"foo":null}'::jsonb, '[{"op":"copy","from":"/foo","path":"/bar"}]'::jsonb) = '{"foo":null,"bar":null}'
SELECT jsonb_patch('{"foo":1,"baz":[{"qux":2}]}'::jsonb, '[{"op":"copy","from":"/baz/0","path":"/boo"}]'::jsonb) = '{"foo":1,"baz":[{"qux":2}],"boo":{"qux":2}}'
SELECT jsonb_patch('{"foo":1,"baz":[1,2,3,4]}'::jsonb, '[{"op":"copy","from":"/baz/1e0","path":"/boo"}]'::jsonb) -- 'Array is referenced with a non-numeric token'
SELECT jsonb_patch('[1]'::jsonb, '[{"op":"copy","from":"/0","path":"/-"}]'::jsonb) = '[1,1]'
SELECT jsonb_patch('[1]'::jsonb, '[{"op":"copy","path":"/-"}]'::jsonb) -- 'Patch "copy" operation is missing "from" member'

SELECT jsonb_patch('{"1e0":"foo"}'::jsonb, '[{"op":"test","path":"/1e0","value":"foo"}]'::jsonb) = '{"1e0":"foo"}'
SELECT jsonb_patch('["foo","bar"]'::jsonb, '[{"op":"test","path":"/1e0","value":"bar"}]'::jsonb) -- 'Array is referenced with a non-numeric token'
SELECT jsonb_patch('{"foo":1}'::jsonb, '[{"op":"test","path":"/foo","value":1}]'::jsonb) = '{"foo":1}'
SELECT jsonb_patch('{"foo":null}'::jsonb, '[{"op":"test","path":"/foo","value":null}]'::jsonb) = '{"foo":null}'
SELECT jsonb_patch('{"foo":{"foo":1,"bar":2}}'::jsonb, '[{"op":"test","path":"/foo","value":{"bar":2,"foo":1}}]'::jsonb) = '{"foo":{"foo":1,"bar":2}}'
SELECT jsonb_patch('{"foo":[{"foo":1,"bar":2}]}'::jsonb, '[{"op":"test","path":"/foo","value":[{"bar":2,"foo":1}]}]'::jsonb) = '{"foo":[{"foo":1,"bar":2}]}'
SELECT jsonb_patch('{"foo":{"bar":[1,2,3,4]}}'::jsonb, '[{"op":"test","path":"/foo","value":{"bar":[1,2,3,4]}}]'::jsonb) = '{"foo":{"bar":[1,2,3,4]}}'
SELECT jsonb_patch('{"foo":{"bar":[1,2,3,4]}}'::jsonb, '[{"op":"test","path":"/foo/bar","value":[1,2,3,4]}]'::jsonb) = '{"foo":{"bar":[1,2,3,4]}}'
SELECT jsonb_patch('{"foo":{"bar":[1,2,3,4]}}'::jsonb, '[{"op":"test","path":"/foo/bar","value":[4,3,2,1]}]'::jsonb) -- 'Patch "test" operation "value" member is not equal to referencing value'
SELECT jsonb_patch('{"foo":1}'::jsonb, '[{"op":"test","path":"","value":{"foo":1}}]'::jsonb) = '{"foo":1}'
SELECT jsonb_patch('{"":1}'::jsonb, '[{"op":"test","path":"/","value":1}]'::jsonb) = '{"":1}'
SELECT jsonb_patch('[1]'::jsonb, '[{"op":"test","path":"/00","value":1}]'::jsonb) -- 'Array is referenced with a non-numeric token'
SELECT jsonb_patch('[1]'::jsonb, '[{"op":"test","path":"/0"}]'::jsonb) -- 'Patch "test" operation is missing "value" member'