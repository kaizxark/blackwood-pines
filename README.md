# 🌲 BLACKWOOD PINES: DEADWOOD OUTBREAK

[![Godot Engine](https://img.shields.io/badge/Godot-v4.3_Stable-478CBF?logo=godotengine&logoColor=white)](https://godotengine.org)
[![Graphics API](https://img.shields.io/badge/Renderer-OpenGL_4.6_/_Compatibility-brightgreen?logo=opengl&logoColor=white)](https://mesa3d.org)
[![Platform](https://img.shields.io/badge/Platform-Linux_Ubuntu_24.04-orange?logo=linux&logoColor=white)](https://ubuntu.com)
[![Architecture](https://img.shields.io/badge/Arch-x86__64-blue)]()
[![Status](https://img.shields.io/badge/Status-Fully_Playable-success)]()
[![License](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)

A photorealistic, adrenaline-fueled survival horror First-Person Shooter engineered in **Godot 4.3**. Stranded in the isolated Blackwood Alpine Valley, you must survive relentless undead horde incursions, master authentic firearms, repair fortified barricades, unlock mystery crates, and drink vital combat perks before the valley consumes you.

---

## 📸 In-Game Visuals & Environment

| Ranger Outpost Alpha & Tactical Porch | Timber Creek Bridge & Stream Wash |
| :---: | :---: |
| ![Ranger Outpost Alpha](outpost_alpha_cabin_view.png) | ![Timber Creek Bridge](creek_bridge_wash_view.png) |

| Ancient Stone Dolmen (Mystery Box Grotto) | 360° Alpine Cirque Panorama |
| :---: | :---: |
| ![Ancient Dolmen Grotto](ancient_dolmen_grotto_view.png) | ![Alpine Cirque Panorama](alpine_cirque_panorama_view.png) |

| Tactical Weapon Ready on Forest Trail | Dense Old-Growth Forest Understory |
| :---: | :---: |
| ![Weapon Ready Trail](weapon_ready_trail.png) | ![Lush Forest Undergrowth](lush_forest_undergrowth.png) |

---

## 🕹️ Controls & Tactical Input

| Action | Control | Tactical Effect |
| :--- | :---: | :--- |
| **Locomotion** | <kbd>W</kbd> <kbd>A</kbd> <kbd>S</kbd> <kbd>D</kbd> | Smooth kinematic traversal across rolling alpine hills |
| **Sprint** | <kbd>Shift</kbd> | High-speed dash ($10.5\text{ m/s}$) with FOV dynamic expansion |
| **Jump** | <kbd>Space</kbd> | Jump with coyote-time buffer & slope velocity preservation |
| **Crouch / Slide** | <kbd>Ctrl</kbd> / <kbd>C</kbd> | Tactical slide downhill when engaged during full sprint |
| **Fire Primary** | <kbd>LMB</kbd> | Discharge chambered firearm with 2nd-order spring recoil |
| **Aim Down Sights** | <kbd>RMB</kbd> | Tighten spread, zoom FOV to $54^\circ$, align iron sights |
| **Manual Reload** | <kbd>R</kbd> | Tactical magazine / tube reload |
| **Quick-Switch** | <kbd>Q</kbd> | Instantly swap between active and previously held weapon |
| **Cycle Arsenal** | <kbd>Scroll Up</kbd> / <kbd>Down</kbd> | Sequentially rotate through equipped firearms |
| **Slot Hotkeys** | <kbd>1</kbd> - <kbd>5</kbd> | Direct instantaneous weapon selection |
| **Interact / Repair** | <kbd>E</kbd> | Repair barricade planks, purchase wall-buys, buy perks |
| **Pause / Release Mouse** | <kbd>Esc</kbd> | Free mouse cursor & access system menu |

---

## 🔫 Authentic 5-Weapon Arsenal

Every firearm features custom 3D procedural modeling, damped harmonic recoil springs, dynamic reticle bloom, muzzle flash lighting, and caliber-accurate ballistics:

| Slot | Firearm | Caliber | Mag Capacity | Fire Rate | Tactical Role |
| :---: | :--- | :--- | :---: | :---: | :--- |
| **1** | **M1911 Tactical** | .45 ACP | 7 / 70 | Semi-Auto ($420\text{ RPM}$) | Pinpoint close-quarters sidearm |
| **2** | **Remington 870 Police** | 12-Gauge | 8 / 72 | Pump-Action ($68\text{ RPM}$) | Devastating 8-pellet buckshot blast |
| **3** | **AK-47 Kalashnikov** | 7.62x39mm | 30 / 180 | Full-Auto ($600\text{ RPM}$) | Heavy armor-penetrating automatic rifle |
| **4** | **M4A1 SOPMOD** | 5.56x45mm | 30 / 210 | Full-Auto ($800\text{ RPM}$) | Low-recoil precision tactical carbine |
| **5** | **Colt Python** | .357 Magnum | 6 / 36 | Revolver ($180\text{ RPM}$) | Massive kinetic stopping power |

---

## 🌲 Geological Landscape & World Architecture

* **Glacial U-Valley Topography & Creek Wash:**
  * Downstream natural gradient ($z = +90\text{m} \to z = -90\text{m}$) with a meandering geological valley spine.
  * Carved dry creek bed with rounded river stones, drift logs, and stepping stones.
  * Natural terracing: Outpost Alpha plateau, Ancient Stone Dolmen hollow, and High Lookout Bluff promontory.
* **Continuous 360° Alpine Mountain Amphitheater:**
  * Single seamless radial mountain ring ($R \in [110\text{m}, 320\text{m}]$) with 72 radial sectors and 14 elevation rings—eliminating disjointed flat panels or open seams.
  * Soaring summits reaching $127.8\text{m}$ (Mount Blackwood peak, Sawtooth arêtes, and Cathedral spires) with glaciated snowfields and wind-blown rime.
* **4-Octave Procedural Fractal Terrain Shader (`terrain_forest_lush.gdshader`):**
  * Multi-layer procedural splatting: dark forest loam, fallen pine needles, worn gravel trail, velvety moss, and rain puddles.
  * Triplanar vertical rock projection: cliffs exceeding $30^\circ$ project vertical strata and crustose lichens without stretching.
* **Lived-In World Architecture:**
  * **Ranger Outpost Alpha:** Weathered timber log cabin ($8\text{m} \times 6\text{m}$), raised wooden plank porch, corrugated zinc roof, radio antenna mast, and defensive window barricades.
  * **Timber Creek Bridge:** Heavy log trestle bridge spanning the dry stream wash with side rails.
  * **Ancient Stone Dolmen Grotto:** Megalithic ring of towering granite standing stones arching over the Mystery Box.
* **16,000+ Instanced Ecological Flora Assets (8 GPU MultiMeshes):**
  * 1,800 Douglas Pines ($18\text{m}-28\text{m}$) on montane slopes
  * 900 Broadleaf Hardwood Oaks ($12\text{m}-18\text{m}$) on warm sunlit flanks
  * 750 Silver Paper Birches ($10\text{m}-16\text{m}$) clustered near moist creek margins
  * 1,800 Understory Shrubs & Berry Bushes ($1.8\text{m}-3.2\text{m}$)
  * 3,600 Lush Feathered Ferns ($0.7\text{m}-1.3\text{m}$) hugging stream banks
  * 5,500 Alpine Wild Grass & Wildflower Tufts ($0.4\text{m}-0.8\text{m}$)
  * 480 Mossy Nurse Logs ($6\text{m}-10\text{m}$) aligned with slope fall-lines
  * 750 Glacial Granite Boulders & Stream Stones ($1.8\text{m}-4.5\text{m}$)
* **HeightMapShape3D Kinematic Collision:** Native 121×121 continuous heightfield collision eliminating ghost edges and ensuring flawless CharacterBody3D slope navigation.

---

## 🧟 Core Survival Mechanics

* **Round-Based Escalation:** `BlackwoodHordeDirector` handles wave progression, zombie sprint speeds, spawn quotas, and audio stinger crescendos.
* **Dynamic Dismemberment & Decapitation:** Headshots decapitate undead targets, triggering high-pressure arterial blood fountains and limb gib physics.
* **Barricade Fortification:** Board up broken windows with wooden planks (<kbd>E</kbd>) to delay incoming zombies and earn bonus points (+10 PTS/plank).
* **Wall-Buy Stations:** Interactive chalk wall outlines allow purchasing firearms or topping up reserve ammunition.
* **Perk Vending Machines:** Quench your thirst with **Juggernog** to permanently boost maximum health from 100 to 250 HP.
* **Mystery Box Roulette:** Spend 950 PTS to cycle the random 3D weapon roulette under a beacon of light.

---

## 🚀 Quick Start & Launch Instructions

### Prerequisites
* Linux (Ubuntu 24.04 LTS or compatible distribution)
* Godot Engine 4.3 Stable
* GPU with OpenGL 3.3+ / 4.6 (Compatible with Intel UHD, AMD Radeon Vega / RDNA, NVIDIA GeForce)

### Launching the Game
```bash
# Clone the repository
git clone https://github.com/kaizxark/blackwood-pines.git
cd blackwood-pines

# Launch the game directly
./run_game.sh
```

### Opening the Project in Godot Editor
```bash
./run_editor.sh
```

### Running the Automated Test Suites
```bash
# Verify all 7 core survival systems (locomotion, weapons, barricades, perks, etc.)
./bin/godot --headless --script tests/test_zombie_survival_loop.gd

# Verify mountain vistas, multi-mesh asset counts, and weapon cycling
./tests/verify_epic_overhaul.gd
```

---

## 📁 Project Architecture

```
blackwood-pines/
├── assets/
│   ├── materials/        # PBR material overrides
│   └── shaders/          # Custom GLSL shaders (mountain, terrain, foliage, rock)
├── core/
│   ├── BlackwoodHordeDirector.gd  # Round manager & zombie spawner
│   ├── BloodManager.gd            # Decals, gibs, and arterial blood fountains
│   ├── EventBus.gd                # Global decoupled signal hub
│   ├── GameManager.gd            # Score, perks, health, and global state
│   └── SoundManager.gd           # Procedural audio synth & sound pool
├── entities/
│   ├── player/           # First-person controller, camera pivot, and movement
│   └── enemies/zombie/   # Undead NPC, decapitation, and navmesh pathfinding
├── interactables/        # Barricades, wall-buys, perk machines, mystery box
├── levels/
│   └── zombie_outbreak/  # Blackwood_Pines.tscn alpine forest arena
├── tests/                # Automated verification suites & scene generators
├── ui/                   # Retro tactical HUD, health bars, crosshair, and killfeed
└── weapons/              # 5-weapon arsenal definitions, ballistics, and WeaponManager
```

---

## 📜 License
Developed for Project Proto-Breach under the MIT License.

<!-- Initial documentation milestone: Complete controls, lore, weapon stats, and rendering architecture -->

---

## 📊 System Requirements & Hardware Benchmarks

| Component | Minimum Specification | Recommended Specification |
| :--- | :--- | :--- |
| **OS** | Linux (Ubuntu 22.04+, Debian, Arch, Fedora) | Ubuntu 24.04 LTS (x86_64) |
| **Processor** | Dual-Core Intel Core i3 / AMD Ryzen 3 | Quad-Core AMD Ryzen 5 / Intel Core i5 |
| **Memory** | 4 GB RAM | 8+ GB RAM |
| **Graphics** | Integrated AMD Radeon Vega 8 / Intel UHD 630 | Dedicated GPU (NVIDIA GTX 1060 / AMD RX 580+) |
| **OpenGL** | OpenGL 3.3 Core Profile | OpenGL 4.6 (Core Profile) Mesa 25+ |
| **Target FPS** | 60 FPS (Compatibility Mode) | 120+ FPS (High-Fidelity) |

---

## ❓ Frequently Asked Questions (FAQ)

**Q: How do I switch weapons in the heat of combat?**  
A: You can use your mouse scroll wheel, press number keys <kbd>1</kbd> through <kbd>5</kbd>, or hit <kbd>Q</kbd> to quick-switch between your active and previously held weapon.

**Q: Where can I find more ammunition?**  
A: Wall-Buy chalk stations scattered around the perimeter allow you to purchase fresh reserve ammo for $250\text{ PTS}$ at any time.

**Q: How does zombie decapitation work?**  
A: Accurate headshots trigger instant decapitation, spawning high-velocity arterial blood fountains and granting maximum score points (+100 PTS).
