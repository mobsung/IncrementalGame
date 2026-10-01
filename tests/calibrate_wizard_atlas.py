"""Read alpha only, emit authored regions/pivots. Source PNG bytes are never changed."""
from pathlib import Path
from PIL import Image
import re
from collections import deque

def component_bounds(alpha):
    width,height=alpha.size
    pixels=alpha.tobytes()
    seen=bytearray(width*height)
    components=[]
    for start,value in enumerate(pixels):
        if value<100 or seen[start]: continue
        queue=deque([start]);seen[start]=1
        size=0; left=width;top=height;right=0;bottom=0
        while queue:
            i=queue.popleft();x=i%width;y=i//width
            size+=1;left=min(left,x);right=max(right,x+1);top=min(top,y);bottom=max(bottom,y+1)
            for other in (i-1 if x else -1,i+1 if x+1<width else -1,i-width if y else -1,i+width if y+1<height else -1):
                if other>=0 and not seen[other] and pixels[other]>=100:
                    seen[other]=1;queue.append(other)
        components.append((size,(left,top,right,bottom)))
    return max(components)[1]
root=Path(__file__).resolve().parents[1]/'content/units/supports/would_be_wizard/visuals'
if 'isolated_frames' in (root/'apprentice_sheet.tres').read_text():
    raise SystemExit('Isolated UV frames are authoritative. Use tests/isolate_wizard_frames.py instead.')
cuts={
 'apprentice':[0,198,369,537,739,1024],
 'acolyte':[0,200,389,558,742,911,1024],
 'archsage':[0,188,356,521,698,886,1024],
 'makeshift':[0,214,400,582,751,913,1024],
 'archmage':[0,187,359,528,732,880,1024],
}
for role,ys in cuts.items():
    im=Image.open(root/'spritesheets'/f'{role}.png')
    w,h=im.size
    ys=[round(y*h/1024) for y in ys]
    regions=[]; pivots=[]; heights=[]
    for row in range(len(ys)-1):
        for col in range(6):
            x=round(col*w/6); right=round((col+1)*w/6)
            y=ys[row]; bottom=ys[row+1]
            expanded_y=max(0,y-30);expanded_bottom=min(h,bottom+30)
            alpha=im.getchannel('A').crop((x,expanded_y,right,expanded_bottom))
            box=component_bounds(alpha)
            if not box: raise ValueError((role,row,col,'empty frame'))
            # Keep nominal cell for VFX, ground from opaque core not faint aura.
            region_left=max(0,box[0]-2);region_top=max(0,box[1]-2)
            region_right=min(right-x,box[2]+2);region_bottom=min(expanded_bottom-expanded_y,box[3]+2)
            pivot_x=(box[0]+box[2])/2-region_left
            lower=alpha.crop((box[0],max(box[1],box[3]-12),box[2],box[3])).point(lambda a:255 if a>=100 else 0).getbbox()
            if lower: pivot_x=box[0]+(lower[0]+lower[2])/2-region_left
            if row==len(ys)-2: pivot_x=(region_right-region_left)/2
            regions.append(f'Rect2({x+region_left}, {expanded_y+region_top}, {region_right-region_left}, {region_bottom-region_top})')
            pivots.extend([round(pivot_x,2),box[3]-region_top])
            if row==0: heights.append(box[3]-box[1])
    file=root/f'{role}_sheet.tres'
    text=file.read_text()
    text=re.sub(r'^(row_count|body_pixels|regions|pivots) = .*\n','',text,flags=re.M)
    text+=f'row_count = {len(ys)-1}\nbody_pixels = {float(sorted(heights)[len(heights)//2])}\n'
    text+='regions = Array[Rect2](['+', '.join(regions)+'])\n'
    text+='pivots = PackedVector2Array('+', '.join(str(v) for v in pivots)+')\n'
    file.write_text(text)
    portrait=root/f'{role}.tres'
    text=portrait.read_text()
    text=re.sub(r'^region = Rect2\([^\n]+\)', 'region = '+regions[0],text,flags=re.M)
    portrait.write_text(text)
    print(role,im.size,'frames',len(regions),'body',sorted(heights))
