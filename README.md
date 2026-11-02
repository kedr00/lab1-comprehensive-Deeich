# Practical Work 9: PC Info and Audit Script

This repository contains the updated script `pc_info.bat` for collecting system information and analyzing installed software. The script generates a report (`pc_report.txt`) with recommendations for basic and excessive software.

## 1. Basic Software Categories and Rationale
For a standard office workplace, the following basic software categories were selected:
- **Office Suite** (Keywords: `Office`, `LibreOffice`, `OpenOffice`). Rationale: Essential for creating and editing text documents, spreadsheets, and presentations.
- **Web Browser** (Keywords: `Chrome`, `Firefox`, `Edge`). Rationale: Required for accessing web-based corporate tools and the internet. *Note: The script explicitly notes if only Edge is found, as it is a built-in system component, not a result of manual configuration.*
- **PDF Reader** (Keywords: `Acrobat`, `Foxit`, `SumatraPDF`). Rationale: Necessary for viewing documentation and email attachments.
- **Archiver** (Keywords: `7-Zip`, `WinRAR`, `WinZip`). Rationale: Required for unpacking compressed files received via email or downloaded.
- **Antivirus** (Keywords: `Defender`, `Kaspersky`, `ESET`, `Dr.Web`). Rationale: Critical for endpoint security and data protection.

## 2. Excessive Software Indicators (For Review)
Software that does not belong to basic office tasks is grouped into four categories to provide structured recommendations:
- **Gaming Software:** `Steam`, `Epic`, `GOG`, `Origin`, `Ubisoft`, `Battle.net`, `Riot`, and standalone words `game`, `gaming`. (Note: Regex boundaries `\< \>` are used to prevent false positives like matching "engine").
- **Torrent Clients:** `torrent`, `uTorrent`, `BitTorrent`, `qBittorrent`, `Vuze`. These create network load and are potential security risks.
- **Messengers:** `Discord`, `Telegram`, `WhatsApp`, `Viber`, `Skype`. The script flags these for review, noting they might be used as corporate tools in some organizations.
- **Entertainment Tools:** `Wallpaper Engine`, `OBS`, `Soundpad`.

*Disclaimer:* The script explicitly states in the report that these findings are for **review**, not an order to delete. Decisions are left to the human administrator.

## 3. Logic Verification
To ensure the script's logic works correctly, the following tests were performed:
- **Positive test for excessive software:** A test string (e.g., "Steam") was temporarily added to the registry query results or system. The script successfully identified it and placed it in the "Gaming Software" section.
- **Negative test for basic software:** The Archiver search keywords (e.g., "7-Zip") were temporarily excluded from the script logic. The script successfully output the `[RECOMMENDATION] Archiver not found` message.
- After testing, the script was reverted to its original state.

## 4. Known Limitations
- **WMIC Deprecation:** `wmic` is deprecated in newer Windows 11 builds. To handle large numbers (RAM, disk space) and avoid 32-bit integer overflow, PowerShell (`Get-CimInstance`) is used via batch file integration.
- **Registry limitations:** The script relies on the `DisplayName` parameter in the Uninstall registry keys. Some portable applications or software installed without standard registry keys will not be detected.
- **Encoding:** The script uses codepage 437 and English output to prevent encoding issues with Cyrillic characters in standard Windows Command Prompt.