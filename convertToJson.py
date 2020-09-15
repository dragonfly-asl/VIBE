import sys
import json
import numpy 
import joblib


dirPath=sys.argv[1]
outputF = dirPath+'__vibe.json'

vibe = joblib.load(dirPath+'/vibe_output.pkl')

pose3d = numpy.array(vibe[0]['joints3d'])

output = {}
output['num_frames'] = pose3d.shape[0] 
output['frames'] = []

for idx in range(pose3d.shape[0]):
  output['frames'].append(pose3d[idx,:,:].reshape(49*3).tolist())

json.dump(output,open(outputF,'w'))
