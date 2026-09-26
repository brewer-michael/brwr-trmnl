"""brwr-trmnl: merge bootloader, partition table, OTA data and app into one
image for flashing at offset 0 (web flasher, esptool write_flash 0x0).

Offsets come from the build itself (FLASH_EXTRA_IMAGES, ESP32_APP_OFFSET),
so they follow the partition table. The filesystem is formatted on first
boot, so it isn't included.
"""

import os
import subprocess

Import("env")  # noqa: F821


def merge(source, target, env):
    build_dir = env.subst("$BUILD_DIR")
    output = os.path.join(build_dir, "merged_firmware.bin")

    images = []
    for offset, path in env.get("FLASH_EXTRA_IMAGES", []):
        images += [env.subst(offset), env.subst(path)]
    images += [env.subst("$ESP32_APP_OFFSET"), os.path.join(build_dir, "firmware.bin")]

    esptool = os.path.join(env.PioPlatform().get_package_dir("tool-esptoolpy"), "esptool.py")
    subprocess.run(
        [
            env.subst("$PYTHONEXE"), esptool,
            "--chip", "esp32s3",
            "merge_bin",
            "-o", output,
            "--flash_mode", "keep",
            "--flash_freq", "keep",
            "--flash_size", "8MB",
            *images,
        ],
        check=True,
    )
    print(f"Merged firmware (flash at 0x0): {output}")


env.AddPostAction("$BUILD_DIR/${PROGNAME}.bin", merge)  # noqa: F821
