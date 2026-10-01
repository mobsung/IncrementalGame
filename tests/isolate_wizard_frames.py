"""Read original pixels and author UV patches; never rewrite or generate raster artwork."""
from pathlib import Path
import re
import numpy as np
from PIL import Image
from audit_wizard_components import components

ROOT=Path(__file__).resolve().parents[1]/'content/units/supports/would_be_wizard/visuals'
CUTS={'apprentice':[0,198,369,537,739,1024], 'acolyte':[0,200,389,558,742,911,1024],
 'archsage':[0,188,356,521,698,886,1024], 'makeshift':[0,214,400,582,751,913,1024],
 'archmage':[0,187,359,528,732,880,1024]}
# Authored detached props exceed their nominal cells. Keep the complete prop with its pose.
PROPS={
 'archmage':[(20,(700,555,820,640)),(22,(1140,515,1320,635)),(23,(1370,515,1536,630))],
 'makeshift':[(21,(955,583,1120,655)),(26,(698,741,870,817))],
 'archsage':[(13,(410,355,515,450)),(14,(650,355,775,455)),(15,(893,355,1020,455)),
             (16,(1130,355,1290,455)),(27,(952,733,1044,846))],
 'acolyte':[(13,(394,385,520,500)),(14,(648,385,815,505)),(16,(1115,385,1340,475))],
}
GUTTERS={
 'acolyte':[(15,(768,385,825,445))],
 'archsage':[(15,(745,355,805,440)),(16,(1000,355,1070,440)),(28,(1000,735,1090,805))],
 'archmage':[(21,(780,535,825,650))],
}

def patch_rectangles(owner, frame):
    active={}; rectangles=[]
    for y,row in enumerate(owner==frame):
        padded=np.concatenate(([False],row,[False])).astype(np.int8)
        edges=np.flatnonzero(np.diff(padded))
        spans=list(zip(edges[::2],edges[1::2]))
        current={}
        for left,right in spans:
            key=(int(left),int(right))
            if key in active:
                rect=active.pop(key);rect[3]+=1
            else:rect=[key[0],y,key[1]-key[0],1]
            current[key]=rect
        rectangles.extend(active.values());active=current
    rectangles.extend(active.values())
    return rectangles

for role,ys in CUTS.items():
    alpha=np.array(Image.open(ROOT/'spritesheets'/f'{role}.png').getchannel('A'))
    height,width=alpha.shape
    labels,core=components(alpha,100)
    cells=[];main=[];bounds=[]
    for row in range(len(ys)-1):
        for col in range(6):
            x=col*width//6;right=(col+1)*width//6
            counts=np.bincount(labels[ys[row]:ys[row+1],x:right].ravel())
            counts[0]=0; selected=int(counts.argmax())
            main.append(selected); cells.append((x,ys[row],right,ys[row+1]))
            bounds.append(core[selected-1]['box'])
    owner=np.zeros(alpha.shape,dtype=np.int16)
    core_owners={}
    for index,component in enumerate(main):
        # Makeshift cell 27 has no character in the source sheet; hit reuses pose 28.
        if role=='makeshift' and index==27:continue
        core_owners.setdefault(component,[]).append(index)
    centers=np.array([((b[0]+b[2])/2,(ys[i//6]+ys[i//6+1])/2) for i,b in enumerate(bounds)])
    def prop_owner(box):
        cx=(box[0]+box[2])/2;cy=(box[1]+box[3])/2
        for frame,(x,y,r,b) in PROPS.get(role,[]):
            if x<=cx<r and y<=cy<b:return frame+1
        return None
    def choose(points,candidates):
        px=points%width;py=points//width
        scores=[]
        for i in candidates:
            b=bounds[i]
            dx=np.maximum(np.maximum(b[0]-px,px-b[2]),0)
            dy=np.maximum(np.maximum(b[1]-py,py-b[3]),0)
            scores.append((dx*dx+dy*dy)*100+((px-centers[i,0])**2+(py-centers[i,1])**2)*.01)
        return np.array(candidates)[np.argmin(scores,axis=0)]+1
    for item in core:
        candidates=core_owners.get(item['id'])
        if candidates is None:
            # Detached particles/tools belong to the nearest full-body silhouette.
            cx=(item['box'][0]+item['box'][2])/2;cy=(item['box'][1]+item['box'][3])/2
            candidates=list(range(len(main)))
            assignment=prop_owner(item['box']) or choose(np.array([int(cy)*width+int(cx)]),candidates)[0]
            candidates=[int(assignment)-1]
        if len(candidates)==1:
            owner.ravel()[item['points']]=candidates[0]+1
        else:
            # Two death poses joined by a thin source effect: partition at authored gutter.
            pts=item['points']; px=pts%width;py=pts//width
            distances=[]
            for i in candidates:
                x,y,r,b=cells[i]
                distances.append(np.maximum(np.maximum(x-px,px-(r-1)),0)**2+
                                 np.maximum(np.maximum(y-py,py-(b-1)),0)**2)
            owner.ravel()[pts]=np.array(candidates)[np.argmin(distances,axis=0)]+1
    # Preserve soft alpha edges and glow without letting another pose's core leak in.
    _,soft=components(alpha,1)
    for item in soft:
        pts=item['points']
        primary=np.isin(labels.ravel()[pts],list(core_owners))
        ids=np.unique(owner.ravel()[pts[primary]]);ids=ids[ids>0]
        if len(ids)==1:
            owner.ravel()[pts]=int(ids[0])
            continue
        pending=pts[~primary]
        if not len(pending):continue
        if not len(ids):
            preferred=prop_owner(item['box'])
            ids=np.array([preferred]) if preferred else np.unique(choose(pts,list(range(len(main)))))
        elif len(ids)>1:
            # Detached core fragments already have explicit prop ownership.
            # Preserve them; only apportion the translucent border of joined glows.
            pending=pending[labels.ravel()[pending]==0]
        owner.ravel()[pending]=int(ids[0]) if len(ids)==1 else choose(pending,[int(i)-1 for i in ids])
    # Audited gutter slivers of adjacent spell trails; never remove this pose's solid body.
    for frame,(x,y,r,b) in GUTTERS.get(role,[]):
        selection=(owner[y:b,x:r]==frame+1)&(labels[y:b,x:r]!=main[frame])
        owner[y:b,x:r][selection]=0
    # Joined glows can leave tiny disconnected tails after ownership is split.
    # Exclude these UV islands, keeping solid detached pages, tools and props.
    omitted=0
    for frame in range(1,len(main)+1):
        pts=np.flatnonzero(owner.ravel()==frame)
        if not len(pts):continue
        xs=pts%width;yy=pts//width
        x,y,r,b=int(xs.min()),int(yy.min()),int(xs.max())+1,int(yy.max())+1
        local=np.where(owner[y:b,x:r]==frame,alpha[y:b,x:r],0)
        _,islands=components(local,1)
        for island in islands:
            ip=island['points'];opaque=np.count_nonzero(local.ravel()[ip]>=100)
            if opaque>=32 and island['size']>=48:continue
            sy=ip//(r-x)+y;sx=ip%(r-x)+x
            owner[sy,sx]=0;omitted+=len(ip)
    refs='';subs='';regions=[];pivots=[];heights=[];total=0
    for index in range(len(main)):
        source_index=28 if role=='makeshift' and index==27 else index
        points=np.flatnonzero(owner.ravel()==source_index+1);px=points%width;py=points//width
        left,top,right,bottom=int(px.min()),int(py.min()),int(px.max())+1,int(py.max())+1
        # Body anchor follows the opaque silhouette, not detached glow.
        body=core[main[source_index]-1]['points'];body=body[owner.ravel()[body]==source_index+1]
        bx=body%width;by=body//width;ground=int(by.max())+1
        feet=bx[by>=ground-12]
        pivot=float((feet.min()+feet.max()+1)/2) if len(feet) else (left+right)/2
        if index//6==len(ys)-2:pivot=(int(bx.min())+int(bx.max())+1)/2
        regions.append(f'Rect2({left}, {top}, {right-left}, {bottom-top})')
        pivots.extend([round(pivot-left,2),ground-top])
        if index<6:heights.append(ground-int(by.min()))
        patches=patch_rectangles(owner,source_index+1);total+=len(patches)
        values=', '.join('Rect2(%d, %d, %d, %d)'%tuple(p) for p in patches)
        subs+=f'[sub_resource type="Resource" id="frame_{index}"]\nscript = ExtResource("frame_type")\npatches = Array[Rect2]([{values}])\n\n'
    path=ROOT/f'{role}_sheet.tres';text=path.read_text()
    text=re.sub(r'^\[ext_resource[^\n]*id="frame_type"[^\n]*\n','',text,flags=re.M)
    text=re.sub(r'^\[sub_resource type="Resource" id="frame_\d+"\][\s\S]*?(?=^\[|\Z)','',text,flags=re.M)
    text=re.sub(r'^(row_count|body_pixels|regions|pivots|isolated_frames) = .*\n?','',text,flags=re.M)
    header,rest=text.split('\n',1)
    text=header+'\n[ext_resource type="Script" path="res://content/units/supports/would_be_wizard/visuals/wizard_frame.gd" id="frame_type"]\n'+rest
    text=text.replace('[resource]',subs+'[resource]',1)
    text+=f'row_count = {len(ys)-1}\nbody_pixels = {float(sorted(heights)[3])}\nregions = Array[Rect2]([{", ".join(regions)}])\n'
    text+='pivots = PackedVector2Array('+', '.join(map(str,pivots))+')\n'
    text+='isolated_frames = Array[Resource](['+', '.join(f'SubResource("frame_{i}")' for i in range(len(main)))+'])\n'
    path.write_text(text)
    print(role,'poses',len(main),'UV patches',total,'rendered pixels',np.count_nonzero(owner),'excluded faint islands',omitted)
