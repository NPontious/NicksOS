{ pkgs, lib, ... }:

{
  # Systemd service for daily Robinhood & Fidelity briefing
  systemd.services.tradingagents-briefing = {
    description = "TradingAgents Daily Briefing for Robinhood & Fidelity";
    path = [
      pkgs.docker
      pkgs.python3
      pkgs.curl
    ];
    serviceConfig = {
      Type = "oneshot";
      User = "nicho";
      Group = "users";
      WorkingDirectory = "/home/nicho/TradingAgents";
      ExecStart = "${pkgs.python3}/bin/python3 /home/nicho/TradingAgents/daily_briefing.py";
      TimeoutSec = 3600; # 60 min maximum for multi-ticker analysis
    };
  };

  # Morning (8:30 AM ET) and Evening (4:30 PM ET) timers on weekdays
  systemd.timers.tradingagents-briefing = {
    description = "Timer for TradingAgents Daily Morning & Evening Briefings";
    partOf = [ "tradingagents-briefing.service" ];
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = [
        "Mon..Fri 08:30:00"
        "Mon..Fri 16:30:00"
      ];
      Persistent = true;
    };
  };
}
