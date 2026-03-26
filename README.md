# PARAMANT
### Post-Quantum Versleutelde Messenger

> **Niemand kan meelezen. Letterlijk niemand.**  
> Geen account. Geen telefoonnummer. Geen server die leest. Gemaakt in Nederland.

[![Live](https://img.shields.io/badge/LIVE-paramant.app-00ff9d?style=flat-square&labelColor=0c0e10)](https://paramant.app)
[![Relay](https://img.shields.io/badge/RELAY-relay.paramant.app-4a7c59?style=flat-square&labelColor=0c0e10)](https://relay.paramant.app/health)
[![ML-KEM-768](https://img.shields.io/badge/ML--KEM--768-NIST_FIPS_203-2a2d35?style=flat-square&labelColor=0c0e10)](#versleuteling)
[![Native app](https://img.shields.io/badge/Native_app-v0.2.0-2a2d35?style=flat-square&labelColor=0c0e10)](https://github.com/Apolloccrypt/paramant-app/releases)

---

## Wat is PARAMANT?

PARAMANT is een onafhankelijke open-source messenger met post-quantum hybride end-to-end encryptie. Geen bedrijf, geen investeerders, geen advertenties. Gebouwd door één persoon in Nederland.

Berichten zijn fundamenteel onleesbaar voor iedereen behalve de ontvanger — ook voor de relay. De relay ziet uitsluitend een hash-prefix, pakketgrootte en tijdstempel. Nooit de inhoud.

**Twee versies:**
- **Browser** — open `paramant.app`, geen installatie, geen account
- **Native app** — Rust + Tauri 2, sleutels gewist via `drop()`, geen browser-extensies

---

## Versleuteling

| Algoritme | Standaard | Rol |
|---|---|---|
| ML-KEM-768 | NIST FIPS 203 (2024) | Post-quantum Key Encapsulation |
| ECDH P-256 | NIST SP 800-186 | Klassieke Diffie-Hellman |
| AES-256-GCM | NIST SP 800-38D | Versleuteling + authenticatie |
| HKDF-SHA-256 | RFC 5869 | Key derivation |
| SHA-256 | FIPS 180-4 | Hashing |

```
master = HKDF-SHA-256(ECDH_shared ‖ KEM_shared, "paramant-master-v1")

MK[n]   = HKDF(CK[n], "msg")
CK[n+1] = HKDF(CK[n], "chain")                      // elk bericht
CK[n+1] = HKDF(CK[n] ‖ KEM_shared, "kem-ratchet")  // elke 8 berichten
```

---

## Privacy

```
Relay ziet WEL:    hash-prefix (16 hex) · pakketgrootte · tijdstempel
Relay ziet NOOIT:  inhoud · sleutels · namen · IP-adressen · wie met wie
```

- Relay bewaart metadata **maximaal 5 minuten** — daarna auto-delete
- Geen cookies, geen trackers, geen analytics
- IndexedDB lokaal: sleutelpaar + nonce-registry (nooit naar server)
- Tor hidden service beschikbaar
- 2 externe CDN scripts bij laden (TailwindCSS + QRCode.js via Cloudflare CDN)

Volledig beleid: [paramant.app/privacy.html](https://paramant.app/privacy.html)

---

## Vergelijking

| | WhatsApp | Signal | Telegram | PARAMANT |
|---|:---:|:---:|:---:|:---:|
| Account nodig | ✗ tel.nr | ✗ tel.nr | ✗ tel.nr | **geen** |
| Post-quantum | ✗ | ~ PQXDH | ✗ | **ML-KEM-768** |
| Metadata bewaard | ✗ volledig | ~ minimaal | ✗ ja | **hash+grootte · 5 min** |
| Installatie nodig | ✗ | ✗ | ✗ | **browser** |
| Bedrijf erachter | Meta | Signal Foundation | Telegram | **niemand** |

---

## Security scan v0.2.0

```
[OK] PIE + Full RELRO + Stack canary
[OK] Geen gets/strcpy/strcat
[OK] ML-KEM-768 AVX2 native assembly in binary
[OK] Zeroize — EcdhShared + SharedSecret gewist via drop()
[OK] Geen trackers, geen hardcoded secrets
[OK] .deb GPG gesigneerd (6EF8E5AC...29A49B97)
[OK] APK v2+v3 scheme gesigneerd
[!]  Geen formele cryptografische audit (side-channel timing)
```

---

## Snel starten

```
1. Ga naar https://paramant.app
2. Klik ">> OPEN APP // GRATIS"
3. Wacht op RELAY_ONLINE
4. Kopieer adres → stuur naar je amice
5. Klik + → plak adres → Verbinden
6. Vergelijk veiligheidsnummers via telefoon
7. Appen
```

---

## Native app installatie

```bash
sudo dpkg -i PARAMANT_0.2.0_amd64.deb        # Ubuntu/Debian
sudo rpm -i PARAMANT-0.2.0-1.x86_64.rpm      # Fedora/RHEL
chmod +x paramant_0.2.0_amd64.AppImage       # AppImage
```

Downloads: [github.com/Apolloccrypt/paramant-app/releases](https://github.com/Apolloccrypt/paramant-app/releases)

---

## Deployment

```bash
# Web (Cloudflare Pages — auto via git push)
git push origin main

# Relay (Hetzner Neurenberg DE — EU/GDPR)
scp relay.js root@116.203.86.81:/home/paramant/relay/
ssh root@116.203.86.81 "systemctl restart paramant-relay"
```

**Tor hidden services:**
```
App:   csnmdkpqikrf6abad7ej4mqsftiyh2z2fg3nzpf4x4zbnh2ulbmq5mid.onion
Relay: 6hz46anxzpwvzgzih23fm6p3lgx3e6p453um6wplw2vkjnpzyj747fqd.onion
```

---

## Repos

| Repo | Inhoud |
|---|---|
| [paramant](https://github.com/Apolloccrypt/paramant) | Web app (dit repo) — Cloudflare Pages |
| [paramant-app](https://github.com/Apolloccrypt/paramant-app) | Native app — Tauri 2 + Rust |
| [paramant-core](https://github.com/Apolloccrypt/paramant-core) | Rust crypto library |

---

## Bekende beperkingen

- **Browser-extensies** kunnen DOM onderscheppen vóór versleuteling → gebruik incognito of native app
- **JS geheugen** — V8 kan sleutels kopiëren vóór `fill(0)` → native app biedt sterkere garantie
- **Code signing** Windows is self-signed (SmartScreen waarschuwing), Android via eigen keystore
- **Geen formele audit** — side-channel timing pqcrypto-kyber niet formeel geauditeerd

---

<div align="center">

**PARAMANT** · Post-Quantum Messenger · Gemaakt in Nederland  
`ML-KEM-768 + ECDH P-256 + AES-256-GCM · NIST FIPS 203`  
Geen account. Geen bedrijf. Geen compromis.

[paramant.app](https://paramant.app) · [Download](https://paramant.app/download.html) · [Privacy](https://paramant.app/privacy.html)

</div>
