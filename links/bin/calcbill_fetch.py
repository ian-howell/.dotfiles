#!/usr/bin/env python3

"""
Playwright-based automation for fetching AT&T bill text.

Credential storage: ~/.config/att/.env (ATT_USER, ATT_PASS)

On first run, prompts for credentials and stores them.
Always opens a headed browser -- AT&T uses Arkose Labs CAPTCHA
that must be solved interactively, plus 2FA may be required.
"""

import os
import re
import shutil
import stat
import sys
import tempfile
import time
from datetime import datetime
from getpass import getpass
from pathlib import Path

from playwright.sync_api import sync_playwright, TimeoutError as PwTimeout
from playwright_stealth import Stealth

ATT_CONFIG_DIR = Path.home() / ".config" / "att"
ENV_FILE = ATT_CONFIG_DIR / ".env"

ATT_LOGIN_URL = "https://www.att.com/acctmgmt/login"
ATT_OVERVIEW_URL = "https://www.att.com/acctmgmt/overview"
ATT_BILLING_SPA_PATH = "/acctmgmt/billing/mybillingcenter"


# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------


def _log(msg):
    """Print a timestamped log message to stderr."""
    ts = datetime.now().strftime("%H:%M:%S")
    print(f"[{ts}] {msg}", file=sys.stderr, flush=True)


# ---------------------------------------------------------------------------
# Credential management
# ---------------------------------------------------------------------------


def _parse_env_file(path):
    """Parse a simple KEY=VALUE .env file. No quotes handling needed."""
    env = {}
    if not path.exists():
        return env
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if "=" in line:
                key, _, value = line.partition("=")
                env[key.strip()] = value.strip()
    return env


def _write_env_file(path, env):
    """Write a KEY=VALUE .env file with restrictive permissions."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w") as f:
        for key, value in env.items():
            f.write(f"{key}={value}\n")
    os.chmod(path, stat.S_IRUSR | stat.S_IWUSR)  # 600


def _get_credentials():
    """Load credentials from .env file, prompting on first run."""
    env = _parse_env_file(ENV_FILE)
    user = env.get("ATT_USER", "")
    password = env.get("ATT_PASS", "")

    if user and password:
        _log(f"Loaded credentials for {user}")
        return user, password

    print(f"No credentials found at {ENV_FILE}")
    print("Enter your AT&T login credentials (will be saved for future use):\n")
    user = input("  AT&T username (email/phone): ").strip()
    password = getpass("  AT&T password: ").strip()

    if not user or not password:
        print("Error: username and password are required.", file=sys.stderr)
        sys.exit(1)

    _write_env_file(ENV_FILE, {"ATT_USER": user, "ATT_PASS": password})
    print(f"\nCredentials saved to {ENV_FILE} (chmod 600)\n")
    return user, password


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _dismiss_smart_banner(page):
    """Dismiss the AT&T smart-app banner modal if it appears.

    AT&T shows a modal with id="cancelModalXBtn" on many pages.
    It blocks interaction with everything underneath.
    """
    try:
        btn = page.locator("button#cancelModalXBtn")
        btn.wait_for(state="visible", timeout=3000)
        btn.click()
        _log("Dismissed smart-app banner modal")
        page.wait_for_timeout(500)
    except PwTimeout:
        pass
    except Exception as e:
        _log(f"Smart banner dismiss failed (non-fatal): {e}")


# ---------------------------------------------------------------------------
# Browser automation -- login
# ---------------------------------------------------------------------------


def _needs_login(page):
    """Return True if the current page is a login/signin page."""
    url = page.url.lower()
    is_login = "login" in url or "signin.att.com" in url
    _log(f"URL: {page.url}  needs_login={is_login}")
    return is_login


def _do_login(page, user, password):
    """Perform the AT&T login flow with real selectors.

    AT&T login is a multi-step form on signin.att.com:
      1. Dismiss smart-app banner modal (button#cancelModalXBtn)
      2. Enter user ID (input#userID) and click Continue (button#continueFromUserLogin)
      3. Enter password (input#password) and click Sign In (button#signin)

    The sign-in button triggers an Arkose Labs CAPTCHA challenge.
    """
    _log(f"Navigating to {ATT_LOGIN_URL}")
    page.goto(ATT_LOGIN_URL, wait_until="domcontentloaded")
    try:
        page.wait_for_load_state("networkidle", timeout=15000)
    except PwTimeout:
        _log("networkidle timed out on login page (continuing)")

    # Redirected past login?  Session cookie still valid.
    if not _needs_login(page):
        _log("Redirected past login -- session still valid")
        return True

    _dismiss_smart_banner(page)

    # ---- Step 1: User ID ----
    # AT&T may remember the email from a previous session and skip
    # straight to the password step, leaving input#userID as type="hidden".
    uid = page.locator("input#userID")
    try:
        uid.wait_for(state="visible", timeout=5000)
        _log("Entering user ID")
        uid.fill(user)

        cont = page.locator("button#continueFromUserLogin")
        cont.wait_for(state="visible", timeout=5000)
        cont.click()
    except PwTimeout:
        _log("userID field hidden (AT&T remembered email), skipping to password")

    # Wait for password field to appear (indicates step 2 loaded)
    _log("Waiting for password step...")
    pw = page.locator("input#password")
    pw.wait_for(state="visible", timeout=15000)

    _dismiss_smart_banner(page)

    # ---- Step 2: Password ----
    _log("Entering password")
    pw.fill(password)

    # DO NOT check "Keep me signed in" (#keepMeIn) -- it triggers a
    # confirmation modal that blocks the signin button.

    signin = page.locator("button#signin")
    signin.wait_for(state="visible", timeout=5000)
    signin.click()
    _log("Clicked Sign In -- waiting for Arkose / navigation")

    # ---- Arkose CAPTCHA / post-login wait ----
    # Arkose may show an invisible/visible challenge. The user sees the
    # challenge in the browser and solves it manually.
    #
    # We poll until we leave signin.att.com OR hit a 2FA page.
    _log("Waiting for login to complete (solve CAPTCHA if prompted)...")

    deadline = time.monotonic() + 120  # 2 minute timeout
    while time.monotonic() < deadline:
        url = page.url.lower()

        # Successfully left the login domain
        if "signin.att.com" not in url and "login" not in url:
            _log(f"Login succeeded, now at: {page.url}")
            return True

        # Still on login domain -- check for 2FA
        if _is_2fa_page(page):
            _handle_2fa(page)
            return True

        page.wait_for_timeout(1000)

    # If we're still here, login timed out
    _log("Login timed out after 2 minutes.")
    sys.exit(1)


def _is_2fa_page(page):
    """Detect if the current page is a 2FA/verification page."""
    try:
        text = page.text_content("body", timeout=2000) or ""
        indicators = [
            "verify your identity",
            "verification code",
            "one-time code",
            "temporary code",
            "security code",
            "enter the code",
            "we sent a code",
            "we texted you",
            "confirm your identity",
        ]
        text_lower = text.lower()
        for indicator in indicators:
            if indicator in text_lower:
                _log(f"2FA detected (matched: '{indicator}')")
                return True
    except Exception:
        pass
    return False


def _handle_2fa(page):
    """Handle 2FA by waiting for the user to complete it in the browser."""
    _log("=" * 50)
    _log("  2FA VERIFICATION REQUIRED")
    _log("=" * 50)
    _log("Complete the verification in the browser window.")
    _log("The script will continue automatically once you're through.")

    # Poll until we leave the 2FA page
    for i in range(120):  # 2 minutes
        time.sleep(1)
        if not _is_2fa_page(page):
            url = page.url.lower()
            if "signin.att.com" not in url and "login" not in url:
                _log("2FA complete")
                return
    _log("Timed out waiting for 2FA.")
    sys.exit(1)


# ---------------------------------------------------------------------------
# Browser automation -- billing
# ---------------------------------------------------------------------------


def _navigate_to_bill(page):
    """Navigate to the billing center via SPA navigation.

    Direct URL navigation to billing pages does NOT work -- AT&T silently
    redirects to the homepage. The correct approach:
      1. Load /acctmgmt/overview (account overview)
      2. Use JS window.location.href to navigate within the SPA
    """
    _log(f"Loading account overview at {ATT_OVERVIEW_URL}")

    page.goto(ATT_OVERVIEW_URL, wait_until="domcontentloaded")
    try:
        page.wait_for_load_state("networkidle", timeout=15000)
    except PwTimeout:
        _log("networkidle timed out on overview page (continuing)")

    _dismiss_smart_banner(page)
    page.wait_for_timeout(2000)

    # SPA-navigate to billing center
    _log(f"SPA-navigating to {ATT_BILLING_SPA_PATH}")
    page.evaluate(f'() => window.location.href = "{ATT_BILLING_SPA_PATH}"')

    try:
        page.wait_for_load_state("networkidle", timeout=20000)
    except PwTimeout:
        _log("networkidle timed out on billing center (continuing)")

    _dismiss_smart_banner(page)

    # Wait for billing content to render
    _log("Waiting for bill activity content...")
    try:
        page.locator('[data-testid="bill_activity_accordion_title_0"]').wait_for(
            state="visible", timeout=15000
        )
        _log("Bill activity accordion found")
    except PwTimeout:
        _log("WARNING: bill activity accordion not found, page may not have loaded")

    page.wait_for_timeout(2000)
    _log(f"Billing center URL: {page.url}")


def _extract_bill_text(page):
    """Extract bill text from the billing center page.

    Uses the structured data-testid selectors on AT&T's billing page for
    reliable extraction. The billing center shows per-line charges in an
    accordion for each billing period:
      - billing-period-0 = current bill
      - billing-period-1 = previous bill
      - etc.

    The raw text of a bill section follows this format (which calcbill.py
    already knows how to parse):
        NAME LASTNAME
        314.306.1339
        $45.38
        ...
        Total
        $438.26

    If the current bill total is $0.00, falls back to the previous month's
    bill (billing-period-1).
    """
    # Try current bill first (period 0)
    text = _extract_bill_period(page, period=0)
    if text and not _bill_is_zero(text):
        return text

    _log("Current bill is $0.00 or empty -- trying previous month")

    # Expand previous bill accordion
    try:
        accordion = page.locator('[data-testid="bill_activity_accordion_title_1"]')
        accordion.wait_for(state="visible", timeout=5000)
        accordion.click()
        _log("Clicked previous bill accordion")
        page.wait_for_timeout(3000)
    except PwTimeout:
        _log("WARNING: previous bill accordion not found")
    except Exception as e:
        _log(f"WARNING: failed to expand previous bill accordion: {e}")

    text = _extract_bill_period(page, period=1)
    if text:
        return text

    # Final fallback: grab all body text
    _log("Falling back to full page text extraction")
    return page.evaluate("() => document.body.innerText")


def _extract_bill_period(page, period=0):
    """Extract bill text for a specific billing period.

    Looks for the bill accordion body for the given period and extracts
    its inner text. Falls back to scanning for data-testid line-charge
    elements if the accordion body selector isn't found.
    """
    # Try the accordion body first -- contains all line items
    body_sel = f'[data-testid="bill_activity_accordion_body_{period}"]'
    try:
        body = page.locator(body_sel)
        body.wait_for(state="visible", timeout=5000)
        text = body.inner_text()
        lines = text.strip().splitlines()
        _log(f"Period {period} accordion body: {len(lines)} lines")
        if lines:
            return text
    except PwTimeout:
        _log(f"Accordion body {body_sel} not visible")
    except Exception as e:
        _log(f"Accordion body extraction failed: {e}")

    # Fallback: gather individual line-charge elements
    # Pattern: history-bill-details-Charges_LineNN-PHONE-billing-period-N
    # Each element's inner_text() may concatenate name+phone+amount into one
    # string like "MICKEY HOWELL314.306.1339$45.38". We split on the phone
    # number pattern to reconstruct the expected multi-line format.
    _log(f"Trying line-charge data-testid selectors for period {period}")
    line_els = page.locator(
        f'[data-testid*="billing-period-{period}"][data-testid*="Charges_Line"]'
    ).all()

    if not line_els:
        _log(f"No line-charge elements found for period {period}")
        return ""

    parts = []
    # Regex: split "NAME LASTNAME314.306.1339$45.38" into name, phone, amount
    line_re = re.compile(r"^(.+?)(\d{3}\.\d{3}\.\d{4})(\$[\d,.]+)$")
    for el in line_els:
        try:
            raw = el.inner_text().strip()
            m = line_re.match(raw)
            if m:
                # Reconstruct as separate lines for the parser
                parts.append(m.group(1).strip())
                parts.append(m.group(2))
                parts.append(m.group(3))
            else:
                # Already has line breaks or different format
                parts.append(raw)
        except Exception:
            continue

    if parts:
        text = "\n".join(parts)
        _log(f"Period {period} line-charge elements: {len(parts)} items")
        return text

    return ""


def _bill_is_zero(text):
    """Check if a bill's total is $0.00."""
    lines = text.strip().splitlines()
    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped == "Total" and i + 1 < len(lines):
            amount = lines[i + 1].strip()
            if amount == "$0.00":
                _log("Bill total is $0.00")
                return True
        # Also catch inline "Total $0.00"
        if stripped.startswith("Total") and "$0.00" in stripped:
            _log("Bill total is $0.00 (inline)")
            return True
    return False


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------


_stealth = Stealth(navigator_platform_override="Linux x86_64")


def fetch_bill_text():
    """Fetch the AT&T bill text via browser automation.

    Opens a headed Chrome browser, logs in (with CAPTCHA/2FA as needed),
    navigates to the billing center, and extracts the bill text.

    Returns:
        The text content of the bill detail section.
    """
    user, password = _get_credentials()

    tmpdir = tempfile.mkdtemp(prefix="calcbill-chrome-")
    _log(f"Using temp profile dir: {tmpdir}")
    try:
        with sync_playwright() as p:
            context = p.chromium.launch_persistent_context(
                user_data_dir=tmpdir,
                channel="chrome",
                headless=False,
                viewport={"width": 1280, "height": 900},
                args=["--disable-blink-features=AutomationControlled"],
            )

            page = context.pages[0] if context.pages else context.new_page()
            _stealth.apply_stealth_sync(page)

            try:
                _do_login(page, user, password)
                _navigate_to_bill(page)
                text = _extract_bill_text(page)
                _log("Bill text extracted successfully")
                return text

            except Exception as e:
                _log(f"Error during bill fetch: {e}")
                raise
            finally:
                context.close()
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)
        _log("Cleaned up temp profile dir")
