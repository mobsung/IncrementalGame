"""Deterministic authoring of the initial test resources; never edits reference artwork."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]
BASE = 'content/units/supports/would_be_wizard'
if (ROOT / BASE / 'forms/apprentice.tres').exists():
    raise SystemExit('Initial resources already authored. Edit resources directly; this bootstrap is not a rebuild tool.')

def resource(path, script, fields, refs=None, subs=''):
    refs = refs or {}
    text = '[gd_resource type="Resource" format=3]\n'
    text += f'[ext_resource type="Script" path="res://{script}" id="script"]\n'
    for key, (kind, target) in refs.items():
        text += f'[ext_resource type="{kind}" path="res://{target}" id="{key}"]\n'
    text += subs + '\n[resource]\nscript = ExtResource("script")\n'
    text += '\n'.join(f'{k} = {v}' for k, v in fields.items()) + '\n'
    file = ROOT / path
    file.parent.mkdir(parents=True, exist_ok=True)
    file.write_text(text, encoding='utf-8')

def quoted(s): return json.dumps(s)

acts = {
    'headlong_swing': ('Headlong Swing','swing','opponent',145,145,6,.6,'A wide physical staff swing. Every four basic cycles empowers it.'),
    'first_remedy': ('First Remedy','remedy','injured_ally',650,0,5,.65,'Heal the most injured ally. Spend up to three Notes and leave an annotation.'),
    'rewrite_wounds': ('Rewrite Wounds','rewrite','injured_ally',700,0,5,.65,'Heal and inscribe a budget of Written Recovery for future nonlethal wounds.'),
    'shared_margins': ('Shared Margins','margins','self',700,0,12,.8,'Link deployed allies: share 30% of damage and echo 20% of primary healing.'),
    'final_revision': ('Final Revision','revision','self',700,0,18,1.0,'In a crisis, restore 50% of unhealed wounds from the last four seconds.'),
    'prototype_trick': ('Prototype Trick','prototype','opponent',320,85,6,.75,'Throw a handmade physical charge; Setup prepares a faster gadget.'),
    'rigged_sigil': ('Rigged Sigil','sigil','opponent',500,95,6,.7,'Place a mechanical entry trap: physical explosion and knockback.'),
    'clockwork_familiar': ('Clockwork Familiar','familiar','self',500,0,12,.8,'Deploy a targetable wheeled decoy. Destroying it triggers Planned Failure.'),
    'grand_illusion': ('Grand Illusion','illusion','opponent',500,160,18,1.0,'Against a group: smoke, mirror decoys, delayed charges and physical retreat.'),
}
for aid, (name, key, target, reach, area, cooldown, cast, desc) in acts.items():
    resource(f'{BASE}/abilities/{aid}.tres','scripts/data/ability_definition.gd',{
        'id':'&'+quoted(aid),'display_name':quoted(name),'wizard_action':quoted(key),
        'description':quoted(desc),'target_kind':quoted(target),'range_radius':str(float(reach)),
        'area_radius':str(float(area)),'supports_area':'true' if area else 'false',
        'supports_multi_cast':'true' if key in ['swing','remedy','rewrite','prototype'] else 'false',
        'cast_time':str(cast),'cooldown':str(float(cooldown)),'minimum_cooldown':'1.0'})

resource(f'{BASE}/abilities/magic_basic.tres','scripts/data/damage_definition.gd',{
    'damage_coefficient':'0.0','magic_coefficient':'1.0','supports_multi_hit':'true'})
resource(f'{BASE}/abilities/physical_basic.tres','scripts/data/damage_definition.gd',{
    'damage_coefficient':'1.0','magic_coefficient':'0.0','supports_multi_hit':'true'})

forms = {
 'archsage':('Grimoire Archsage','healer',270,'Living Script',['rewrite_wounds','shared_margins','final_revision'],['Living Grimoire','The Story Continues'],None),
 'archmage':('False Archmage','ranged',260,'Loaded Staff',['rigged_sigil','clockwork_familiar','grand_illusion'],['Perfect Misdirection','Nothing Up My Sleeve'],None),
 'acolyte':('Grimoire Acolyte','healer',230,'Ink Spark',['first_remedy'],['Margin Notes'],'archsage'),
 'makeshift':('Makeshift Wizard','ranged',120,'Weighted Staff',['prototype_trick'],['Sleight of Hand'],'archmage'),
 'apprentice':('Reckless Apprentice','warrior',105,'Training Staff',['headlong_swing'],['Hard Lessons'],['acolyte','makeshift']),
}
for role,(name,cls,reach,basic,active,passive,next_form) in forms.items():
    refs={'visual':('Resource',f'{BASE}/visuals/{role}.tres'), 'basic':('Resource',f'{BASE}/abilities/{"magic" if role in ["acolyte","archsage"] else "physical"}_basic.tres')}
    refs.update({a:('Resource',f'{BASE}/abilities/{a}.tres') for a in active})
    fields={'id':'&'+quoted('would_be_wizard' if role=='apprentice' else 'wizard_'+role),
        'display_name':quoted(name),'unit_class':quoted(cls),'wizard_role':quoted(role),
        'basic_name':quoted(basic),'max_health':'250.0','physical_attack':'18.0','magic_attack':'16.0',
        'ability_power':'24.0','armor':'6.0','magic_resistance':'8.0','attack_speed':'1.0',
        'movement_speed':'220.0','engagement_radius':'350.0','attack_range':str(float(reach)),
        'gold':'0.0','experience':'0.0','souls':'0.0','critical_chance':'0.05',
        'basic_damage':'ExtResource("basic")','visual':'ExtResource("visual")',
        'basic_projectile_speed':'700.0' if role in ['acolyte','archsage','archmage'] else '0.0',
        'active_abilities':'Array[ExtResource("script")]([])',
        'passive_names':'PackedStringArray('+','.join(quoted(p) for p in passive)+')'}
    # Typed arrays require the element's script, not the combatant script.
    refs['ability_type']=('Script','scripts/data/ability_definition.gd')
    fields['active_abilities']='Array[ExtResource("ability_type")](['+','.join('ExtResource('+quoted(a)+')' for a in active)+'])'
    subs=''
    if next_form:
        choices=next_form if isinstance(next_form,list) else [next_form]
        refs['evolution_type']=('Script','scripts/data/evolution_definition.gd')
        for dest in choices:
            refs[dest]=('Resource',f'{BASE}/forms/{dest}.tres')
            subs+=f'\n[sub_resource type="Resource" id="evolve_{dest}"]\nscript = ExtResource("evolution_type")\nid = &"{dest}"\nrequired_level = {10 if role=="apprentice" else 30}\nform = ExtResource("{dest}")\ndescription = "Permanent branch. Refunds level points; preserves level, XP and Gold purchases."\n'
        fields['evolution_options']='Array[ExtResource("evolution_type")](['+','.join(f'SubResource("evolve_{d}")' for d in choices)+'])'
    resource(f'{BASE}/forms/{role}.tres','scripts/data/combatant_definition.gd',fields,refs,subs)

for role in forms:
    resource(f'{BASE}/visuals/{role}.tres','scripts/data/combatant_visual.gd',{
        'texture':'SubResource("portrait")','animation':'ExtResource("motion")','height':'155.0','faces_right':'true'},
        {'sheet':('Texture2D',f'{BASE}/visuals/spritesheets/{role}.png'), 'motion':('Resource',f'{BASE}/visuals/{role}_sheet.tres')},
        '\n[sub_resource type="AtlasTexture" id="portrait"]\natlas = ExtResource("sheet")\nregion = Rect2(0, 0, 256, 205)\n')
    resource(f'{BASE}/visuals/{role}_sheet.tres',f'{BASE}/visuals/wizard_sheet.gd',{
        'sheet':'ExtResource("sheet")','role':quoted(role)}, {'sheet':('Texture2D',f'{BASE}/visuals/spritesheets/{role}.png')})

for key,name in [('clockwork_familiar','Clockwork Familiar'),('mirror_decoy','Mirror Decoy')]:
    resource(f'{BASE}/forms/{key}.tres','scripts/data/combatant_definition.gd',{
        'id':'&'+quoted(key),'display_name':quoted(name),'max_health':'80.0','physical_attack':'0.0',
        'attack_range':'0.0','attack_speed':'0.1','movement_speed':'50.0','gold':'0.0','experience':'0.0','souls':'0.0',
        'visual':'ExtResource("visual")'}, {'visual':('Resource',f'{BASE}/visuals/{key}.tres')})

resource(f'{BASE}/gacha/wizard_rare.tres','scripts/data/summon_entry_definition.gd',{
    'unit':'ExtResource("unit")','rarity':'&"rare"','pool_weight':'1.0'},
    {'unit':('Resource',f'{BASE}/forms/apprentice.tres')})
for key,name,desc,effects,roles in [
 ('wizard_mastery','Practical Mastery','+12% active potency per rank.','{&"wizard_power": 0.12}',[]),
 ('wizard_training','Staff Practice','+10% basic coefficient per rank.','{&"basic_coefficient": 0.1}',[]),
 ('wizard_tempering','Weathered Robes','Amplifies individual Gold health and armor gains by 10%.','{&"gold_health": 0.1, &"gold_armor": 0.1}',[]),
]:
    resource(f'{BASE}/upgrades/{key}.tres','scripts/data/level_upgrade_definition.gd',{
        'id':'&'+quoted(key),'species_id':'&"would_be_wizard"','display_name':quoted(name),'description':quoted(desc),
        'max_ranks':'5','base_cost':'1','cost_increment':'0','required_levels':'PackedInt32Array(1, 5, 10, 20, 30)',
        'effects':effects})

file=ROOT/'resources/gacha/first_summon.tres'
text=file.read_text().replace('load_steps=3','load_steps=4').replace('[resource]','[ext_resource type="Resource" path="res://'+BASE+'/gacha/wizard_rare.tres" id="3"]\n\n[resource]').replace('([ExtResource("2")])','([ExtResource("2"), ExtResource("3")])')
file.write_text(text,encoding='utf-8')
file=ROOT/'resources/battle/first_arena.tres'
text=file.read_text()
refs=''
for key in ['wizard_mastery','wizard_training','wizard_tempering']:
    refs+=f'[ext_resource type="Resource" path="res://{BASE}/upgrades/{key}.tres" id="{key}"]\n'
for key in ['clockwork_familiar','mirror_decoy']:
    refs+=f'[ext_resource type="Resource" path="res://{BASE}/forms/{key}.tres" id="{key}"]\n'
text=text.replace('[resource]',refs+'\n[resource]')
lines=text.splitlines()
for i,line in enumerate(lines):
    if line.startswith('upgrades = '): lines[i]=line.replace('])',', '+', '.join(f'ExtResource("{k}")' for k in ['wizard_mastery','wizard_training','wizard_tempering'])+'])')
lines.append('extra_definitions = Array[ExtResource("1")]([ExtResource("clockwork_familiar"), ExtResource("mirror_decoy")])')
# Resolve exact combatant script ID from the resource instead of assuming ID 1.
import re
cd_id=re.search(r'path="res://scripts/data/combatant_definition.gd" id="([^"]+)"',text)
if not cd_id:
    lines.insert(1,'[ext_resource type="Script" path="res://scripts/data/combatant_definition.gd" id="wizard_combatant_type"]')
    lines[-1]=lines[-1].replace('ExtResource("1")','ExtResource("wizard_combatant_type")')
else: lines[-1]=lines[-1].replace('ExtResource("1")',f'ExtResource("{cd_id[1]}")')
file.write_text('\n'.join(lines)+'\n',encoding='utf-8')
# Existing Golem upgrades must never appear on or alter the Wizard.
for file in (ROOT/'content/units/warriors/spaghetti_golem/upgrades').glob('*.tres'):
    text=file.read_text()
    if 'scripts/data/level_upgrade_definition.gd' in text:
        file.write_text(text+'species_id = &"spaghetti_golem"\n',encoding='utf-8')
