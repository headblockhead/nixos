require ["fileinto", "mailbox"];

if address :contains "From" "pcbway.com" {
  fileinto "Organizations.PCBWay";
  stop;
}
if address :contains "From" "pcbx.com" {
  fileinto "Organizations.PCBX";
  stop;
}
if address :contains "X-Original-To" "openraildata" {
  fileinto "Groups.OpenRailData";
  stop;
}

# automated rules below
