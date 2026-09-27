# Voice: "show the calendar on the fridge"

Say it to a voice speaker and it's on the fridge 10–15 seconds or so later
(an estimate: nobody has timed a real one yet). The speaker doesn't talk to
the display directly: it's a Home Assistant voice
satellite, and Home Assistant does the rest.

```
 "Hey Jarvis, show the calendar on the fridge"
        │
        ▼
 Voice speaker ───► Home Assistant Assist ───► brwr_trmnl sentences ───► script.brwr_trmnl_show
 (any Assist         wake word, speech-to-text,   (custom_sentences/)         │  MQTT, retained
  satellite)         intent                                                   ▼
        ▲                                                         brwr-trmnl/all/show
        └──── "Okay, Calendar is going on the fridge." ◄──                    │
                                                                              ▼
                                                        every display: fetch the Calendar screen, draw it
```

Any Assist satellite works the same way: the open speaker (a Raspberry Pi
running as a Home Assistant voice satellite), a Home Assistant Voice Preview
Edition, an ESP32-S3-BOX, the Home Assistant app on a phone or watch, or
typing into Assist. Nothing on the speaker needs to know the display exists.

## Set it up

You need [Home Assistant set up for the display](home-assistant.md) with the
package installed, and a working voice assistant (Settings › Voice
assistants).

1. Copy
   [`homeassistant/custom_sentences/en/brwr_trmnl.yaml`](../homeassistant/custom_sentences/en/brwr_trmnl.yaml)
   to `<config>/custom_sentences/en/brwr_trmnl.yaml`.
2. Restart Home Assistant (later edits only need the action
   `conversation.reload`).
3. Try it without the speaker: open Assist (the speech bubble in the top
   bar) and type *show the calendar on the fridge*.

Set the display's **Power mode** to **Always ready** (the default). In
**Deep sleep** a voice command waits until the display next wakes, and it's
only kept for so long: a screen for 15 minutes (a note for its 4 hours),
next, previous and refresh for 5 minutes. A display that wakes later skips
it.

## What you can say

| Say | Does |
|---|---|
| "Show the calendar on the fridge" | Shows a screen. With the TRMNL server as the image source it stays up for an hour (**Hold commanded screen**), then the playlist carries on; with Home Assistant screens it becomes the current screen |
| "Put the shopping list on the fridge", "Fridge, show the weather" | Same, other screens: *home*, *calendar*, *shopping list* or *grocery list*, *weather* or *forecast*, *note* |
| "Leave a note on the fridge saying dinner's at seven" | Posts a note for 4 hours |
| "Fridge note: back by six" | Same, shorter |
| "Next screen on the fridge", "Previous fridge screen" | Steps through the screens |
| "Refresh the fridge", "Clear the fridge display" | Ends a held screen or note and refreshes (with the TRMNL server as the source, the playlist moves on) |

The word lists are in the sentences file. To add a screen:

1. Add a view for it to the fridge dashboard.
2. Add it to `brwr_trmnl_publish_screens` in the package: its name and
   dashboard path.
3. Add the same name under `brwr_screen` in the sentences file, with the
   words you'll say for it.
4. If an LLM agent uses the scripts, add the name to the screen names in
   the **Fridge display: show** script's description too.
5. Reload scripts (Developer tools › YAML › Scripts), run **Fridge display:
   publish screens**, and run the action `conversation.reload`.

```yaml
      - in: "(bin|trash|recycling) [day]"
        out: "Bins"
```

## How long it takes

With **Always ready**, from the end of the sentence (estimates):

| Step | Time |
|---|---|
| Speech-to-text and intent | under a second (Home Assistant Cloud) to 1–3 s (Whisper on a Raspberry Pi) |
| Home Assistant → MQTT → display | well under a second |
| Display restarts, reconnects to Wi-Fi and MQTT | 3–7 s |
| TRMNL HA add-on renders the dashboard | 1–4 s (longer if its browser has to start: turn on **keep_browser_open**) |
| Decode, load and refresh the panel | ~3 s |
| **Total** | **about 8–17 seconds** |

The speaker answers straight away; it doesn't wait for the panel.

## With an AI conversation agent

If your voice assistant uses an LLM (OpenAI, Anthropic, Google, Ollama):

- Turn on **Prefer handling commands locally** in the voice assistant's
  settings. The sentences above then run instantly without the model and
  cost nothing; anything they don't match goes to the model.
- To let the model handle requests the sentences don't cover ("put the
  weather on the fridge for five minutes"), expose the scripts: open
  **Fridge display: show**, **post a note** and **next, previous or
  refresh** under Settings › Automations & scenes › Scripts, then ⋮ ›
  Settings › Voice assistants › expose. Their descriptions tell the model what
  each one does and which screen names exist. It can only show screens in
  the list, or a dashboard path or image URL you tell it about.

## More than one display

Everything above publishes to `brwr-trmnl/all/...`, so every display shows
it. To aim at one display, publish to its own topic,
`brwr-trmnl/<id>/show`, where `<id>` is in the device's MQTT info in Home
Assistant. For example, a sentence trigger in an automation:

```yaml
triggers:
  - trigger: conversation
    command: "show the calendar in the hall"
actions:
  - action: mqtt.publish
    data:
      topic: brwr-trmnl/a1b2c3/show
      payload: '{"screen": "Calendar", "hold": 30}'
      retain: true
  - set_conversation_response: "Okay, it's in the hall."
```

The per-display topic is retained until that display has handled it, so it
also reaches a display that's in deep sleep, when it next wakes.

## If it doesn't work

| Symptom | Check |
|---|---|
| Assist says "Sorry, I couldn't understand that" | The sentences file isn't loaded: its path, then `conversation.reload`. With an LLM agent, **Prefer handling commands locally** |
| Assist answers but the display doesn't change | The display's **Power mode**, and its **Last error** sensor. In Settings › Devices & services › MQTT › Configure, listen to `brwr-trmnl/#` and repeat the command |
| **Last error** says "No screen called Calendar" | The name in the sentences file must match a name in `brwr_trmnl_publish_screens`; after editing the list, reload scripts and run the publish script |
| **Last error** says "Couldn't load Calendar (…, HTTP n)" | That screen's dashboard path must open in the TRMNL HA add-on: try its URL in a browser |
| It takes 20 s or more | The add-on's browser is starting each time (**keep_browser_open**), or the display's Wi-Fi signal is weak |
