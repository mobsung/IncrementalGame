"""Read-only connected silhouette inventory for diagnosing atlas contamination."""
from pathlib import Path
from PIL import Image
from collections import deque
import numpy as np

def components(alpha, threshold=100):
    height,width = alpha.shape
    mask = alpha >= threshold
    labels = np.zeros(alpha.shape, dtype=np.int32)
    items = []
    flat = mask.ravel(); owned = labels.ravel()
    for start in np.flatnonzero(flat):
        start = int(start)
        if owned[start]: continue
        number = len(items)+1
        queue = deque([start]); owned[start]=number
        points=[]
        while queue:
            i=queue.popleft(); x=i%width; y=i//width; points.append(i)
            for other in (i-1 if x else -1, i+1 if x+1<width else -1,
                          i-width if y else -1, i+width if y+1<height else -1):
                if other>=0 and flat[other] and not owned[other]:
                    owned[other]=number; queue.append(other)
        pts = np.array(points,dtype=np.int32)
        xs=pts%width;ys=pts//width
        items.append({'id':number,'points':pts,'size':len(pts),
                      'box':(int(xs.min()),int(ys.min()),int(xs.max())+1,int(ys.max())+1)})
    return labels, items

if __name__ == '__main__':
    root=Path(__file__).resolve().parents[1]/'content/units/supports/would_be_wizard/visuals/spritesheets'
    for role in ['apprentice','acolyte','archsage','makeshift','archmage']:
        alpha=np.array(Image.open(root/f'{role}.png').getchannel('A'))
        labels, items=components(alpha)
        large=[v for v in items if v['size']>2000]
        print(role,len(large),[(v['size'],v['box']) for v in large])
