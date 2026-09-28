# Unity Cadet

Mobile space adventure prototype featuring AI wingmate Lieutenant Judy, persistent story memory, and ship-linking combat.

## Concept

Hova, a newly trained cadet, and Lieutenant Judy begin a freight escort mission. Judy diverts to a Nomad attack; Hova follows to help. A mysterious anomaly during a station's destruction strands them and their separate ships in uncharted space. Their adventure follows their struggle to survive, grow closer, and find a way home.

The player talks naturally with Judy through a small comms portrait. She should remember shared experiences and react to confirmed story and gameplay events.

## Start here

Read [Story and Product Requirements Document](docs/STORY_AND_PRD.md) before implementing features. It records approved story facts, open decisions, scope, and acceptance criteria. Do not turn proposed ideas or unexplained artifact details into established canon.

**Current status:** planning documentation only. No runnable prototype or verified AI integration is included yet.

## Build first: Judy's chat and story prototype

- Mobile-friendly conversation interface with a compact comms portrait.
- Judy character definition, story progression, persistent memories, and gradual relationship development.
- Simulated mission and ship events so conversation can be tested before flight integration.
- Structured link, unlink, and formation requests with confirmed success/failure responses.
- Text fallback, followed by microphone input and consistent spoken responses once the AI framework and access are verified.

Judy's portrait opens when she speaks, remains open during conversation, and closes afterward. Keep it small enough to preserve the gameplay view.

## Reuse first

Inspect the previously researched AI framework and Homelancer's existing code before selecting replacements. Reuse suitable existing libraries and components; build the project-specific character, story, and integration around them. Check compatibility and licenses, and retain required attribution.

Do not build a second full flight/combat engine. A compatible basic flight demo may be used for early testing; Homelancer supplies the intended gameplay foundation.

## Later gameplay integration

- Cockpit and chase-camera views with mobile flight/aim controls and targeting assistance.
- Separate ships for wingmate assistance, or ships physically linked one beneath the other.
- Linking increases firepower and boost; no exact multiplier is approved.
- Unlimited-ammunition primary energy weapons, regenerating shields, and finite torpedoes.
- Solar recharge near stars, resource gathering, and a journey back to charted space.
- Natural coordination with Judy alongside combat.

## Architecture boundaries

Game state owns ship movement, damage, resources, and linking. The conversation system receives those facts and may request actions; it must not invent successful execution. Keep Judy's character data separate from the reusable conversation system.

Homelancer develops the flight/combat foundation. Unity Cadet tests the two-character conversation/story experience. Starfire is a later, larger project with its own story and cast that can reuse proven systems.

## Implementation order

1. Identify and verify the previously researched chatbot framework.
2. Implement character/story data, conversation UI, and persistent state.
3. Add simulated event inputs and command-result handling.
4. Verify mobile interaction, story consistency, and restored memories.
5. Integrate voice when available, then connect reusable flight/combat systems.

## Definition of the first working prototype

The player can talk with Judy, trigger a simulated event, receive a story-consistent response, issue a link request and hear its actual result, and reload the session without losing selected memories. Clearly label simulated events and any non-AI fallback.

## Setup and testing

No install or run commands are available yet. Add exact setup instructions, required environment variables, and verified test commands with the first implementation. Keep API keys out of the public repository and client-side code.
