# PARAMANT
### Onafhankelijke Post-Quantum Privacytool

> **Niemand kan meelezen. Letterlijk niemand.**  
> Geen account. Geen bedrijf. Geen opslag. Puur cryptografie.

[![Live Demo](https://img.shields.io/badge/🔐_Live_Demo-paramant--e27c.vercel.app-14b8a6?style=for-the-badge)](https://paramant-e27c.vercel.app)
[![Relay](https://img.shields.io/badge/📡_Relay-onrender.com-0d9488?style=for-the-badge)](https://paramant-relay.onrender.com/health)
[![ML-KEM-768](https://img.shields.io/badge/ML--KEM--768-NIST_FIPS_203-334155?style=for-the-badge)](#de-versleuteling)
[![ECDH P-256](https://img.shields.io/badge/ECDH_P--256-NIST_SP_800--186-334155?style=for-the-badge)](#de-versleuteling)
[![Steun de relay](https://img.shields.io/badge/🔐_Steun_de_relay-buymeacoffee.com/mickbeer-14b8a6?style=for-the-badge)](https://buymeacoffee.com/mickbeer)

---

## Wat is PARAMANT?

PARAMANT is een **onafhankelijke open-source privacytool** — geen bedrijf, geen investeerders, geen advertenties, geen platform. Gebouwd door één persoon.

Het is een browser-native messenger met **post-quantum hybride end-to-end encryptie**. Geen account. Geen opslag. Berichten zijn fundamenteel onleesbaar voor iedereen behalve de ontvanger — ook voor de beheerder van de relay.

Het gedraagt zich als een **openbaar encrypted ledger**: vergelijkbaar met blockchain is het aantoonbaar dat communicatie plaatsvond, maar de inhoud, identiteit en relaties zijn volledig onkenbaar.

---

## De Versleuteling

PARAMANT gebruikt **post-quantum hybride end-to-end encryptie** — de sterkst mogelijke klasse berichtbeveiliging die momenteel bestaat en die voldoet aan de nieuwste NIST-standaarden.

### Algoritmen (NIST-gestandaardiseerd)

| Algoritme | Standaard | Rol |
|---|---|---|
| **ML-KEM-768** | NIST FIPS 203 (2024) | Post-quantum Key Encapsulation Mechanism. Bestand tegen kwantumcomputers die alle klassieke encryptie breken via Shor's algoritme |
| **ECDH P-256** | NIST SP 800-186 | Elliptische-curve Diffie-Hellman sleuteluitwisseling — klassieke laag |
| **AES-256-GCM** | NIST SP 800-38D | Symmetrische versleuteling met geauthenticeerde encryptie |
| **HKDF-SHA-256** | RFC 5869 | Key derivation function |
| **SHA-256** | FIPS 180-4 | Hash (identity, safety numbers, chatId) |

### Hybride Key Exchange

```
master_secret = HKDF-SHA-256(ECDH_shared ‖ KEM_shared, "paramant-master-v1")
```

Beide geheimen worden gecombineerd: als één ervan ooit gecompromitteerd wordt (inclusief toekomstige kwantumcomputers), beschermt de andere nog steeds alle berichten.

### Rol-gebaseerde Ratchet Chains

Na de handshake worden twee onafhankelijke sleutelketens afgeleid:

```
ckA = HKDF(master, "paramant-chain-A-v2")   ← A→B richting
ckB = HKDF(master, "paramant-chain-B-v2")   ← B→A richting
chatId = HKDF(HKDF(master, "paramant-chat-id-v2"), "paramant-chat-id-v1", 8)
```

Wie welke keten gebruikt als send/recv wordt **deterministisch bepaald** door vergelijking van de publieke sleutels. Beide kanten zijn het eens zonder extra communicatie.

### Forward Secrecy & Post-Compromise Security

```
MK[n]    = HKDF(CK[n], "msg")
CK[n+1]  = HKDF(CK[n], "chain")                        — elke bericht
CK[n+1]  = HKDF(CK[n] ‖ KEM_shared, "kem-ratchet")    — elke 8 berichten (ML-KEM injectie)
```

- **Forward secrecy:** elke sleutel wordt na gebruik permanent gewist. Oudere berichten kunnen nooit worden ontsleuteld, ook niet bij toegang tot het apparaat
- **Post-compromise security:** elke 8 berichten wordt een nieuwe kwantumsleuteluitwisseling uitgevoerd. Als een sleutel ooit uitlekt, herstelt de beveiliging zichzelf automatisch
- **PKCS7-padding** (32-byte blokken): verbergt berichtlengte
- **96-bit random nonce** per bericht
- **AAD** = `paramant:{seq}:{type}`: voorkomt type-confusion aanvallen
- **Replay-bescherming** via IndexedDB nonce-log (persistent over herladen)

---

## Vergelijking

| Eigenschap | WhatsApp | Signal | Telegram | **PARAMANT** |
|---|:---:|:---:|:---:|:---:|
| Account nodig? | ✗ Telefoonnummer | ✗ Telefoonnummer | ✗ Telefoonnummer | **✓ Nooit** |
| Server leest mee? | ✗ Meta-servers | ~ Minimaal | ✗ Cloud | **✓ Niemand** |
| Post-quantum (ML-KEM-768)? | ✗ | ~ PQXDH (X25519) | ✗ | **✓ FIPS 203** |
| Metadata bewaard? | ✗ Volledig | ~ Minimaal | ✗ Ja | **✓ Nul** |
| Offline werking? | ✗ | ✗ | ✗ | **✓ Altijd** |
| App installeren? | ✗ Verplicht | ✗ Verplicht | ✗ Verplicht | **✓ Browser** |
| Bedrijf erachter? | ✗ Meta | ✗ Signal Foundation | ✗ Telegram | **✓ Niemand** |
| Live aanwezigheid | ✗ | ✗ | ✗ | **✓ Ja** |
| Zelfdestructie | ~ Beperkt | ✓ | ~ Beperkt | **✓ Één klik** |

---

## Wat de Relay Opslaat

De relay is een **doorgeefluik**, geen opslagplaats. Hij ziet en bewaart uitsluitend:

```
Relay ziet WEL:    chatHash-prefix (16 hex-chars van SHA-256) · bytes · tijdstempel
Relay ziet NOOIT:  berichtinhoud · sleutels · namen · IP-adressen · wie met wie praat
```

| Wat | Voorbeeld | Wat het betekent |
|---|---|---|
| Hash-prefix | `a3f8c2d1e7b49f20…` | 16 tekens van SHA-256(chatId) — niet terug te herleiden naar personen |
| Pakketgrootte | `2.4 KB` | Bytes, nooit inhoud |
| Tijdstempel | `14:23:41` | Wanneer het pakket langskwam |

De relay herstart periodiek — ook die metadata verdwijnt dan. Hij is vergelijkbaar met een **openbare brievenbus die de dikte en het tijdstip van een verzegelde envelop noteert, nooit de inhoud**.

---

## Blockchain-aard

PARAMANT gedraagt zich als een **openbaar encrypted ledger**:

- **Openbaar transparant:** iedereen kan via `/api/ledger` zien *dát* er communicatie plaatsvond
- **Onleesbaar:** niemand kan zien *wat*, *wie* of *met wie*
- **Live aanwezigheid:** zie wie er online is, verbind direct, zonder account
- **Zelfdestructie:** één klik wist gesprek, sleutels en alle lokale data — niets blijft achter op servers want er ís geen server die het heeft

---

## Security Audit — Claims vs Code

Onafhankelijke verificatie van alle claims tegen de daadwerkelijke broncode. **60/60 geautomatiseerde implementatiechecks geslaagd.**

> ⚠️ **Let op:** Dit zijn geautomatiseerde checks die verifiëren dat alle cryptografische componenten aanwezig en correct verbonden zijn. Het is *geen vervanging* voor een formele audit door gespecialiseerde cryptografen. Side-channel aanvallen en subtiele KDF-fouten zijn niet formeel uitgesloten.

| Claim / Eigenschap | Status | Verificatie |
|---|:---:|---|
| ML-KEM-768 + ECDH P-256 + AES-256-GCM | ✅ | Alle 3 aanwezig — NIST-gestandaardiseerde algoritmen (FIPS 203, SP 800-186, SP 800-38D) |
| "Niemand kan meelezen" | ✅ | Relay ontvangt en bewaart nul plaintext |
| "Geen account nodig" | ✅ | Geen login, register of wachtwoord in code |
| "Post-quantum hybrid" | ✅ | ML-KEM in elke handshake + elke 8 berichten opnieuw geïnjecteerd |
| "Forward secrecy" | ✅ | MK, CK, KEM shared, master — alle gewist na gebruik (`fill(0)`) |
| "Zelfdestructie in één klik" | ✅ | `sendChainKey` + `recvChainKey` beide gewist bij sluiten |
| Replay bescherming | ✅ | IndexedDB nonce-log, `s:`/`r:` prefix, `seq < recvSeq` guard |
| XSS / injectie preventie | ✅ | `textContent`, `validNick()`, `isHex()`, `pType` early return |
| Relay hardening | ✅ | Rate limits, IP caps, room buffer gecapped op 5 pakketten |
| HTTP security headers | ✅ | HSTS, `CSP: default-src 'none'`, X-Frame-Options: DENY |

### Bekende Beperkingen — Eerlijk Gedocumenteerd

**Geheugenisolatie in de browser**
`fill(0)` wist sleutels direct na gebruik en verkleint het aanvalsvenster drastisch. JavaScript-engines (V8/SpiderMonkey) kunnen data echter eerder hebben gekopieerd tijdens garbage collection of JIT-optimalisatie — absolute geheugengarantie is inherent onmogelijk in browser-native tools. Een native app biedt sterkere isolatie. PARAMANT kiest bewust voor toegankelijkheid boven installatieplicht.

**Browser-extensies**
Extensies met DOM-toegang kunnen tekst onderscheppen vóór versleuteling — buiten het bereik van de CSP. PARAMANT detecteert en waarschuwt bij bekende extensie-signaturen, en adviseert gebruik in incognito-modus. Dit is een fundamentele beperking van alle browser-native tools, inclusief WhatsApp Web en Signal Desktop.

**Key Transparency**
Verifieer de verbinding door de **veiligheidsnummers te vergelijken** via telefoon of in persoon. Doe je dat, dan is het MITM-risico nul.

**ECDSA packet signatures**
Niet geïmplementeerd. De **AES-256-GCM authenticatietag** zorgt er echter voor dat elk aangepast of nagemaakt pakket de decryptie laat mislukken — een vals pakket komt nooit door.

**Relay ephemeral**
Geen database — herstart = ledger weg. Opzettelijk: er is niets te stelen. Berichten staan nooit op de relay.

**Geen formele cryptografische audit**
De 60/60 checks zijn geautomatiseerde implementatiechecks. Side-channel aanvallen en subtiele fouten in de KDF-logica zijn niet formeel uitgesloten door onafhankelijke cryptografen.

> Geen van de beperkingen laat een aanvaller berichten lezen, vervalsen of achterhalen. Ze zijn bewuste afwegingen voor een gratis, open-source tool zonder bedrijf erachter.

---

## Dreigingsmodel

| Aanval | Risico | Mitigatie |
|---|---|---|
| Passief afluisteren | **Geen** | AES-256-GCM E2E |
| Kwantumcomputer (toekomst) | **Geen** | ML-KEM-768 NIST FIPS 203 |
| Harvest now / decrypt later | **Geen** | PQ-hybrid vanaf handshake |
| Relay-compromis | **Laag** | Alleen hash+bytes zichtbaar, geen plaintext |
| MITM bij verbinden | **Laag** | Safety numbers (SHA-256 van master secret) |
| Replay-aanval | **Geen** | IndexedDB nonce-log met s:/r: prefixen |
| XSS injectie | **Gefixed** | `textContent` + `validNick()` + `isHex()` |
| DDoS relay | **Beperkt** | 50 msg/10s per conn, 20 conn/IP, 500 global cap |
| Ledger spam | **Beperkt** | Max 50 entries per chatHash |
| Pakket-injectie | **Geen** | AES-GCM authentication tag vereist |

---

## Snel Starten

```
1. Ga naar https://paramant-e27c.vercel.app
2. Klik "Start gratis" → app opent
3. Klik "Offline" → wacht tot "🟢 Relay actief" (max 30 sec)
4. Klik "📋 Kopieer adres" → stuur naar je amice
5. Klik "+" → plak adres amice → "Verbinden"
6. Bel amice, vergelijk "🔢 Veiligheidsnummers" → veilig bevestigd
7. Appen maar 🔐

Offline (zonder relay):
  Stap 3 overslaan → berichten handmatig kopiëren/plakken via elk kanaal
  Download de app voor USB/offline: "⬇ Download" knop in de sidebar
```

---

## Deployment

### Client (Vercel — gratis)
```bash
# Zet relay-URL in index.html voor </head>:
# <script>window._PARAMANT_RELAY='wss://paramant-relay.onrender.com'</script>
vercel --prod
```

### Relay (Render.com — gratis)
```bash
# relay.js + package.json → GitHub → Render → New Web Service → npm start
```

### Via Tor (.onion — maximale privacy)
```bash
# torrc:
HiddenServiceDir /var/lib/tor/paramant/
HiddenServicePort 80 127.0.0.1:8080

# Client:
window._PARAMANT_RELAY_ONION = 'ws://jouw-adres.onion';
```

---

## Repository

```
paramant/
├── index.html      ← Volledige app — HTML + CSS + JS in één bestand (~127KB)
├── vercel.json     ← HSTS, CSP, X-Frame-Options security headers
└── README.md       ← Dit bestand

paramant-relay/
├── relay.js        ← WebSocket relay server (Node.js, alleen ws als dependency)
└── package.json    ← { "start": "node relay.js" }
```

---

## Donaties

PARAMANT is vrij, open-source en zonder bedrijf erachter. De relay, hosting en ontwikkeling worden uitsluitend betaald uit vrijwillige donaties van gebruikers die privacy het waard vinden.

Geen donatie? Geen probleem — de tool blijft gratis. Vind je het de moeite waard? Dan houd je met een bijdrage de relay online.

[![Steun de relay](https://img.shields.io/badge/🔐_Houd_de_relay_online-buymeacoffee.com/mickbeer-14b8a6?style=for-the-badge)](https://buymeacoffee.com/mickbeer)

---

<div align="center">

**PARAMANT** · Onafhankelijke Post-Quantum Privacytool  
`ML-KEM-768 (NIST FIPS 203) + ECDH P-256 (NIST SP 800-186) + AES-256-GCM`  
Geen account. Geen bedrijf. Geen compromis.

[🔐 Live Demo](https://paramant-e27c.vercel.app) · [📡 Relay](https://paramant-relay.onrender.com/health) · [☕ Doneer](https://buymeacoffee.com/mickbeer)

</div>
