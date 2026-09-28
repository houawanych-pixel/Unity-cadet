# Unity Cadet — Story Lock v1

Date: September 28, 2026
Source: creator's spoken storyline and explicit request to lock it in.
Status: approved story foundation; implementation and unresolved details remain open.

## Identity and premise

The title is **Unity Cadet**. Hova is the player character, a cadet who has just finished training. Lieutenant Judy is the experienced pilot accompanying him. Each flies a separate ship. The central adventure follows the two of them, stranded in uncharted space, surviving and fighting their way back to charted space and ultimately home.

## Locked opening sequence

1. Hova and Judy begin a freight-carrier escort mission.
2. Judy receives an urgent call for help: Nomads have entered a sector. She diverts to the battle and orders Hova to stay with the carrier because he is not ready to fight Nomads.
3. Hova asks the freight pilot what Nomads are. The pilot describes them as powerful energy beings, an energy race with energy weapons.
4. Worried about Judy, Hova decides to help. The freight pilot encourages him to go, explaining that this is a familiar route they routinely travel.
5. The story shows Judy reaching the battle first. Nomads are everywhere, the station is being destroyed, and defenders are dying.
6. Hova jumps to Judy's coordinates. By his arrival, Judy is the only surviving defender there. Hova is immediately pursued and overwhelmed by the danger.
7. The Nomads are seeking an artifact. During the station's final explosion, the artifact activates and warps Hova and Judy, with their ships, away from the battle.
8. They emerge in unknown space. Their charts cannot establish where they are. Finding their way home becomes the main story.

## Locked adventure systems

- Live conversation: the player speaks to Judy, and she answers through the intended AI character/story system. Judy participates in driving the unfolding adventure.
- Two ships: Hova and Judy retain their own ships and can operate separately.
- Linked configuration: the ships physically lock together, one underneath the other, forming one combined craft. Both ships' boosters contribute to the linked craft.
- Shared combat roles: while linked, one pilot can handle flight while the other operates turrets or other ship systems. Exact role-switching controls remain to be designed.
- Solar recharge: the ships use solar panels and can replenish their energy near stars. Charge rate, safe distance, capacity, and energy costs remain game-design parameters.
- Resource gathering: the journey includes collecting resources and visiting or docking at planetary destinations.
- Story focus: the relationship, conversations, decisions, dangers, and adventures shared by Hova and Judy anchor the journey home.

## Build guardrails

Preserve this opening sequence and the two-pilot premise when writing missions or implementing systems. Do not replace Hova with Trent or rename the project Starfire or Unity Connect. Treat the creator's Freelancer comparison as a reference for the described opening, not a source of additional unstated canon.

The AI implementation should respect these fixed story facts. Proposed implementation principle: keep ship energy, resources, location, damage, and objectives in authoritative game state, and supply those facts to Judy's AI so conversation stays consistent with gameplay. This principle is a technical recommendation, not an already implemented feature.

## Deliberately unresolved

- Artifact name, origin, exact location before activation, activation mechanism, and fate after the warp.
- Why the artifact transports these two ships and where it sends them.
- Exact AI bot engine previously discussed: not named or verified in this transcript.
- Detailed Nomad lore beyond the creator's description.
- Ship names, precise docking geometry, linked handling, resource balance, and route home.
- Specific later missions, encounters, and ending.

These gaps are open decisions; they must not be silently filled in as approved canon. This document records story direction and does not claim a playable build or AI integration exists.

# Story additions and Product Requirements Document (PRD)

Revision: September 28, 2026, following the creator's continued design discussion. This section extends the story lock above and takes precedence where it clarifies an earlier statement.

## Additional approved story and game direction

- The station disaster includes an unexplained anomaly: everything appears to freeze, then a sudden displacement occurs. Hova and Judy do not know what happened or understand the artifact. The creator described everyone teleporting away; the scope of other transported beings and their destinations remains unresolved. Do not have Judy reveal an explanation she does not know.
- Judy gradually falls in love with Hova during their shared survival journey. Their experiences and conversations should give the relationship emotional continuity. Suggested approach: shared hardship builds trust over time, and the player chooses Hova's response. Specific romance scenes remain proposals.
- Both ships incorporate some Nomad technology. Primary energy weapons have no expendable ammunition count and remain available; shields regenerate. Torpedoes are finite carried equipment: expended torpedoes are gone. Do not introduce ammunition scarcity for the primary guns.
- Linking the ships increases firepower and boost. No exact multiplier is approved. Separate ships provide an assisting wing pilot; the player chooses to stay separate or combine. Flanking and covering behavior are proposed ways to make that choice useful.
- Unity Cadet is a mobile game with cockpit and chase views and Freelancer-inspired targeting/combat. Detailed flight and combat implementation comes from Homelancer.
- Judy's comms portrait is small, using the creator's Star Fox reference for compact presentation. It opens and lights up when she speaks, stays open for an ongoing conversation, and closes afterward. Suggested refinement: a brief response grace period and a tap-to-pin option; exact timing is not locked.
- Spoken coordination includes commands such as “Judy, link up,” “go into formation,” and unlink/break-away requests. Judy acknowledges and responds to actual execution status.

## Project relationship

| Project | Responsibility |
|---|---|
| Homelancer | Flight, combat, targeting, and gameplay foundation developed separately. |
| Unity Cadet | Focused two-character test of conversation, persistent character memory, story, and later integration with the gameplay foundation. |
| Starfire | Later, larger project with its own story and more characters, reusing proven systems. |

These are intended responsibilities, not verified claims about existing code or completed builds.

## Phase 1 objective: chat and story prototype

Build and validate a mobile-friendly Judy conversation and story interface independently of flight gameplay. Do not wait for Homelancer's complete gameplay. Use clearly labeled simulated events and ship state until integration is available.

### In scope

1. Judy character definition: identity, lieutenant role, personality guidance, known facts, knowledge limits, relationship progression, and voice/presentation requirements.
2. Story state: escort, distress call, Judy's diversion, Hova's intervention, station anomaly, and arrival in uncharted space. Authored milestones preserve the opening; dynamic conversations operate within those facts.
3. Text conversation first, with an interface that can accept microphone input and return spoken responses. Live speech integration depends on verifying the previously discussed AI engine and its available access. Provide a text fallback.
4. Persistent session state and selected memories: decisions, shared events, current objective, relationship milestones, and relevant past conversations. Reloading a session restores these facts. Do not advance romance solely by message count.
5. Compact comms portrait states: closed, incoming/speaking, listening/conversation, and closing. Temporary portrait assets must be labeled until the supplied artwork is inspected and mapped.
6. A test panel for simulated events: threat detected, low energy, damage, rescue, resource collection, recharge, link success/failure, and unlink success/failure.
7. Command interpretation: ordinary conversation stays dialogue; recognized commands become structured requests. The simulation or later gameplay system decides whether a request succeeds.
8. A reusable character interface, with Judy's biography and story data kept separate so Starfire can add characters later.

### Out of scope for this phase

Playable flight, combat simulation, enemy AI, targeting physics, ship docking geometry, camera gameplay, planetary exploration, and full Starfire support. These requirements remain recorded for later integration; do not duplicate Homelancer's gameplay work.

## Proposed integration contract

Agree this small boundary with Homelancer before connecting implementations. These names are proposed, not verified existing APIs.

- Inputs to the story system: event ID, event type, current story phase, location/charted status, both ships' energy/shields/damage, torpedo stock, link status, threats, and objective.
- Outputs: dialogue text, intended emotional/presentation state, and optional command request such as link, unlink, or formation.
- Execution result: pending, succeeded, or failed, plus a reason. Judy must not claim ships linked merely because she agreed to the request.
- Authority: gameplay owns resources, damage, movement, and link state. Story state owns unlocked narrative milestones. The language model may suggest actions but must not invent completed actions or rewrite locked canon.
- Memory updates: retain confirmed events and useful conversation facts; distinguish player speculation about the artifact from established facts.

## Phase 1 acceptance criteria

- A player can converse with Judy in the mobile interface without running a flight level.
- Judy consistently recognizes Hova and her own role, follows the current story phase, and treats the anomaly as unexplained.
- A simulated event changes her response appropriately; she does not claim events occurred when none were supplied.
- A link request produces an acknowledgment, followed by a truthful success/failure response after the test harness returns its result.
- Saved choices and selected memories survive closing and reopening the session.
- Relationship development follows shared events and player responses without skipping immediately to intimacy.
- The small comms window opens during speech/conversation and closes when the exchange ends without blocking primary mobile interaction.
- Missing AI access or a failed voice request produces a clear fallback, not fake live-AI success.

## Build sequence and remaining dependency

1. Verify the existing Unity Cadet research specification and identify the previously selected AI engine before choosing a new provider or promising live voice functionality.
2. Build the story data, Judy profile, chat interface, memory store, and simulated-event harness.
3. Validate the acceptance criteria with text, then connected voice when available.
4. Connect the agreed event/command interface to Homelancer once its relevant gameplay systems are ready.
5. Playtest the combined mobile experience before expanding the architecture for Starfire.

Current completion status: storyline and PRD documented. This update does not establish that implementation has begun or that any playable or live-AI prototype has been tested.

## Reuse-first implementation requirement

Creator clarification: use existing resources and suitable open-source components rather than building every system from scratch. A minimal flight component is acceptable for a demonstration; full combat/gameplay development remains Homelancer's responsibility.

- First inspect Homelancer's existing work and the previously researched chatbot engine for reuse.
- If a minimal flight demonstration needs another component, evaluate existing spaceship-flight/shooter repositories before writing a custom controller. No particular repository has yet been selected or verified.
- Reuse a suitable chatbot/voice framework for the conversation infrastructure. Supply Unity Cadet's own character profile, story state, memory rules, and gameplay integration.
- Check each candidate's license, engine compatibility, mobile controls/performance, dependencies, and maintenance before adopting it. Retain required attribution.
- Keep the first prototype small: conversation and story with simulated events; optionally a basic flight scene if a compatible reusable component is available. Do not let a borrowed flight demo turn into a duplicate Homelancer combat project.
- Existing source code is a starting component, not proof that the integrated experience works. Completion requires testing the connection between dialogue, commands, game state, memory, and mobile presentation.