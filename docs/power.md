# Power and battery life

brwr-trmnl runs on a 5000 mAh LiPo and charges over USB-C. How long a charge
lasts depends mostly on two settings you can change in Home Assistant: the
**power mode** and the **refresh interval**.

> **Estimates, not measurements.** The currents below come from datasheets and
> published measurements of the same parts, and no prototype has been measured
> yet. Check your own build: the **Battery** sensor in Home Assistant plotted
> over a week tells you the real rate.

## The power path

```
 USB-C (charge) ──► TP4056 charger ──► OUT+ ─┬─► XIAO ESP32-S3 BAT+ ──► 3.3 V regulator ──► ESP32-S3
                     + DW01A protection      │
 LiPo 5000 mAh ◄──► B+ / B−                  ├─► MiniBoost 5 V (TPS61023) ──► e-paper HAT (IT8951)
                                             │     EN ◄── GPIO6: on only while drawing
                                             └─► 220k / 220k divider ──► GPIO4 (battery voltage)
```

- The **panel's controller is powered only while it draws.** The MiniBoost
  is a "true disconnect" booster: with EN low its output is cut off from the
  battery completely, so the HAT draws nothing between refreshes. That's
  why this build uses it rather than a booster without an enable pin, which
  would feed the HAT all the time.
- The **XIAO runs straight off the battery** through its own low-dropout
  regulator, and sleeps between refreshes.
- The **e-paper holds its picture with no power at all.**

## Where the current goes

### Asleep

| | Current | Source |
|---|---|---|
| XIAO ESP32-S3, deep sleep | ~14 µA | Seeed's figure for the XIAO ESP32S3 |
| MiniBoost EN pull-up (100 kΩ to the battery, held low) | ~40 µA | 4 V ÷ 100 kΩ |
| Battery divider, 2 × 220 kΩ | ~9 µA | 4 V ÷ 440 kΩ |
| TP4056 module (charger off, DW01A protection) | ~4 µA | datasheets, typical |
| The battery's own protection board | ~3 µA | typical |
| MiniBoost booster (off), HAT (unpowered) | < 1 µA | TPS61023 shutdown current |
| **Total** | **~70 µA, about 1.7 mAh a day** | |

The largest item is the pull-up resistor on the MiniBoost's EN pin. It's
harmless, but if you want the last 5% (or refresh only a few times a day),
remove the 100 kΩ resistor next to the EN pin on the MiniBoost (R1 on
Adafruit's schematic): the 4.7 kΩ pull-down on the carrier keeps the booster
off without it. Sleep current drops to about 30 µA.

### Each refresh

| Step | Time | Battery current |
|---|---|---|
| Boot, connect to Wi-Fi and MQTT | 2–4 s | ~90 mA |
| Ask the server, download the image (1872 × 1404 PNG) | 1–6 s | ~90 mA (longer when the TRMNL HA add-on renders a dashboard) |
| Decode into PSRAM | ~1 s | ~70 mA |
| Power the HAT, load the image over SPI, refresh the panel | ~3 s | ~200 mA (5 V through the booster) |
| Report to Home Assistant, sleep | < 1 s | ~90 mA |
| **Total** | **7–15 s** | **0.5–0.9 mAh** |

### Awake and listening ("Always ready")

The ESP32-S3 stays connected to Wi-Fi and MQTT in automatic light sleep,
waking for Wi-Fi beacons and MQTT keep-alives. Expect **2–5 mA**, depending
mostly on your network: routers that send a lot of broadcast traffic keep it
awake more often.

## Battery life

5000 mAh, counting 85% of it as usable (the firmware stops at 3.35 V, and
cells lose capacity with age):

| Power mode | Refresh | Per day | One charge lasts |
|---|---|---|---|
| Deep sleep | every 15 min | 50–88 mAh | **2–3 months** |
| Deep sleep | every 30 min | 26–45 mAh | **3–5 months** |
| Deep sleep | every 60 min | 14–23 mAh | **6–10 months** |
| Always ready | every 60 min | 60–142 mAh | **4–10 weeks** |
| Always ready | every 30 min | 72–163 mAh | **4–8 weeks** |

Voice commands, button presses and screens pushed from Home Assistant each
cost about one refresh.

## Choosing a power mode

| | **Always ready** (default) | **Deep sleep** |
|---|---|---|
| A voice command or automation shows up | In about 5–10 seconds | At the next refresh, or when you press a button |
| Buttons | Instant; press events reach Home Assistant straight away | Instant (a press wakes it) |
| Settings changed in Home Assistant | Applied at once | Applied at the next wake |
| One charge | Weeks | Months |

Change it from the device page in Home Assistant (**Power mode**). If "show
the calendar on the fridge" is what you built it for, keep **Always ready**
and charge it every month or so. If it's a calm dashboard that changes every
half hour, **Deep sleep** gets you a season per charge.

In Always ready, if Wi-Fi or MQTT drops for two minutes the device gives up
listening and sleeps until its next refresh, then tries again, so a router
outage doesn't drain the battery.

## Charging

- Plug a USB-C charger into the **CHARGE** port (the TP4056 module) at the top
  edge. It charges at 1 A: about **5–6 hours** from empty. The module's LED is
  red while charging and turns blue or green when it's done.
- The other port, **USB**, is the XIAO's. It's for flashing and logs, and
  also charges, slowly (100 mA, about two days from empty).
- It keeps working while it charges.
- **If a USB-C-to-C charger does nothing**, the charger module is missing the
  resistors that USB-C chargers look for. Use a USB-A-to-C cable, or buy a
  module that lists "5.1k CC resistors".

## When the battery runs out

Below 3.35 V (resting) the booster can't hold 5 V through a refresh, so the
display shows **Battery empty**, reports it to Home Assistant (the **Last
error** sensor, and **Showing** reads "Battery empty"), and stops refreshing.
Charge it, then press any button.

It still draws its sleep current while it waits. The charger module's
protection disconnects the cell at about 2.4 V, but charge it within a
month or two of it saying empty: lithium cells don't like being stored flat.

## Battery care

- Pouch cells must not be squeezed, bent or pierced. The enclosure's cradle
  holds it on foam with clearance all round; never add screws or ribs that
  press on it.
- A fridge door is at room temperature, which suits the cell. Don't mount it
  on the side of an oven or near the fridge's warm vent at the bottom or back.
- LiPo cells charge between 0 °C and 45 °C.
- For storage, charge to about half and switch it off with the optional
  slide switch (SW4 in the [BOM](bom.md)), or unplug the battery.
