# Home Assistant

brwr-trmnl talks to Home Assistant over MQTT. It appears as a device with
sensors, controls and button triggers, and it takes commands: show this
screen, post this note, next screen. Voice commands are those same commands
said out loud ([voice.md](voice.md)).

```
  Home Assistant                                            brwr-trmnl
  ┌───────────────────────────────────────────┐   MQTT     ┌──────────────┐
  │ Mosquitto broker  ◄────────────────────────┼──────────► │ state, button│
  │                                            │  commands  │ triggers     │
  │ Terminus add-on :2300  (TRMNL plugins,     │  ◄──────── │ GET screen   │
  │   playlists)                               │   image    │              │
  │ TRMNL HA add-on :10000 (dashboards → PNG)  │  ──────►   │ 1872 × 1404  │
  │ packages/brwr_trmnl.yaml (screens, scripts,│            │ 16 grays     │
  │   voice intents)                           │            │              │
  └────────────────────────────────────────────┘            └──────────────┘
```

## 1. Add-ons and integrations

| What | Why | Where |
|---|---|---|
| **Mosquitto broker** add-on + the **MQTT** integration | The device's connection to Home Assistant | Settings › Add-ons › Add-on store |
| **Terminus** add-on (port 2300) | TRMNL's plugins and playlists, served locally. Needed for the "TRMNL server" source | Add-on repository `https://github.com/usetrmnl/trmnl-home-assistant` |
| **TRMNL HA** add-on (port 10000) | Renders Home Assistant dashboards as 16-gray PNGs. Needed for "Home Assistant screens", and for voice/notes | same repository |

1. **Mosquitto**: install, start, then Settings › Devices & services › MQTT
   (Home Assistant offers it once the broker runs). Mosquitto accepts Home
   Assistant user logins: create a user such as `mqtt` (Settings › People ›
   Users, "Can only log in from the local network") and give the display that
   username and password.
2. **Add-on repository**: Settings › Add-ons › Add-on store › ⋮ ›
   Repositories, add `https://github.com/usetrmnl/trmnl-home-assistant`.
3. **Terminus**: install, set **ha_ip** to your Home Assistant's IP address,
   start, open the web UI and create an account. Terminus serves the device at
   `http://<ha-ip>:2300`; the display's setup page fills that in for you.
4. **TRMNL HA**: install, create a long-lived access token (your profile ›
   Security › Long-lived access tokens) and paste it into **access_token**.
   Turn on **keep_browser_open**: the first render after the browser closes
   takes 3–5 s longer, which you notice when you ask for a screen by voice.
   Port 10000 has no authentication, so keep it on your home network.

## 2. Connect the display

Hold **REFRESH** for 5–15 s (or power it up for the first time). It opens a
Wi-Fi hotspot called `brwr-trmnl-XXXXXX`. Join it; the setup page opens (or go
to `http://4.3.2.1`). Pick your Wi-Fi, then under **Home Assistant**:

- **Home Assistant address**: its IP address, e.g. `192.168.1.20`.
- **Screens come from**: *Terminus add-on* or *Home Assistant dashboards*.
  You can change this later in Home Assistant.
- **MQTT username / password**: the user from step 1.
- **Panel VCOM**: the voltage printed on the panel's ribbon cable, e.g.
  `-1.52`. A wrong value gives a washed-out picture. You can change it later.

Tap **Connect**. Within a minute the device appears under Settings › Devices &
services › MQTT as **brwr-trmnl XXXXXX**. Rename it ("Fridge") if you like.

With Terminus as the source, open the Terminus web UI: the display shows up
there too (it reports itself as a TRMNL X, so screens are 1872 × 1404 in 16
grays). Give it a playlist.

## 3. The device in Home Assistant

| Entity | Type | What it does |
|---|---|---|
| Battery | sensor | Estimated charge, % |
| Battery voltage | sensor (diagnostic) | Resting voltage at the last wake |
| Wi-Fi signal | sensor (diagnostic) | RSSI at the last wake, dBm |
| Last refresh | sensor (diagnostic) | When the panel last changed |
| Showing | sensor | What's on screen: "Playlist", a screen name, "Battery empty"… |
| Last error | sensor (diagnostic) | Why the last refresh failed, if it did |
| On screen | image | The image that's on the panel |
| Screen | select | Pick a screen. "Playlist" goes back to the schedule |
| Image source | select (config) | TRMNL server, or Home Assistant screens |
| Power mode | select (config) | Always ready, or Deep sleep ([power.md](power.md)) |
| Buttons | select (config) | *Change screens* (they also fire triggers), or *Home Assistant only* |
| Refresh interval | number (config) | Minutes; 0 = automatic (the server's rate, or 30 min for Home Assistant screens) |
| Hold commanded screen | number (config) | Minutes a commanded screen stays before the schedule resumes |
| Panel VCOM | number (config) | Volts, as printed on the ribbon cable |
| Refresh, Next screen, Previous screen | buttons | Same as the physical buttons |
| BACK / REFRESH / NEXT: short, double, long press | device triggers | For automations |

In **Deep sleep** the display only checks in when it wakes, so a change you
make in Home Assistant shows up at the next refresh (or press any button). In
**Always ready** it lands within about 10 seconds.

## 4. Home Assistant screens

The TRMNL HA add-on turns a dashboard view into the exact image the panel
wants. The device asks for
`http://<ha>:10000/<path>?viewport=1872x1404&dithering&dither_method=floyd-steinberg&palette=gray-16&format=png`.

1. **Make a dashboard for the fridge.** Settings › Dashboards › Add dashboard
   › *New dashboard from scratch*, URL `fridge-display`, not in the sidebar.
   Open it › ✎ › ⋮ › *Raw configuration editor* and paste
   [`homeassistant/dashboards/fridge-display.yaml`](../homeassistant/dashboards/fridge-display.yaml).
   Replace the example entity ids with yours.
2. **Install the package.** Copy
   [`homeassistant/packages/brwr_trmnl.yaml`](../homeassistant/packages/brwr_trmnl.yaml)
   into `<config>/packages/` and make sure `configuration.yaml` loads packages:

   ```yaml
   homeassistant:
     packages: !include_dir_named packages
   ```

   Restart Home Assistant. On start it publishes the screen list to every
   display (`brwr-trmnl/all/set/screens`). After editing the list, run the
   script **Fridge display: publish screens**.
3. **Choose it.** Set **Image source** to *Home Assistant screens*, or keep
   the TRMNL server and use the screens for voice commands and notes only.

Tips for dashboards on e-paper:

- **Panel views** with a grid or stack card keep the layout fixed at any zoom.
- `?zoom=2` in a screen's path doubles the size of everything, which is
  about right for reading from a metre away at 227 dpi. The note screen uses 3.
- Plain black on white reads best. Avoid pale colors, thin fonts and
  animations: the panel shows 16 grays and refreshes in about a second.
- The add-on waits for the page to settle. If a card loads late, add `&wait=1000`.

Any image URL works as a screen too: a camera snapshot proxied through the
add-on (`http://<ha>:10000/?url=<page>&viewport=1872x1404&...`), a static PNG
under `/local/`, or a Terminus screen.

## 5. Scripts and commands

The package's scripts work from automations, the dashboard and voice:

| Script | Does |
|---|---|
| `script.brwr_trmnl_show` | `screen:` name, or `path:` / `url:` (+ `name:`), and optional `hold:` minutes |
| `script.brwr_trmnl_note` | Sets `input_text.brwr_trmnl_note` and shows the Note screen for 4 h |
| `script.brwr_trmnl_command` | `command: next`, `back` or `refresh` (refresh also ends a held screen) |
| `script.brwr_trmnl_publish_screens` | Publishes the screen list |

```yaml
# The doorbell rang: show the front door for 5 minutes
- action: script.brwr_trmnl_show
  data:
    path: "fridge-display/doorbell?zoom=2"
    name: Doorbell
    hold: 5
```

They publish to `brwr-trmnl/all/...`, which every display listens to. Each
command carries a timestamp, so a display acts on it once, and one that was
asleep skips it if it's no longer current.

**MQTT topics**, for anything else (`<base>` = `brwr-trmnl/<last six of the MAC>`):

| Topic | Direction | Payload |
|---|---|---|
| `<base>/status` | device → | `online` / `offline` (retained; offline is the last will) |
| `<base>/state` | device → | JSON: battery, voltage, rssi, refreshed, screen, showing, source, power, buttons, refresh, hold, vcom, held_until, error |
| `<base>/image` | device → | URL of the image on screen |
| `<base>/button` | device → | `back_short`, `refresh_double`, `next_long`, … |
| `<base>/set/source`, `power`, `buttons`, `refresh`, `hold`, `vcom`, `screens` | → device | settings (retained) |
| `<base>/set/screen`, `<base>/cmd`, `<base>/show` | → device | one-shot commands (retained until the device has handled them) |
| `brwr-trmnl/all/set/screens` | → all | `[{"name": "Calendar", "path": "fridge-display/calendar?zoom=2"}, …]` |
| `brwr-trmnl/all/show` | → all | `{"screen": "Calendar", "hold": 30, "ts": 1790424000}` or `"path"` / `"url"` + `"name"` |
| `brwr-trmnl/all/cmd` | → all | `{"cmd": "next", "ts": 1790424000}` |

## 6. Buttons in automations

The front buttons are device triggers (Settings › Automations › + › Device ›
your display). A long press sends a trigger without changing the screen, so
it's free for your own use:

```yaml
triggers:
  - trigger: device
    domain: mqtt
    device_id: <your display>
    type: button_long_press
    subtype: button_2        # button_1 BACK, button_2 REFRESH, button_3 NEXT
actions:
  - action: light.toggle
    target:
      entity_id: light.kitchen
```

Set **Buttons** to *Home Assistant only* and short presses stop changing
screens too, so every press is yours. Holding REFRESH for 5 s (Wi-Fi setup)
or 15 s (reset) always works.

## Troubleshooting

| Symptom | Check |
|---|---|
| Device never appears | MQTT user/password; the broker's log; the display's **Last error** once it does connect |
| "Couldn't load Calendar" | Open the screen's add-on URL in a browser; the path must match the dashboard URL and view path |
| Screen changes take minutes | Power mode is Deep sleep, or the display lost Wi-Fi (Wi-Fi signal sensor) |
| Washed-out picture | Panel VCOM |
| Entities "unavailable" | The display went offline unexpectedly (last will): battery, Wi-Fi or a crash |
