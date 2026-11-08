#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Packages and signs the Nowy Start APK for Bemi Cognita Tab 5 (Android 8.1 API 27):
- Uses Ksiazki_Kanon.apk as base (proven working on Bemi Cognita Tab 5)
- Changes package name to net.mikespub.nowystart (22 bytes, exact length match, unique)
- Patches classes.dex bytecode and recalculates SHA1 and Adler32 checksums
- Updates app label in resources.arsc to 'Nowy Start' (10 bytes)
- Configures assets/settings.json for DOM storage, JS, database and file access
- Injects NowyStart.html into assets/web/index.html, assets/local/index.html, assets/demo/index.html
- Signs with OpenSSL PKCS#7 v1 signature (-nosmimecap) compatible with Android 8.1
- Produces /home/protectoru/Pulpit/NowyStart.apk and /home/protectoru/Pulpit/NowyStart/NowyStart.apk
"""

import os
import zipfile
import hashlib
import zlib
import struct
import subprocess
import shutil
import base64
import json

BASE_APK = "/home/protectoru/Pulpit/Ksiazki_Kanon.apk"
HTML_SOURCE = "/home/protectoru/Pulpit/NowyStart.html"
OUT_APK = "/home/protectoru/Pulpit/NowyStart/NowyStart.apk"
DESKTOP_COPY = "/home/protectoru/Pulpit/NowyStart.apk"

def build_nowystart_apk():
    print(f"Reading base APK from: {BASE_APK}")
    if not os.path.exists(BASE_APK):
        raise FileNotFoundError(f"Base APK not found at {BASE_APK}")
    if not os.path.exists(HTML_SOURCE):
        raise FileNotFoundError(f"HTML source not found at {HTML_SOURCE}")

    with open(HTML_SOURCE, "rb") as f:
        app_html = f.read()

    modified_files = {}

    with zipfile.ZipFile(BASE_APK, "r") as zin:
        for item in zin.infolist():
            filename = item.filename
            if filename.startswith("META-INF/"):
                continue  # skip old signature

            data = zin.read(filename)

            if filename == "AndroidManifest.xml":
                old_pkg = "net.mikespub.mywebbook".encode("utf-16le")
                new_pkg = "net.mikespub.nowystart".encode("utf-16le")
                assert len(old_pkg) == len(new_pkg), "Package length mismatch!"
                assert old_pkg in data, "Old package string not found in AndroidManifest!"
                data = data.replace(old_pkg, new_pkg)
                print(f"[✓] Patched {filename}: replaced package name with net.mikespub.nowystart")

            elif filename == "classes.dex":
                assert b"mywebbook" in data, "Old string 'mywebbook' not found in classes.dex!"
                data = data.replace(b"mywebbook", b"nowystart")
                dex = bytearray(data)
                # Recalculate SHA1 (bytes 12..32) over bytes 32..EOF
                dex[12:32] = hashlib.sha1(dex[32:]).digest()
                # Recalculate Adler32 (bytes 8..12) over bytes 12..EOF
                dex[8:12] = struct.pack("<I", zlib.adler32(dex[12:]) & 0xffffffff)
                data = bytes(dex)
                print(f"[✓] Patched {filename}: updated DEX strings and recalculated SHA1 & Adler32 checksums")

            elif filename == "resources.arsc":
                # 'TopKsiazek' is 10 bytes, 'Nowy Start' is 10 bytes
                assert b"TopKsiazek" in data, "TopKsiazek not found in resources.arsc!"
                data = data.replace(b"TopKsiazek", b"Nowy Start")
                data = data.replace(b"/mywebbook/", b"/nowystart/")
                data = data.replace(b"\t\tmywebbook\x00", b"\t\tnowystart\x00")
                print(f"[✓] Patched {filename}: updated app title to 'Nowy Start'")

            elif filename in ["assets/web/index.html", "assets/local/index.html", "assets/demo/index.html"]:
                data = app_html
                print(f"[✓] Replaced {filename} with Nowy Start HTML ({len(data)} bytes)")

            elif filename == "assets/settings.json":
                try:
                    sj = json.loads(data.decode("utf-8"))
                    sj["console_log"] = True
                    sj["remote_debug"] = True
                    sj["web_settings"]["JavaScriptEnabled"] = True
                    sj["web_settings"]["DomStorageEnabled"] = True
                    sj["web_settings"]["AllowFileAccess"] = True
                    sj["web_settings"]["DatabaseEnabled"] = True
                    data = json.dumps(sj, indent=2).encode("utf-8")
                    print("[✓] Updated assets/settings.json for JavaScript & DOM storage")
                except Exception as ex:
                    print("[!] Settings json error:", ex)

            modified_files[filename] = data

    # Key & Certificate Generation
    work_dir = "/tmp/nowystart_sign_work"
    if os.path.exists(work_dir):
        shutil.rmtree(work_dir)
    os.makedirs(work_dir, exist_ok=True)

    key_file = os.path.join(work_dir, "key.pem")
    cert_file = os.path.join(work_dir, "cert.pem")

    print("[*] Generating 2048-bit RSA key and self-signed certificate...")
    subprocess.run([
        "openssl", "req", "-x509", "-newkey", "rsa:2048",
        "-keyout", key_file, "-out", cert_file,
        "-days", "10000", "-nodes",
        "-subj", "/C=PL/O=NowyStart/CN=NowyStart"
    ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    # Compute MANIFEST.MF
    manifest_entries = []
    for name, data in modified_files.items():
        d_file = base64.b64encode(hashlib.sha1(data).digest()).decode("ascii")
        entry_mf = f"Name: {name}\r\nSHA1-Digest: {d_file}\r\n\r\n"
        manifest_entries.append((name, entry_mf))

    mf_content = "Manifest-Version: 1.0\r\nCreated-By: 1.0 (Android)\r\n\r\n" + "".join(e[1] for e in manifest_entries)
    mf_bytes = mf_content.encode("utf-8")
    mf_digest = base64.b64encode(hashlib.sha1(mf_bytes).digest()).decode("ascii")

    # Compute CERT.SF
    sf_content = f"Signature-Version: 1.0\r\nCreated-By: 1.0 (Android)\r\nSHA1-Digest-Manifest: {mf_digest}\r\n\r\n"
    for name, entry_mf in manifest_entries:
        entry_d = base64.b64encode(hashlib.sha1(entry_mf.encode("utf-8")).digest()).decode("ascii")
        sf_content += f"Name: {name}\r\nSHA1-Digest: {entry_d}\r\n\r\n"

    sf_bytes = sf_content.encode("utf-8")
    sf_path = os.path.join(work_dir, "CERT.SF")
    rsa_path = os.path.join(work_dir, "CERT.RSA")
    with open(sf_path, "wb") as f:
        f.write(sf_bytes)

    # Sign with OpenSSL
    print("[*] Signing CERT.SF with OpenSSL PKCS#7 v1 signature...")
    subprocess.run([
        "openssl", "smime", "-sign", "-inkey", key_file, "-signer", cert_file,
        "-in", sf_path, "-out", rsa_path, "-outform", "DER",
        "-nodetach", "-nosmimecap"
    ], check=True)

    with open(rsa_path, "rb") as f:
        rsa_bytes = f.read()

    # Package APK
    print(f"[*] Packaging final APK to {OUT_APK}...")
    os.makedirs(os.path.dirname(OUT_APK), exist_ok=True)
    with zipfile.ZipFile(OUT_APK, "w", compression=zipfile.ZIP_DEFLATED) as zout:
        zout.writestr("META-INF/MANIFEST.MF", mf_bytes)
        zout.writestr("META-INF/CERT.SF", sf_bytes)
        zout.writestr("META-INF/CERT.RSA", rsa_bytes)
        for name, data in modified_files.items():
            zout.writestr(name, data)

    shutil.copy2(OUT_APK, DESKTOP_COPY)
    print(f"[✓] Successfully built and signed: {OUT_APK} ({os.path.getsize(OUT_APK):,} bytes)")
    print(f"[✓] Copied to desktop: {DESKTOP_COPY}")

    # Cleanup
    shutil.rmtree(work_dir)

if __name__ == "__main__":
    build_nowystart_apk()
