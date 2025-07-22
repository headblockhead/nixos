require ["fileinto", "mailbox"];

if address :contains "To" "airtable" {
  fileinto "Organizations.Airtable";
  stop;
}      
if address :contains "To" "apple" {
  fileinto "Organizations.Apple";
  stop;
}
if address :contains "To" "bsky" {
  fileinto "Organizations.Bluesky";
  stop;
}
if address :contains "From" "github.com" {
  fileinto "Organizations.GitHub";
  stop;
}
if address :contains "To" "google" {
  fileinto "Organizations.Google";
  stop;
}
if address :contains "To" "hackclub" {
  fileinto "Organizations.Hack Club";
  stop;
}
if address :contains "To" "immobilise" {
  fileinto "Organizations.Immobilise";
  stop;
}
if address :contains "To" "itch" {
  fileinto "Organizations.Itch";
  stop;
}
if address :contains "To" "jlc" {
  fileinto "Organizations.JLCPCB";
  stop;
}
if address :contains "To" "lner" {
  fileinto "Organizations.LNER";
  stop;
}
if address :contains "To" "meta" {
  fileinto "Organizations.Meta";
  stop;
}
if address :contains "To" "modrinth" {
  fileinto "Organizations.Modrinth";
  stop;
}
if address :contains "To" "nasa" {
  fileinto "Organizations.NASA";
  stop;
}
if address :contains "From" "pcbway.com" {
  fileinto "Organizations.PCBWay";
  stop;
}
if address :contains "From" "pcbx.com" {
  fileinto "Organizations.PCBX";
  stop;
}
if address :contains "To" "prusa" {
  fileinto "Organizations.Prusa";
  stop;
}
if address :contains "To" "steam" {
  fileinto "Organizations.Steam";
  stop;
}
if address :contains "To" "thepihut" {
  fileinto "Organizations.ThePiHut";
  stop;
}
if address :contains "To" "abuseipdb" {
  fileinto "Organizations.AbuseIPDB";
  stop;
}
if address :contains "To" "obsidian" {
  fileinto "Organizations.Obsidian";
  stop;
}
if address :contains "To" "microsoft" {
  fileinto "Organizations.Microsoft";
  stop;
}
if address :contains "To" "ubisoft" {
  fileinto "Organizations.Ubisoft";
  stop;
}

if address :contains "To" "openraildata" {
  fileinto "OpenRailData";
  stop;
}
if address :contains "To" "security" {
  fileinto "Security";
  stop;
}
if address :contains "To" "headblockhead" {
  fileinto "headblockhead";
  stop;
}
