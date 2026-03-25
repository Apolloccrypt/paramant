# PARAMANT
### Post-Quantum Public Encrypted Ledger

> **Openbaar. Quantum-safe. Onverwoestbaar.**  
> Veiliger dan Signal. Geen account. Geen server die meekijkt.

[![Live Demo](https://img.shields.io/badge/🔐_Live_Demo-paramant--e27c.vercel.app-14b8a6?style=for-the-badge)](https://paramant-e27c.vercel.app)
[![Relay](https://img.shields.io/badge/📡_Relay-onrender.com-0d9488?style=for-the-badge)](https://paramant-relay.onrender.com/health)
[![NIST FIPS 203](https://img.shields.io/badge/NIST-FIPS_203_ML--KEM--768-334155?style=for-the-badge)](#algoritmen)

---

## Wat is PARAMANT?

PARAMANT is een browser-native post-quantum messenger zonder server, account of metadata. Berichten worden versleuteld met een hybride **ML-KEM-768 + ECDH P-256** schema en **AES-256-GCM** met forward secrecy.

Een optionele relay fungeert als **openbaar encrypted ledger** — vergelijkbaar met blockchain: bewijs van communicatie, zonder inhoud, identiteit of relaties bloot te geven.

```
Jij                    Relay (optioneel)              Amice
 │                           │                           │
 │──── versleuteld pakket ──►│──── versleuteld pakket ──►│
 │                           │                           │
 │         Relay ziet:       │         Jij ziet:         │
 │   hash(16) · bytes · ts   │     leesbare tekst        │
```

---

## Vergelijking

| Eigenschap | WhatsApp | Signal | Telegram | **PARAMANT** |
|---|:---:|:---:|:---:|:---:|
| Account nodig? | ✗ Ja | ✗ Ja | ✗ Ja | **✓ Nee** |
| Server leest mee? | ✗ Meta | ~ Minimaal | ✗ Cloud | **✓ Nooit** |
| Post-quantum? | ✗ | ~ PQXDH | ✗ | **✓ FIPS 203** |
| Metadata bewaard? | ✗ Volledig | ~ Minimaal | ✗ Ja | **✓ Nul** |
| Offline werking? | ✗ | ✗ | ✗ | **✓ Ja** |
| App installeren? | ✗ Verplicht | ✗ Verplicht | ✗ Verplicht | **✓ Browser** |

---

## Cryptografisch Protocol

### Sleuteluitwisseling

Elke identiteit bestaat uit een **ECDH P-256** + **ML-KEM-768** keypair, lokaal gegenereerd in de browser. Gecombineerd via HKDF-SHA-256:

```
master_secret = HKDF-SHA-256(ECDH_shared ‖ KEM_shared, "paramant-master-v1")
```

Het master secret wordt direct na gebruik gewist.

### Ratchet & Forward Secrecy

Symmetrische KDF-chain: elke message key wordt afgeleid en na gebruik gewist. Elke **8 berichten** volgt een nieuwe ML-KEM encapsulatie (KEM-injectie) voor post-compromise security:

```
MK[n]    = HKDF(CK[n], "msg")
CK[n+1]  = HKDF(CK[n], "chain")                        — normaal
CK[n+1]  = HKDF(CK[n] ‖ KEM_shared, "kem-ratchet")    — elke 8 berichten
```

### Versleuteling

| Parameter | Waarde |
|---|---|
| Algoritme | AES-256-GCM |
| Nonce | 96-bit random |
| AAD | `paramant:{seq}:{type}` |
| Padding | PKCS7 (32-byte blokken) |
| Replay-bescherming | IndexedDB nonce-log |

### Hash-derived Identity

```
SHA-256(pubKey) → 32 bytes
  Bytes  0–11  →  Mandelbrot fractal avatar
                   (regio, offset, zoom, iteraties, kleur, helderheid, palet-mix)
  Bytes 16–27  →  Deterministische gebruikersnaam
                   (5 stijlvarianten × adj × noun × sym × num)
```

> Dezelfde sleutel geeft **altijd** dezelfde naam, avatar en QR-code — mathematisch uniek per sleutel.

---

## Relay — Publiek Encrypted Ledger

```
Relay ziet WEL:    chatHash-prefix (16 chars) · bytes · tijdstempel
Relay ziet NOOIT:  plaintext · sleutels · namen · IP-adressen
```

### API

| Endpoint | Beschrijving |
|---|---|
| `GET /health` | Health check |
| `GET /api/stats` | Pakketten · chats · online |
| `GET /api/ledger` | Laatste 50 entries |
| `GET /api/ledger/:hash` | Entries per chat-hash |
| `WS /` | Real-time relay |

---

## Dreigingsmodel

| Aanval | Risico | Mitigatie |
|---|---|---|
| Passief afluisteren | **Geen** | E2E AES-256-GCM |
| Relay-compromis | **Laag** | Alleen hash+bytes zichtbaar |
| MITM bij verbinden | **Laag** | Safety numbers (SHA-256) |
| Replay-aanval | **Geen** | IndexedDB nonce-log |
| Quantum-computer | **Geen** | ML-KEM-768 (NIST FIPS 203) |
| Harvest now/decrypt later | **Geen** | PQ-hybrid vanaf handshake |
| XSS injectie | **Gefixed** | `textContent` · `validNick()` · `isHex()` |
| DDoS relay | **Beperkt** | 50 msg/10s rate-limit per verbinding |
| Pakket-injectie | **Geen** | AES-GCM authentication tag vereist |
| Metadata-analyse | **Minimaal** | Hash (16 chars) + grootte + tijd |

---

## Deployment

### Client op Vercel (gratis)

```bash
# 1. Voeg toe aan index.html voor </head>:
# <script>window._PARAMANT_RELAY='wss://paramant-relay.onrender.com'</script>

# 2. Deploy
vercel --prod
```

### Relay op Render.com (gratis)

```bash
# Push relay.js + package.json naar GitHub
# Render → New Web Service → connect repo → npm start
```

### Via Tor (optioneel, maximale privacy)

```bash
# torrc:
HiddenServiceDir /var/lib/tor/paramant/
HiddenServicePort 80 127.0.0.1:8080

# Of met Docker:
docker-compose -f docker-compose.tor.yml up -d

# Client instellen:
window._PARAMANT_RELAY_ONION = 'ws://jouw-adres.onion';
```

---

## Algoritmen {#algoritmen}

| Algoritme | Standaard | Doel |
|---|---|---|
| ML-KEM-768 | NIST FIPS 203 | Post-quantum key encapsulation |
| ECDH P-256 | NIST SP 800-186 | Klassieke sleuteluitwisseling |
| AES-256-GCM | NIST SP 800-38D | Symmetrische versleuteling |
| HKDF-SHA-256 | RFC 5869 | Key derivation |
| SHA-256 | FIPS 180-4 | Hash (identity, safety numbers) |

---

## Snel starten

```
1. Open https://paramant-e27c.vercel.app
2. Klik "Start gratis"
3. Klik "Offline" → wacht tot "🟢 Relay actief" (max 30 sec)
4. Klik "📋 Kopieer adres" → stuur naar je amice
5. Klik "+" → plak adres amice → "Verbinden"
6. Bel amice, vergelijk "🔢 Veiligheidsnummers" → veilig bevestigd
7. Appen maar 🔐
```

---

## Repository

```
paramant/
├── index.html      ← Volledige app (HTML + CSS + JS, één bestand, ~105KB)
└── vercel.json     ← Security headers (CSP, X-Frame-Options, etc.)

paramant-relay/
├── relay.js        ← WebSocket relay server (Node.js, alleen ws dependency)
└── package.json    ← { "start": "node relay.js" }
```

---

<div align="center">

**PARAMANT** · Post-Quantum Public Encrypted Ledger · Whitepaper v1.0 · Maart 2026

`ML-KEM-768 + ECDH P-256 + AES-256-GCM` · NIST FIPS 203

Geen account. Geen server. Geen compromis.

[🔐 Live Demo](https://paramant-e27c.vercel.app) · [📡 Relay](https://paramant-relay.onrender.com/health) · [github.com/Apolloccrypt](https://github.com/Apolloccrypt)

</div>
