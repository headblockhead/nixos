require ["fileinto", "mailbox"];

if header :contains "List-ID" "openraildata-talk.googlegroups.com" {
  fileinto "Groups.OpenRailData";
  stop;
}
