Boss icon pack (optional)
========================

MRT can show boss icons in the Note -> Encounter dropdown.
This works WITHOUT Encounter Journal on WoTLK 3.3.5a.

How it works
------------
The addon will try to load textures from:
  Interface\\AddOns\\MRT\\media\\bossicons\\<boss_name>.tga

Where <boss_name> is derived from the boss name:
- lowercased
- any non [a-z0-9] replaced with '_' (multiple '_' collapsed)

Examples
--------
"Lord Marrowgar" -> lord_marrowgar.tga
"Blood-Queen Lana'thel" -> blood_queen_lana_thel.tga
"Anub'Rekhan" -> anub_rekhan.tga
"Kael'thas Sunstrider" -> kael_thas_sunstrider.tga

Notes
-----
- Recommended format: 256x256 TGA (32-bit). Smaller sizes also work.
- If a file is missing, MRT will just show the boss name without an icon.
- You can create icons by taking in-game screenshots/portraits and converting them to TGA.
