"""Idempotent atlas resource authoring; preserves the generated PNG."""
from pathlib import Path
import re
ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'content/units/supports/would_be_wizard'
names = ['training_staff','ink_spark','living_script','weighted_staff','loaded_staff','headlong_swing',
 'first_remedy','rewrite_wounds','shared_margins','final_revision','prototype_trick','rigged_sigil',
 'clockwork_familiar','grand_illusion','hard_lessons','margin_notes','living_grimoire','the_story_continues',
 'sleight_of_hand','misdirection','encore','smoke','explosion','hat']
out = BASE / 'visuals/icons'
out.mkdir(exist_ok=True)
for index, name in enumerate(names):
    (out / (name + '.tres')).write_text('[gd_resource type="AtlasTexture" format=3]\n'
      '[ext_resource type="Texture2D" path="res://content/units/supports/would_be_wizard/visuals/spritesheets/icons.png" id="sheet"]\n'
      f'[resource]\natlas = ExtResource("sheet")\nregion = Rect2({index%6*256}, {index//6*256}, 256, 256)\n', encoding='utf-8')
def attach(path, fields):
    text = path.read_text(encoding='utf-8')
    text = re.sub(r'^\[ext_resource[^\n]+id="icon_[^\n]+\n', '', text, flags=re.M)
    text = re.sub(r'^(?:icon|basic_icon|passive_icons) = .*\n?', '', text, flags=re.M)
    refs = ''
    props = ''
    for key, values in fields.items():
        ids = []
        for name in values:
            id = 'icon_' + name
            refs += f'[ext_resource type="Texture2D" path="res://content/units/supports/would_be_wizard/visuals/icons/{name}.tres" id="{id}"]\n'
            ids.append(f'ExtResource("{id}")')
        props += key + ' = ' + (f'Array[Texture2D]([{",".join(ids)}])' if key == 'passive_icons' else ids[0]) + '\n'
    header, rest = text.split('\n', 1)
    text = header + '\n' + refs + rest
    path.write_text(text.rstrip() + '\n' + props, encoding='utf-8')
for path in (BASE/'abilities').glob('*.tres'):
    if path.stem in names: attach(path, {'icon':[path.stem]})
forms = {'apprentice':('training_staff',['hard_lessons']), 'acolyte':('ink_spark',['margin_notes']),
 'archsage':('living_script',['living_grimoire','the_story_continues']), 'makeshift':('weighted_staff',['sleight_of_hand']),
 'archmage':('loaded_staff',['misdirection','encore'])}
for role, (basic, passives) in forms.items():
    attach(BASE/'forms'/f'{role}.tres', {'basic_icon':[basic], 'passive_icons':passives})
