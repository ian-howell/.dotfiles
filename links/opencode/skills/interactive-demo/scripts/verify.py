"""Smoke-test an interactive-demo page and capture a screenshot of every scene.

Usage: verify.py <url> [--out DIR] [--settle MS]

Checks: no page/console errors; every scene reachable by stepping forward; rapid forward/back
clicking settles on the right scene; every playground control can be exercised; playground
undo/redo/branching restores exact states; no horizontal
overflow at common viewport sizes; reduced-motion navigation works. Screenshots land in --out
(default /tmp/opencode/demo-verify) as scene-NN.png and playground.png. Look at them.

Needs a Python with Playwright and Chromium. If `playwright` is a uv tool, its interpreter is
"$(dirname "$(readlink -f "$(command -v playwright)")")/python".
"""
import argparse
import pathlib
import sys

from playwright.sync_api import sync_playwright

ap = argparse.ArgumentParser()
ap.add_argument("url")
ap.add_argument("--out", default="/tmp/opencode/demo-verify")
ap.add_argument("--settle", type=int, default=3600, help="ms to wait after each scene change")
args = ap.parse_args()
out = pathlib.Path(args.out)
out.mkdir(parents=True, exist_ok=True)
base = args.url.split("#")[0]
problems = []

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page(viewport={"width": 1440, "height": 900})
    page.on("pageerror", lambda e: problems.append(f"page error: {e}"))
    page.on("console", lambda m: m.type == "error" and problems.append(f"console error: {m.text}"))
    page.goto(base)
    page.wait_for_timeout(args.settle)
    if not page.evaluate("typeof window.demo === 'object'"):
        sys.exit("window.demo is missing: did Demo.story() run?")
    count = page.evaluate("demo.scenes.length")

    # Step forward through every scene the way a presenter would.
    for i in range(count):
        if i:
            page.keyboard.press("ArrowRight")
            page.wait_for_timeout(args.settle)
        idx = page.evaluate("demo.idx")
        if idx != i:
            problems.append(f"expected scene {i}, got {idx}")
        page.screenshot(path=str(out / f"scene-{i:02d}.png"))

    # Rapid clicking in both directions must settle cleanly.
    page.keyboard.press("Home")
    for _ in range(count):
        page.keyboard.press("ArrowRight")
        page.wait_for_timeout(150)
    page.wait_for_timeout(args.settle)
    if page.evaluate("demo.idx") != count - 1:
        problems.append("rapid forward navigation did not reach the last scene")
    for _ in range(count):
        page.keyboard.press("ArrowLeft")
        page.wait_for_timeout(120)
    page.wait_for_timeout(args.settle)
    if page.evaluate("demo.idx") != 0:
        problems.append("rapid back navigation did not reach the first scene")

    # Playground: press every enabled control a few times.
    if page.locator("#modePlay").is_visible():
        page.locator("#modePlay").click()
        page.wait_for_timeout(1500)
        for _ in range(3):
            for b in page.locator("#playDock button").all():
                if b.is_enabled():
                    b.click()
                    page.wait_for_timeout(700)
        page.wait_for_timeout(args.settle)
        page.screenshot(path=str(out / "playground.png"))

        # Undo / redo / branch: travelling must restore exact states and keep the timeline coherent.
        tl = page.evaluate("demo.timeline")
        if tl["pos"] >= 2:
            snaps = page.evaluate("demo.timeline.pos")
            here = page.evaluate("JSON.stringify(demo.state)")
            page.keyboard.press("z")
            page.keyboard.press("z")
            page.wait_for_timeout(400)
            if page.evaluate("demo.timeline.pos") != snaps - 2:
                problems.append("undo did not move back two steps")
            page.keyboard.press("Shift+Z")
            page.keyboard.press("Control+y")
            page.wait_for_timeout(400)
            if page.evaluate("JSON.stringify(demo.state)") != here:
                problems.append("redo did not restore the exact state")
            page.locator("#tape button").first.click()
            page.wait_for_timeout(400)
            enabled = [b for b in page.locator("#playDock button").all() if b.is_enabled()]
            if enabled:
                enabled[0].click()
                page.wait_for_timeout(400)
                if page.evaluate("demo.timeline.pos") != len(page.evaluate("demo.timeline.labels")) - 1:
                    problems.append("a new event after undo did not discard the undone branch")
            page.wait_for_timeout(args.settle)
        elif page.locator("#playDock button").count():
            problems.append("playground timeline did not record events")
        else:
            print("SKIP: history actions; this scaffold has no playground event controls")
        page.locator("#modeStory").click()

    # Scenarios replay their full path from the stable initial state.
    if page.locator("#modePlay").is_visible():
        page.locator("#modePlay").click()
        initial = page.evaluate("JSON.stringify(demo.initial())")
        for value in page.locator("#preset option").evaluate_all("os => os.map(o => o.value).filter(Boolean)"):
            page.locator("#preset").select_option(value)
            page.locator("#preset").evaluate("el => el.blur()")
            page.wait_for_timeout(200)
            tl = page.evaluate("demo.timeline")
            if tl["pos"] != len(tl["labels"]) - 1:
                problems.append(f"scenario {value} did not end at its final step")
            page.locator("#tape button").first.click()
            page.wait_for_timeout(200)
            if page.evaluate("JSON.stringify(demo.state)") != initial:
                problems.append(f"scenario {value} history does not start at the stable initial state")
        page.locator("#modeStory").click()

    # Layout at other sizes.
    has_play = page.locator("#modePlay").is_visible()
    if has_play:
        page.locator("#modePlay").click()
        # Keep enough entries to exercise horizontal scrolling and old-entry access.
        for _ in range(15):
            enabled = [b for b in page.locator("#playDock button").all() if b.is_enabled()]
            if enabled:
                enabled[0].click()
        if page.locator("#tape button").count() != len(page.evaluate("demo.timeline.labels")):
            problems.append("history entries were omitted instead of remaining scrollable")
    for w, h in [(1920, 1080), (1280, 720), (390, 844)]:
        page.set_viewport_size({"width": w, "height": h})
        page.wait_for_timeout(300)
        if not page.evaluate("document.documentElement.scrollWidth <= innerWidth"):
            problems.append(f"horizontal overflow at {w}x{h}")
        if has_play:
            actions = page.locator(".play-actions").bounding_box()
            row = page.locator(".history-row").bounding_box()
            if row["y"] < actions["y"] + actions["height"]:
                problems.append(f"timeline is not below the action controls at {w}x{h}")
            for name in ("#undo", "#redo"):
                box = page.locator(name).bounding_box()
                if box["x"] < 0 or box["x"] + box["width"] > w or box["y"] + box["height"] > h:
                    problems.append(f"{name} is clipped at {w}x{h}")
            stage = page.locator("#world").bounding_box()
            footer = page.locator("footer").bounding_box()
            if stage["y"] + stage["height"] > footer["y"] + 1:
                problems.append(f"stage overlaps the footer at {w}x{h}")
            page.screenshot(path=str(out / f"playground-{w}.png"))
    if has_play:
        page.locator("#tape button").first.click()
        if page.evaluate("demo.timeline.pos") != 0:
            problems.append("oldest history entry is not reachable")
        page.locator("#modeStory").click()

    # Reduced motion.
    page.set_viewport_size({"width": 1440, "height": 900})
    page.emulate_media(reduced_motion="reduce")
    for i in range(count):
        page.evaluate(f"demo.go({i})")
        page.wait_for_timeout(120)
    browser.close()

for line in problems:
    print("FAIL", line)
print(f"{'PASS' if not problems else 'FAIL'}: {count} scenes; screenshots in {out}")
sys.exit(1 if problems else 0)
