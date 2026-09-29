# Unity Cadet mobile cockpit prototype v0.2.0

September 29, 2026. Latest creator request authorizes a simple playable mobile cockpit based on the approved anime concept, before detailed video production. This adds a small training demo; it does not replace Homelancer or complete the original AI milestones.

## Implemented
Godot 4.3 Compatibility renderer; no hands; flat cockpit frame; two symmetric touch sticks with independent touch IDs; shield/hull/energy percentages; six action buttons with independent auto/manual toggles; targeting ring, offscreen threat arrows and radar. Three training drones, primary weapon energy consumption, finite missiles and proximity mines, recharge costs, damage, failure/restart, victory/debrief and pause. Energy passively recharges; left stick controls yaw/pitch with slow forward flight. Right stick places the aim ring. Scripted Judy status/help/link-test responses, using the approved anime helmet portrait as a still atlas region. No AI, mic, voice, video or persistent character memory is represented as complete.

Desktop: WASD flight, Space fire; mouse operates HUD. Mobile: landscape, two thumbs on sticks, index fingers on top buttons. Six switches default to manual to avoid spending equipment unexpectedly. Auto guns and missiles require an aimed target. Auto mines require a nearby target. Blue wing ship is a formation placeholder; link is explicitly a simulation.

## Reuse
Basic ship basis movement, cone-style target eligibility, cooldown and mesh construction adapted from the owner's `houawanych-pixel/homelancer-digital/scripts/game.gd` at `fff8284ae4f7de97d1b21dad11a18222604331be`. The existing Unity-cadet Godot scene and project are retained. No third-party Freelancer code/assets or external chatbot code copied.

## Asset status
- `client/assets/Unity_Cadet_Judy_Portrait_v01.webp`: approved generated concept, extracted and resized as a small runtime portrait; UI is live code, not the screenshot background.
- Regular fleet source filename supplied by user: `c6c661d8-6cf8-4db9-8e42-a33f1bbddd34_8087e6a442c479976f7ab9bd7e3f7ecf.glb`.
- Enemy fleet source filename supplied by user: `c4c7fd83-1dca-4d45-abe8-5a6cab5a71c4_1696a7d40b9de77e32b5d8617258b20d.glb`.
- Earlier cadet source: `7e180e15-a913-452b-ab0a-e8d3c92cf233_glb_run_36edf4307dfe16e80679b422f316adfd.glb`.
These GLBs were not present in either checked-out repository. Drive metadata verified September 29: enemy source `1hutSCmvizMoq0eR4YGn_NPYdyR_cxpdH` (19,774,856 bytes) and original cadet `1iLsaHkbyBWkO3Ck3FD67biEjRFCjTLcb` (23,774,004 bytes). The separate regular fleet file remains unresolved. Sources have not been downloaded or integrated. No model separation or topology optimization is claimed. Current drones and wing ship are named procedural training placeholders.

## Run and export
Open `client/project.godot` in Godot 4.3 and run. Headless verification:
`godot --headless --path client --editor --import --quit`
`godot --headless --path client -- --self-test`
Export with 4.3 single-thread web release templates:
`godot --headless --path client --export-release Web`
Serve `web/` over HTTP, not file://. Open index.html. GitHub workflow imports, tests, exports and publishes the same source on main, with commit and checksums in version.txt.

## Remaining work
Import/split the actual ship GLBs; improve cockpit icons and visual effects; test on a physical Samsung; connect original planned backend and voice/video pipeline; make story/memory persistence separately. Training dialogue is not the canon opening mission. No real-device FPS claim.

## Creator additions — September 29
- Left repair controls show individual charge stocks out of 5. Kits restore 35%; no consumption at full health or during cooldown. Auto kit modes activate at 55% or below. Passive shields regenerate 3%/s after four damage-free seconds without kits. Energy also recharges. All rates are prototype tuning.
- Left stick: WARP above, TRACTOR inward/right. Right stick: ENGINE KILL above, THRUST inward/left. Hold thrust; release stops boost. Engine cut brakes to zero in this training demo (not Freelancer inertial coast). Warp requires stopped engine, no steering, 25 energy and five seconds of uninterrupted charge; movement cancels. Warp switches to an empty training sector; no story mission progression claimed.
- TRACK NEXT selects an enemy marker; aim still controls weapons. Tractor collects green salvage within 100 m, adding one of each repair charge, capped at five.
- CALL / LOG opens Judy and hostile test channels. Incoming Judy call, Answer/Decline, End Call and a three-entry log. Hostile Test simulates an incoming hostile call. All dialogue is authored training text, not live AI.
- Center comms panel narrowed so the added inward controls remain usable.

## Verification in this session
Godot 4.3 import and web export succeeded. Deterministic simulation checks passed for targeting, gun cooldown/damage, finite missile/mine stocks, finite repair charges/cooldown, link rejection during threats, flight movement, engine cut, stationary warp start, movement cancellation, completion, target tracking, and call/end-call log. Headless engine emits dummy-renderer mesh cleanup messages on exit. Local Chromium 134 software-rendering startup crashed (SIGSEGV); mobile browser interaction and physical-device performance remain unverified.

## Publishing status
Source published to the existing repository. GitHub runner import, simulation checks and export passed. Initial deployment could not create the Pages site: `Resource not accessible by integration`. Owner must set repository Settings → Pages → Source to GitHub Actions, then rerun the Mobile cockpit playtest workflow. Export artifacts are retained before the Pages check. No public play URL has been verified yet.
