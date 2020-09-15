import sys
import json
import numpy 
import joblib


dirPath=sys.argv[1]
outputF = dirPath+'__vibe.json'

vibe = joblib.load(dirPath+'/vibe_output.pkl')

pose3d = numpy.array(vibe[0]['joints3d'])
orig_cam = numpy.array(vibe[0]['orig_cam'])
pred_cam = numpy.array(vibe[0]['pred_cam'])

#joints3d: (#frame, 49, 3)
#orig_cam: (#frame, 4)
#pred_cam: (#frame, 3)

output = {}
output['num_frames'] = pose3d.shape[0] 
output['joints3d'] = []
output['orig_cam'] = []
output['pred_cam'] = []

for idx in range(pose3d.shape[0]):
  output['joints3d'].append(pose3d[idx,:,:].reshape(49*3).tolist())
  output['orig_cam'].append(orig_cam[idx,:].tolist())
  output['pred_cam'].append(pred_cam[idx,:].tolist())

json.dump(output,open(outputF,'w'))